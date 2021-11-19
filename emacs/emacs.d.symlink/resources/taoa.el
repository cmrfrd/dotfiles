(defun org-global-props (&optional property buffer)
  "Get the plists of global org properties of current buffer."
  (unless property (setq property "PROPERTY"))
  (with-current-buffer (or buffer (current-buffer))
    (org-element-map
        (org-element-parse-buffer)
        'keyword
      (lambda (el) (when (string-match property (org-element-property :key el)) el)))))

(defun org-global-prop-value (key)
  "Get global org property KEY of current buffer."
  (org-element-property :value (car (org-global-props key))))


;; This function is to use ux-hugo in blog posts
;; and leverage the 'CREATED' tag
;; example:
;; #+HUGO_CUSTOM_FRONT_MATTER: :date (org-created-to-blog-date)
(defun org-to-blog-date (date)
  (format-time-string "%Y-%m-%d"
                      (apply #'encode-time
                             (org-parse-time-string
                              date))))

;; Save the current
(defun* org-save-to-mdx (&key (filename "index"))
  (interactive)
  (let ((export-filename (concat
                          (file-name-sans-extension
                           (file-name-nondirectory filename)) ".mdx")))
    (message export-filename)
    (org-export-to-file 'hugo export-filename)))

(defun* export-to-mdx-on-save (&key (enable nil))
  (interactive)
  (if (and (not enable) (memq 'org-save-to-mdx after-save-hook))
      (progn
        (remove-hook 'after-save-hook 'org-save-to-mdx t)
        (message "Disabled mdx on save"))
    (add-hook 'after-save-hook 'org-save-to-mdx nil t)
    (message "Enabled mdx on save")))

;; Org mode to markdown converters do some funky stuff to TeX
;; here we go through the process of 'undoing' most of them
(defun sub-paren-for-dollar-sign (text backend info)
  (when (org-export-derived-backend-p backend 'hugo)
    (progn
      (s-replace-all
       '(("\\$$" . "\\\\["))
       (s-replace-all
        '(("\\\\]" . "$$")
          ("\\\\[" . "$$")
          ("\\\\(" . "$")
          ("\\\\)" . "$")
          ("\\\\}" . "\\}")
          ("\\\\{" . "\\{")
          ("\\\\_" . "_")
          ("\\_" . "_")
          ) text)))))

;; Org mode to markdown converters add curly braces
;; to headlines, here we remove them
(defun remove-regexp-curly-braces (text backend info)
  (when (org-export-derived-backend-p backend 'hugo)
    (progn
      (replace-regexp-in-string "{#.*}" "" text)
      )))

;; Two little utilities we'll need for substituting
;; latex inline via macros are little wrapper funcs
(defun latex-inline-wrap (str) (format "$%s$" str))
(defun latex-display-wrap (str) (format "$$%s$$" str))

;; Hugo is great, but ox-hugo doesn't render images
;; the way we like so lets stub it out
(defun org-hugo-link (link desc info)
  (org-md-link link desc info))
