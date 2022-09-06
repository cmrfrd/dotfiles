;;; ox-jekyll-lite.el --- Export Jekyll on Markdown articles using org-mode. -*- lexical-binding: t; -*-

;; Copyright (C) 2019 Peter Wills

;; Author: Elsa Gonsiorowski <gonsie@me.com>
;; Authors: Yoshinari Nomura <nom@quickhack.net>
;;          Justin Gordon <justin.gordon@gmail.com>
;;          Matt Price <moptop99@gmail.com>
;;          Kaushal Modi <kaushal.modi@gmail.com>
;;          Peter Wills <peter@pwills.com>
;; Keywords: org, jekyll
;; Version: 0.1

;; This is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This library implements a Jekyll-style md backend for
;; Org exporter, based on `md' back-end.
;;
;; It provides two commands for export, depending on the desired
;; output: `org-jekyll-lite-export-as-md' (temporary buffer) and
;; `org-jekyll-lite-export-to-md' ("md" file with YAML front matter).
;;
;; For publishing, `org-jekyll-lite-publish-to-md' is available.
;; For composing, `org-jekyll-lite-insert-export-options-template' is available.

(require 'ox-md)
(require 's)
(require 'dash)

;;; User Configurable Variables

(defgroup org-export-jekyll-lite nil
  "Options for exporting Org mode files to jekyll MD."
  :tag "Org Jekyll MD"
  :group 'org-export
  :version "24.2")

(defcustom org-jekyll-lite-include-yaml-front-matter t
  "If true, then include yaml-front-matter when exporting to md.

If false, then you should include the yaml front matter like this at the top of
the file:

#+BEGIN_EXPORT HTML
---
title: \"Exporting Org to Markdown in Jekyll\"
date: 2019-09-15
categories: post
tags: tech 
keywords: Markdown Jekyll Org
excerpt: Details on exporting org files into a jekyll-friendly markdown format.
---
#+END_EXPORT HTML"
  :group 'org-export-jekyll
  :type 'boolean)

(defcustom org-jekyll-lite-layout ""
  "Default layout used in Jekyll article."
  :group 'org-export-jekyll
  :type 'string)

(defcustom org-jekyll-lite-categories "post"
  "Default space-separated categories in Jekyll article."
  :group 'org-export-jekyll
  :type 'string)

(defcustom org-jekyll-lite-tags ""
  "Default space-separated tags in Jekyll article."
  :group 'org-export-jekyll
  :type 'string)

(defcustom org-jekyll-project-root ""
  "Root of jekyll project directory. Links will be modified to treat this directory as root."
  :group 'org-export-jekyll
  :type 'string)

;;; Define Back-End

(org-export-define-derived-backend 'jekyll 'md
  :filters-alist '((:filter-parse-tree . org-jekyll-lite-separate-elements))
  :menu-entry
  '(?j "Jekyll: export to Markdown with YAML front matter."
       ((?J "As Jekyll buffer" (lambda (a s v b) (org-jekyll-lite-export-as-md a s v)))
        (?j "As Jekyll file" (lambda (a s v b) (org-jekyll-lite-export-to-md a s v)))))
  :translate-alist
  '((headline . org-jekyll-lite-headline-offset)
    (inner-template . org-jekyll-lite-inner-template) 
    (footnote-reference . org-jekyll-lite-footnote-reference)
    (src-block . org-jekyll-lite-src-block)
    (latex-environment . org-jekyll-lite-latex-environment)
    (latex-fragment . org-jekyll-lite-latex-fragment)
    (link . org-jekyll-lite-link)
    (underline . org-jekyll-lite-underline)
    (table . org-jekyll-lite-table)
    (table-cell . org-jekyll-lite-table-cell)
    (table-row . org-jekyll-lite-table-row)
    (template . org-jekyll-lite-template)) ;; add YAML front matter.
  :options-alist
  '((:jekyll-layout "JEKYLL_LAYOUT" nil org-jekyll-lite-layout)
    (:jekyll-categories "JEKYLL_CATEGORIES" nil org-jekyll-lite-categories)
    (:jekyll-tags "JEKYLL_TAGS" nil org-jekyll-lite-tags)))


;;;; Links

(defun org-jekyll-lite-resolve-file-path (path)
  "Resolve a file path so that it treats the jekyll directory as root."
  (if (string= org-jekyll-project-root "")
      (progn
        (message "Variable org-jekyll-project-root is not set, \
so file paths will be linked as provided.")
        path)
    (let ;; remove the trailing slash, so that it looks like e.g. "/assets/images/kitties.jpg"
        ((org-jekyll-project-root-clean (s-chop-suffix "/" org-jekyll-project-root)))
      (s-chop-prefix org-jekyll-project-root-clean path))))


(defun org-jekyll-lite-file-is-image? (raw-link)
  "Tests whether RAW-LINK is a link to an image file."
  (let* ((image-suffixes '(".apng" ".bmp" ".gif" ".ico" ".cur" ".jpg" ".jpeg" ".jfif"
                          ".pjpeg" ".pjp" ".png" ".svg" ".webp"))
         (suffix-matches (--filter (s-ends-with? it raw-link t) image-suffixes)))
    (not (null suffix-matches))))

(defun org-jekyll-lite-link-maybe-image (desc path)
  "If PATH is to a known image type, render the link as an image (with a
  bang). Otherwise, render the image as a usual link."
  (if (org-jekyll-lite-file-is-image? path)
      ;; it's an image, so prepend a bang
      (format "![%s](%s)" desc path)
    ;; non-image file, so no bang
    (format "[%s](%s)" desc path)))

(defun org-jekyll-lite-link (link desc info)
  "Transcode a LINK into Markdown format. 

DESC is the links description. 
INFO is a plist used as a communication channel. 

This function will:
- render images appropriately
- return file paths relative to the jekyll project root"
  (let* ((raw-link (org-element-property :raw-link link))
         (raw-path (org-element-property :path link))
         (type (org-element-property :type link))
         (resolved-path
          (cond
           ;; if the path is to a file, make it treat the jekyll root directory as system
           ;; root, which is how jekyll wants its links.
           ((string= type "file")
            (org-jekyll-lite-resolve-file-path raw-path))
           ;; if not a file, then just use the raw link itself.
           (t raw-link)
         (desc (if desc desc resolved-path)))))
    ;; (message "[ox-hugo-link DBG] link: %S" link)
    ;; (message "[ox-hugo-link DBG] link path: %s" (org-element-property :path link))
    ;; (message "[ox-hugo-link DBG] link filename: %s" (expand-file-name (plist-get (car (cdr link)) :path)))
    ;; (message "[ox-hugo-link DBG] link type: %s" type)
    (org-jekyll-lite-link-maybe-image desc resolved-path)))

;;;; text
(defun org-jekyll-lite-underline (underline contents info)
  "Transcode UNDERLINE from Org to Markdown.
CONTENTS is the text with underline markup.  INFO is a plist
holding contextual information."
  (format "<u>%s</u>" contents))

;;;; Footnote Reference
(defun org-jekyll-lite-footnote-reference (footnote-reference _contents info)
  "Transcode a FOOTNOTE-REFERENCE element into Jekyll-Lite Markdown format.
CONTENTS is nil.  INFO is a plist holding contextual information.

Adapted from ox-blackfriday, via ox-hugo."
  ;; (message "footref: %s" footnote-reference)
  (concat
   ;; Insert separator between two footnotes in a row.
   (let ((prev (org-export-get-previous-element footnote-reference info)))
     (and (eq (org-element-type prev) 'footnote-reference)
          (plist-get info :html-footnote-separator)))
   (format "[^fn%d]" (org-export-get-footnote-number footnote-reference info))))

;;;; Footnote section
(defun org-jekyll-lite-footnote-section (info)
  "Format the footnote section.
INFO is a plist used as a communication channel.

Adapted from ox-blackfriday, via ox-hugo."
  (let ((fn-alist (org-export-collect-footnote-definitions info))
        fn-alist-stripped)
    (let ((n 1)
          def)
      (dolist (fn fn-alist)
        ;; (message "fn: %S" fn)
        ;; (message "fn: %s" (org-export-data fn info)) ;This gives error
        ;; (message "fn nth 2 car: %s" (org-export-data (nth 2 fn) info))
        (setq def (org-trim (org-export-data (nth 2 fn) info)))
        ;; Support multi-line footnote definitions by folding all
        ;; footnote definition lines into a single line as Blackfriday
        ;; does not support that.
        (setq def (replace-regexp-in-string "\n" " " def))
        ;; Replace multiple consecutive spaces with a single space.
        (setq def (replace-regexp-in-string "[[:blank:]]+" " " def))
        (push (cons n def) fn-alist-stripped)
        (setq n (1+ n))))
    (when fn-alist-stripped
      (mapconcat (lambda (fn)
                   ;; (message "dbg: fn: %0d -- %s" (car fn) (cdr fn))
                   (format "[^fn%d]: %s"
                           (car fn)     ;footnote number
                           (cdr fn)))   ;footnote definition
                 (nreverse fn-alist-stripped)
                 "\n"))))

;;;; Latex Environment
(defun org-jekyll-lite-latex-environment (latex-environment _contents info)
  "Transcode a LATEX-ENVIRONMENT object into Markdown format.
INFO is a plist holding contextual information.

Adapted from ox-blackfriday via ox-hugo."
  (let ((processing-type (plist-get info :with-latex)))
    (cond
     ((memq processing-type '(t mathjax))
      (let* ((latex-env (org-remove-indentation
                         (org-element-property :value latex-environment)))
             (env (org-html-format-latex latex-env 'mathjax info))
             (env (org-jekyll-lite-escape-chars-in-equation env)))
        env))
     (t
      (org-html-latex-environment latex-environment nil info)))))

;;;; Latex Fragment
(defun org-jekyll-lite-latex-fragment (latex-fragment _contents info)
  "Transcode a LATEX-FRAGMENT object into Markdown format.
INFO is a plist holding contextual information.

Adapted from ox-blackfriday via ox-hugo."
  (let ((processing-type (plist-get info :with-latex)))
    (cond
     ((memq processing-type '(t mathjax))
      (let* ((latex-frag (org-element-property :value latex-fragment))
             (frag (org-html-format-latex latex-frag 'mathjax info))
             (frag (org-jekyll-lite-escape-chars-in-equation frag)))
        ;; (message "[ox-bf-latex-frag DBG] frag: %s" frag)
        frag))
     (t
      (org-html-latex-fragment latex-fragment nil info)))))

;;;; Escape certain characters inside equations (Blackfriday bug workaround)
(defun org-jekyll-lite-escape-chars-in-equation (str)
  "Escape few characters in STR so that Markdown doesn't parse them.

Adapted from ox-blackfriday via ox-hugo.

Do not interpret underscores and asterisks in equations as
Markdown formatting
characters (https://gohugo.io/content-management/formats#solution):
  \"_\" -> \"\\=\\_\"
  \"*\" -> \"\\=\\*\"
https://github.com/kaushalmodi/ox-hugo/issues/104
Blackfriday converts \"(r)\" to Registered Trademark symbol,
\"(c)\" to Copyright symbol, and \"(tm)\" to Trademark symbol if
the SmartyPants extension is enabled (and there is no way to
disable just this).  So insert an extra space after the opening
parentheses in those strings to trick Blackfriday/smartParens
from activating inside equations.  That extra space anyways
doesn't matter in equations.
  \"(c)\" -> \"( c)\"
  \"(r)\" -> \"( r)\"
  \"(tm)\" -> \"( tm)\"
https://gohugo.io/content-management/formats#solution
https://github.com/kaushalmodi/ox-hugo/issues/138
Need to escape the backslash in \"\\(\", \"\\)\", .. to make
Blackfriday happy.  So:
  \"\\(\" -> \"\\\\(\"
  \"\\)\" -> \"\\\\)\"
  \"\\\\=[\" -> \"\\\\\\=[\"
  \"\\\\=]\" -> \"\\\\\\=]\"
  \"\\\\={\" -> \"\\\\\\={\"
  \"\\\\=}\" -> \"\\\\\\=}\"
  \"\\|\" -> \"\\\\|\"
and finally:
  \"\\\\\" -> \"\\\\\\\\\\\\\"."
  (let* (;; _ -> \_, * -> \*
         (escaped-str (replace-regexp-in-string "[_*]" "\\\\\\&" str))
         ;; (c) -> ( c), (r) -> ( r), (tm) -> ( tm)
         (escaped-str (replace-regexp-in-string "(\\(c\\|r\\|tm\\))" "( \\1)" escaped-str))
         ;; \( -> \\(, \) -> \\), \[ -> \\[, \] -> \\], \{ -> \\{, \} -> \\}, \| -> \\|
         (escaped-str (replace-regexp-in-string "\\(\\\\[](){}[|]\\)" "\\\\\\1" escaped-str))
         (escaped-str (replace-regexp-in-string
                       "\\([^\\]\\)\\\\\\{2\\}[[:blank:]]*$" ;Replace "\\" at EOL with:
                       "\\1\\\\\\\\\\\\\\\\\\\\\\\\"             ;"\\\\\\"
                       escaped-str)))
    escaped-str))


;;; Headline
;;; Keep the level as defined in original content
;;; ** subtree => ## heading

(defun org-jekyll-lite-headline-offset (headline contents info)
  "proper headline offset"
  (let* ((info (plist-put info :headline-offset 0)))
    (org-md-headline headline contents info)))


;;; Internal Filters

(defun org-jekyll-lite-separate-elements (tree _backend info)
  "Fix blank lines between elements.

TREE is the parse tree being exported.  BACKEND is the export
back-end used.  INFO is a plist used as a communication channel.

Enforce a blank line between elements.  There are three exceptions
to this rule:

  1. Preserve blank lines between sibling items in a plain list.

  2. In an item, remove any blank line before the very first
     paragraph and the next sub-list when the latter ends the
     current item.

  3. Do not insert blank lines between table rows.

Assume BACKEND is `jekyll'."
  (org-element-map tree (remq 'item org-element-all-elements)
    (lambda (e)
      (org-element-put-property
       e :post-blank
       (if (and (eq (org-element-type e) 'paragraph)
		(eq (org-element-type (org-element-property :parent e)) 'item)
		(org-export-first-sibling-p e info)
		(let ((next (org-export-get-next-element e info)))
		  (and (eq (org-element-type next) 'plain-list)
		       (not (org-export-get-next-element next info)))))
	   0
	 (if (eq (org-element-type e) 'table-row)
             0
           1)))))
  ;; Return updated tree.
  tree)

(defun org-jekyll-lite-clean-language (language)
  "Clean up the language tag from a source block.

At the moment, only translate 'ipython' to 'python'."
  (if (string= language "ipython") "python" language))

(defun org-jekyll-lite-src-block (src-block contents info)
  "Transcode SRC-BLOCK element into Markdown format. CONTENTS is
nil.  INFO is a plist used as a communication channel.

Adapted from ox-gfm."
  (let* ((lang (org-jekyll-lite-clean-language
                (org-element-property :language src-block)))
         (code (org-export-format-code-default src-block info))
         (prefix (concat "```" lang "\n"))
         (suffix "```"))
    (concat prefix code suffix)))

(defun org-jekyll-lite-table (table contents info)
  "Empty transformation. Org tables should be valid kramdown syntax."
  contents)

(defun org-jekyll-lite-table-cell (table-cell contents info)
  "Empty transformation. Org tables should be valid kramdown syntax."
  (if contents
      (format "| %s " contents)
    "| "))

(defun org-jekyll-lite-table-row (table-row contents info)
  "Empty transformation. Org tables should be valid kramdown syntax."
  (if contents
      (format "%s|" contents)
    (let* ((table (org-export-get-parent table-row))
           (rc (org-export-table-dimensions table info)))
      (concat (apply 'concat (make-list (cdr rc) "|---"))
              (identity "|")))))

;;; Template

(defun org-jekyll-lite-template (contents info)
  "Return complete document string after MD conversion.

CONTENTS is the transcoded contents string. INFO is a plist
holding export options."
  (if org-jekyll-lite-include-yaml-front-matter
      (concat (org-jekyll-lite--yaml-front-matter info) contents)
    contents))

(defun org-jekyll-lite-inner-template (contents info)
  "Return body of document string after MD conversion.

CONTENTS is the transcoded contents string.  INFO is a plist
holding export options."
  (concat
   ;; Table of contents.
   (let ((depth (plist-get info :with-toc)))
     (when depth (org-md--build-toc info (and (wholenump depth) depth))))
   ;; Document contents.
   contents
   ;; Footnotes section.
   "\n\n<!----- Footnotes ----->\n\n"
   (org-jekyll-lite-footnote-section info)))

;;; YAML Front Matter

(defun org-jekyll-lite--get-option (info property-name &optional default)
  "Get org export options, or an (optional) user-provided
default, or (if user does not provide a default) an empty
string."
  (let ((property (org-export-data (plist-get info property-name) info)))
    (format "%s" (or property default ""))))

(defun org-jekyll-lite--yaml-front-matter (info)
  "Creat YAML frontmatter content."
  (let ((convert-to-yaml-list
         (lambda (arg)
           (mapconcat #'(lambda (text)(concat "\n- " text))
                      (split-string arg) " "))))
    (let* ((layout-value
            (org-jekyll-lite--get-option info
                                       :jekyll-layout org-jekyll-lite-layout))
           (title
            (concat "\ntitle: \""
                    (org-jekyll-lite--get-option info
                                               :title) "\""))
           (excerpt
            (concat "\nexcerpt: \""
                    (org-jekyll-lite--get-option info
                                               :subtitle) "\""))
           ;; don't include the layout category if it's not specified
           (layout (if (not (string= layout-value ""))
                       (concat "\nlayout: " layout-value)
                     ""))
           (categories
            (concat "\ncategories: "
                    (funcall convert-to-yaml-list
                             (org-jekyll-lite--get-option
                              info
                              :jekyll-categories org-jekyll-lite-categories))))
           (tags
            (concat "\ntags: "
                    (funcall convert-to-yaml-list
                             (org-jekyll-lite--get-option
                              info
                              :jekyll-tags org-jekyll-lite-tags))))
           (date
            (and (plist-get info :with-date)
                 (concat "\ndate: "
                         (org-jekyll-lite--get-option info :date)))))
      (concat
       "---"
       title
       excerpt
       date
       layout
       categories
       tags
       "\n---\n"))))

;;; End-User functions

;;;###autoload
(defun org-jekyll-lite-export-as-md (&optional async subtreep visible-only)
  "Export current buffer as a Markdown buffer adding some YAML front matter."
  (interactive)
  (org-export-to-buffer 'jekyll "*Org Jekyll-Markdown Export*"
    async subtreep visible-only nil nil (lambda () (markdown-mode))))

;;;###autoload
(defun org-jekyll-lite-export-to-md (&optional async subtreep visible-only)
  "Export current buffer to a Markdown file adding some YAML front matter."
  (interactive)
  (let ((outfile (org-export-output-file-name ".md" subtreep)))
    (org-export-to-file 'jekyll outfile async subtreep visible-only)))

;;;###autoload
(defun org-jekyll-lite-publish-to-md (plist filename pub-dir)
  "Publish an org file to Markdown with YAML front matter.

FILENAME is the filename of the Org file to be published.  PLIST
is the property list for the given project.  PUB-DIR is the
publishing directory.

Return output file name."
  (org-publish-org-to 'jekyll filename ".md" plist pub-dir))

;;;###autoload
(defun org-jekyll-lite-insert-export-options-template
  (&optional title date setupfile categories tags layout)
  "Insert a settings template for Jekyll exporter."
  (interactive)
  (let ((layout     (or layout org-jekyll-lite-layout))
        (tags       (or tags org-jekyll-lite-tags))
        (categories (or categories org-jekyll-lite-categories)))
    (save-excursion
      (insert (format (concat
                       "#+TITLE: "               title
                       "\n#+DATE: "              date
                       "\n#+SETUPFILE: "         setupfile
                       "\n#+JEKYLL_LAYOUT: "     layout
                       "\n#+JEKYLL_CATEGORIES: " categories
                       "\n#+JEKYLL_TAGS: "       tags
                       "\n\n* \n\n{{{more}}}"))))))

;;; provide

(provide 'ox-jekyll-lite)

;;; ox-jekyll-lite.el ends here
