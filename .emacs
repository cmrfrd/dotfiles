
;;
;; Light config
;;
(setq make-backup-files nil) ; stop creating backup~ files
(setq auto-save-default nil) ; stop creating #autosave# files

;; hotkey window resizingx
(global-set-key (kbd "C-M-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "C-M-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "C-M-<down>") 'shrink-window)
(global-set-key (kbd "C-M-<up>") 'enlarge-window)

;; window switching hotkeys
(global-set-key (kbd "C-c <left>")  'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key (kbd "C-c <up>")    'windmove-up)
(global-set-key (kbd "C-c <down>")  'windmove-down)

;; add line numbers
(global-linum-mode t)

;; Interactive shell popping
(use-package shell-pop
  :ensure t)
;(global-set-key (kbd "<M-RET>") 'shell-pop)
(custom-set-variables
 '(shell-pop-shell-type (quote ("ansi-term" "*ansi-term*" (lambda nil (ansi-term shell-pop-term-shell)))))
 '(shell-pop-window-position "right")
 '(shell-pop-universal-key "M-RET"))

;; hotkey scrolling
(defun next-line-and-recenter () (interactive) (next-line) (recenter))
(defun previous-line-and-recenter () (interactive) (previous-line) (recenter))
(global-set-key (kbd "C-n") 'next-line-and-recenter)
(global-set-key (kbd "C-p") 'previous-line-and-recenter)
;;
;; END LIGHT CONFIG
;;



;;
;; Require MELPA packages
;;
(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives (cons "gnu" (concat proto "://elpa.gnu.org/packages/")))))
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/"))

;;; Uncomment for auto refresh of packages
;;;(package-refresh-contents)
;;
;; END Require MELPA packages
;;

;;;;;;
;;;;;; AUTO CONFIG DO NOT TOUCH
;;;;;;
(package-initialize)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (shell-pop py-autopep8 transpose-frame docker neotree flycheck elpy company-anaconda pythonic markdown-mode all-the-icons kaolin-themes dockerfile-mode anaconda-mode docker-tramp company-jedi company use-package "company" "htmlize" ranger))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;;;;;;
;;;;;; END AUTO CONFIG DO NOT TOUCH
;;;;;;

;;
;; Install use-package utility for installing
;; and requireing packages
;;
;; docs
;; https://github.com/jwiegley/use-package
(if (not (package-installed-p 'use-package))
    (progn
      (package-refresh-contents)
      (package-install 'use-package)))
(require 'use-package)
;;
;; END OF USE-PACKAGE INSTALL
;; CAREFUL EDITING
;;


;;
;; Theme installation
;; 
(use-package all-the-icons
  :ensure all-the-icons)
(use-package kaolin-themes
  :config
  (load-theme 'kaolin-aurora t)
  (kaolin-treemacs-theme))
(set-face-foreground 'linum "#42B8A1")
;;
;; END Theme installation
;; 

;;
;; Install file browsing with ranger
;;
(use-package ranger
  :ensure ranger)
(ranger-override-dired-mode t)

;;
;; IDE-like autocomplete.
;;
(use-package company
  :ensure t
  :config
  (global-company-mode)  
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 3)
  (use-package company-jedi
    :defer t
    :init
    :config
    (add-hook 'python-mode-hook 'jedi:setup)
    (add-to-list 'company-backends 'company-jedi))
)


;;
;; Syntax highlithing
;;
(use-package pythonic
  :ensure pythonic)
(use-package anaconda-mode
  :ensure anaconda-mode)
(use-package company-anaconda
  :ensure company-anaconda)
(use-package py-autopep8
  :ensure t)

(defun iambubbi/python-mode-hook ()
  (add-to-list 'company-backends 'company-jedi))
(defun iambubbi/company-anaconda-hook ()
  (add-to-list 'company-backends 'company-anaconda))
(defun iambubbi/flycheck-hook ()
  (global-flycheck-mode)
  (setq flycheck-check-syntax-automatically '(mode-enabled save)))

(add-hook 'python-mode-hook 'anaconda-mode)
(add-hook 'python-mode-hook 'anaconda-eldoc-mode)
(add-hook 'python-mode-hook 'iambubbi/python-mode-hook)
(add-hook 'python-mode-hook 'iambubbi/company-anaconda-hook)
(add-hook 'python-mode-hook 'iambubbi/flycheck-hook)
(add-hook 'python-mode-hook 'py-autopep8-enable-on-save)

(add-hook 'flycheck-mode-hook #'flycheck-virtualenv-setup)



(use-package flycheck
  :ensure t)
(use-package flymake
  :ensure t)

(use-package elpy
  :ensure t
  :after pythonic
  :config (elpy-enable))



;; Configure flymake for Python
(when (load "flymake" t)
  (defun flymake-pylint-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list "epylint" (list local-file))))
  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.py\\'" flymake-pylint-init)))

;; Set as a minor mode for Python
(add-hook 'python-mode-hook '(lambda () (flymake-mode)))
;; Configure to wait a bit longer after edits before starting
(setq-default flymake-no-changes-timeout '3)
;; Keymaps to navigate to the errors
(add-hook 'python-mode-hook '(lambda () (define-key python-mode-map "\C-cn" 'flymake-goto-next-error)))
(add-hook 'python-mode-hook '(lambda () (define-key python-mode-map "\C-cp" 'flymake-goto-prev-error)))
(defun show-fly-err-at-point ()
  "If the cursor is sitting on a flymake error, display the message in the minibuffer"
  (require 'cl)
  (interactive)
  (let ((line-no (line-number-at-pos)))
    (dolist (elem flymake-err-info)
      (if (eq (car elem) line-no)
      (let ((err (car (second elem))))
        (message "%s" (flymake-ler-text err)))))))

(add-hook 'post-command-hook 'show-fly-err-at-point)







;;
;; Remote machine editor
;;
(use-package docker-tramp
  :ensure docker-tramp)
(use-package tramp
  :defer t
  :config
  (setf tramp-persistency-file-name
        (concat temporary-file-directory "tramp-" (user-login-name))))

;;; python mode
;; The package is "python" but the mode is "python-mode":
(use-package python
  :mode ("\\.py\\'" . python-mode)
  :interpreter ("python" . python-mode))

;;;; Dockerfiles
(use-package dockerfile-mode
  :ensure dockerfile-mode)
(require 'dockerfile-mode)
(add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode))

;;;; docker elisp
(use-package docker
  :ensure t
  :bind ("C-c d" . docker))
(use-package transpose-frame
  :ensure t)

;;;;; Markdown
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "/usr/bin/pandoc"))


;;
;; NEOTREE
;;
(use-package neotree
  :init
  (progn
    ;; Every time when the neotree window is opened, it will try to find current
    ;; file and jump to node.
    (setq-default neo-smart-open t)
    (setq-default neo-dont-be-alone t)
    (setq-default neo-window-fixed-size nil)
    (setq-default neo-show-hidden-files t))
  :config
  (progn
    (setq neo-theme 'nerd) ; 'classic, 'nerd, 'ascii, 'arrow
    (setq neo-vc-integration '(face char))

    ;; Patch to fix vc integration
    (defun neo-vc-for-node (node)
      (let* ((backend (vc-backend node))
             (vc-state (when backend (vc-state node backend))))
        ;; (message "%s %s %s" node backend vc-state)
        (cons (cdr (assoc vc-state neo-vc-state-char-alist))
              (cl-case vc-state
                (up-to-date       neo-vc-up-to-date-face)
                (edited           neo-vc-edited-face)
                (needs-update     neo-vc-needs-update-face)
                (needs-merge      neo-vc-needs-merge-face)
                (unlocked-changes neo-vc-unlocked-changes-face)
                (added            neo-vc-added-face)
                (removed          neo-vc-removed-face)
                (conflict         neo-vc-conflict-face)
                (missing          neo-vc-missing-face)
                (ignored          neo-vc-ignored-face)
                (unregistered     neo-vc-unregistered-face)
                (user             neo-vc-user-face)
                (t                neo-vc-default-face)))))

    (defun modi/neotree-go-up-dir ()
      (interactive)
      (goto-char (point-min))
      (forward-line 2)
      (neotree-change-root))

    ;; http://emacs.stackexchange.com/a/12156/115
    (defun modi/find-file-next-in-dir (&optional prev)
      "Open the next file in the directory.
When PREV is non-nil, open the previous file in the directory."
      (interactive "P")
      (let ((neo-init-state (neo-global--window-exists-p)))
        (if (null neo-init-state)
            (neotree-show))
        (neo-global--select-window)
        (if (if prev
                (neotree-previous-line)
              (neotree-next-line))
            (progn
              (neo-buffer--execute nil
                                   (quote neo-open-file)
                                   (lambda (full-path &optional arg)
                                     (message "Reached dir: %s/" full-path)
                                     (if prev
                                         (neotree-next-line)
                                       (neotree-previous-line)))))
          (progn
            (if prev
                (message "You are already on the first file in the directory.")
              (message "You are already on the last file in the directory."))))
        (if (null neo-init-state)
            (neotree-hide))))

    (defun modi/find-file-prev-in-dir ()
      "Open the next file in the directory."
      (interactive)
      (modi/find-file-next-in-dir :prev))

    (bind-keys
     :map neotree-mode-map
      ("^" . modi/neotree-go-up-dir)
      ("<C-return>" . neotree-change-root)
      ("C" . neotree-change-root)
      ("c" . neotree-create-node)
      ("+" . neotree-create-node)
      ("d" . neotree-delete-node)
      ("r" . neotree-rename-node)))

  (add-to-list 'window-size-change-functions
               (lambda (frame)
                 (let ((neo-window (neo-global--get-window)))
                   (unless (null neo-window)
                     (setq neo-window-width (window-width neo-window)))))))
(global-set-key [f8] 'neotree-toggle)



(defun er-switch-to-previous-buffer ()
  "Switch to previously open buffer.
Repeated invocations toggle between the two most recently open buffers."
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) 1)))
(global-set-key (kbd "C-c b") #'er-switch-to-previous-buffer)
