;;;;
;;;;    Alexander Comerford .emacs configuration
;;;;
;;;;    A simple v1 implementation
;;;;



;;; 
;;;  PACKAGE-REPOSITORY CONFIGURATION
;;;
;;;  In this section we add a few package repositories
;;;  to the package-archives list to be imported later.
;;;  After adding we will refresh our package contents
;;;
(package-initialize)
(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (add-to-list 'package-archives
               '("melpa-stable" . "https://stable.melpa.org/packages/"))
  (add-to-list 'package-archives
               '("melpa" . "http://melpa.org/packages/")))
;(package-refresh-contents)

;;;
;;; Install the use-package package
;;; This enables us to install packages declaritively
;;; 
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

;;;;;;
;;;;;; AUTO CONFIG DO NOT TOUCH
;;;;;;
(package-initialize)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("f97e1d3abc6303757e38130f4003e9e0d76026fc466d9286d661499158a06d99" "e893b3d424a9b8b19fb8ab8612158c5b12b9071ea09bade71ba60f43c69355e6" "35eddbaa052a71ab98bbe0dbc1a5cb07ffbb5d569227ce00412579c2048e7699" "3adb42835b51c3a55bc6c1e182a0dd8d278c158769830da43705646196fc367e" "f4260b30a578a781b4c0858a4a0a6071778aaf69aed4ce2872346cbb28693c1a" default)))
 '(package-selected-packages
   (quote
    (diff-hl magit multi-term company-shell company-ycmd company-flx docker-compose-mode jedi helm projectile shell-pop py-autopep8 transpose-frame docker neotree flycheck elpy company-anaconda pythonic markdown-mode all-the-icons kaolin-themes dockerfile-mode anaconda-mode docker-tramp company-jedi company use-package "company" "htmlize" ranger)))
 '(shell-pop-full-span t)
 '(shell-pop-shell-type
   (quote
    ("ansi-term" "*ansi-term*"
     (lambda nil
       (ansi-term shell-pop-term-shell)))))
 '(shell-pop-universal-key "M-RET"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;;;
;;;; HELM CONFIG
;;;;
(use-package helm
  :ensure t
  :bind (("M-x" . helm-M-x)
         ("C-x b" . helm-buffers-list)
         ("C-x f" . helm-find-files)
         ("C-x r b" . helm-bookmarks))
  :config
  (require 'helm-config)
  (helm-mode 1)

  ;; Globally enable fuzzy matching for helm-mode.
  (setq helm-mode-fuzzy-match t)
  (setq helm-completion-in-region-fuzzy-match t)

  (setq helm-M-x-fuzzy-match t)
  (setq helm-buffers-fuzzy-matching t)
  (setq helm-recentf-fuzzy-match t)

  (global-set-key [remap execute-extended-command] #'helm-smex)
  (global-set-key (kbd "M-X") #'helm-smex-major-mode-commands)

  ;; Disable Helm in the following functions.
  ;; See: https://github.com/emacs-helm/helm/wiki#customize-helm-mode
  (setq helm-completing-read-handlers-alist
        '((find-file-read-only . ido)
          (magit-gitignore . nil)
          (rename-file . ido)))

  ;; Enter directories with RET, same as ido
  ;; http://emacs.stackexchange.com/questions/3798/how-do-i-make-pressing-ret-in-helm-find-files-open-the-directory/7896#7896
  (defun helm-find-files-navigate-forward (orig-fun &rest args)
    (if (file-directory-p (helm-get-selection))
        (apply orig-fun args)
      (helm-maybe-exit-minibuffer)))
  (advice-add 'helm-execute-persistent-action :around #'helm-find-files-navigate-forward)

  (with-eval-after-load 'helm-files
    (define-key helm-find-files-map (kbd "<return>") 'helm-execute-persistent-action))

  ;; Don't show "." and ".." directories when finding files.
  ;; https://github.com/hatschipuh/better-helm
  (with-eval-after-load 'helm-files
    (advice-add 'helm-ff-filter-candidate-one-by-one
                :before-while 'no-dots-display-file-p))

  (defvar no-dots-whitelist nil
    "List of helm buffers in which to show dots.")

  (defun no-dots-in-white-listed-helm-buffer-p ()
    (member helm-buffer no-dots-whitelist))
 
  (defun no-dots-display-file-p (file)
    ;; in a whitelisted buffer display the file regardless of its name
    (or (no-dots-in-white-listed-helm-buffer-p)
        ;; not in a whitelisted buffer display all files
        ;; which does not end with /. /..
        (not (string-match "\\(?:/\\|\\`\\)\\.\\{1,2\\}\\'" file)))))
(use-package helm-projectile
  :ensure t
  :init
  (setq projectile-completion-system 'helm)
  (helm-projectile-on))
;;;;
;;;; HELM CONFIG END
;;;;




;;
;; Light config
;;

;; Start emacs server
;(server-start)

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

;; hotkey scrolling
(defun next-line-and-recenter () (interactive) (next-line) (recenter))
(defun previous-line-and-recenter () (interactive) (previous-line) (recenter))
(global-set-key (kbd "C-n") 'next-line-and-recenter)
(global-set-key (kbd "C-p") 'previous-line-and-recenter) 

;; Configure backup files
(setq backup-directory-alist '(("." . "~/.emacs.d/backups"))
      auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save-list/" t))
      delete-old-versions t
      version-control t
      vc-make-backup-files t
      backup-by-copying t
      kept-new-versions 2
      kept-old-versions 2)

;; no menu bar
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))


;;
;; END LIGHT CONFIG
;;



;;
;; Theme installation
;;
(use-package all-the-icons
  :ensure all-the-icons)

;; (use-package kaolin-themes
;;   :ensure t
;;   :config
;;   (load-theme 'kaolin-dark t)
;;   (kaolin-treemacs-theme)
;;   (set-face-attribute 'region nil :background "#35393C")
;;   (set-face-foreground 'linum "#42B8A7")
;;   (setq kaolin-themes-hl-line-colored t)       
;;   (setq kaolin-themes-distinct-fringe t)  
;;   (setq kaolin-themes-distinct-company-scrollbar t)  
;;   )

;(add-to-list 'default-frame-alist '(foreground-color . "#E0DFDB"))
;(add-to-list 'default-frame-alist '(background-color . "#0f1c26"))
;;
;; END Theme installation
;;

;;
;; IDE like project
;;
(use-package projectile
  :ensure t
  :config
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1))

;;
;; Install file browsing with ranger
;;
(use-package ranger
  :ensure ranger)
(ranger-override-dired-mode t)

;;
;; IDE-like autocomplete.
;;
(use-package jedi
  :ensure t
  :init
  (add-hook 'python-mode-hook 'jedi:setup)
  (add-hook 'python-mode-hook 'jedi:ac-setup))
(use-package company
  :ensure t
  :config
  (global-company-mode)  
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 3))
(use-package company-jedi
  :ensure t
  :defer t
  :init
  :config
  (setq jedi:setup-keys t)
  (setq jedi:complete-on-dot t)
  (add-hook 'python-mode-hook 'jedi:setup)
  (add-to-list 'company-backends 'company-jedi))



(use-package company :defer 30
  :ensure t
  :init (global-company-mode t)
  :config
  (defvar company-mode/enable-yas t
    "Enable yasnippet for all backends.")

  (defun company-mode/backend-with-yas (backend)
    (if (or (not company-mode/enable-yas)
            (and (listp backend)
                 (member 'company-yasnippet backend)))
        backend
      (append (if (consp backend) backend (list backend))
              '(:with company-yasnippet))))

  (setq company-backends
        (mapcar #'company-mode/backend-with-yas
                '((company-capf company-shell company-dabbrev company-abbrev
                                company-files company-etags company-keywords)))
        company-idle-delay 1.0
        company-tooltip-flip-when-above t)
  (use-package company-flx :defer t
    :ensure t
    :config (with-eval-after-load 'company
              (company-flx-mode +1)))
  (use-package company-ycmd :defer t
    :ensure t
    :config (company-ycmd-setup))
  (use-package company-shell :defer t
    :ensure t))

;;
;; END IDE-like autocomplete.
;;


;;
;; Syntax highlithing
;;
(use-package yaml-mode
  :ensure t)
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
(add-hook 'yaml-mode-hook
	  '(lambda ()
             (define-key yaml-mode-map "\C-m" 'newline-and-indent)))
(use-package pythonic
  :ensure pythonic)
(use-package anaconda-mode
  :ensure anaconda-mode)
(use-package company-anaconda
  :ensure company-anaconda)
(use-package py-autopep8
  :ensure t)
(use-package flycheck
  :ensure t)
(use-package flymake
  :ensure t)
(use-package elpy
  :ensure t
  :config (elpy-enable))
(setq elpy-company-add-completion-from-shell t)


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
(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:complete-on-dot t)


;; (defun show-fly-err-at-point ()
;;   "If the cursor is sitting on a flymake error, display the message in the minibuffer"
;;   (require 'cl)
;;   (interactive)
;;   (let ((line-no (line-number-at-pos)))
;;     (dolist (elem flymake-err-info)
;;       (if (eq (car elem) line-no)
;;       (let ((err (car (second elem))))
;;         (message "%s" (flymake-ler-text err)))))))

(add-hook 'python-mode-hook '(lambda () (define-key python-mode-map "\C-cn" 'flymake-goto-next-error)))
(add-hook 'python-mode-hook '(lambda () (define-key python-mode-map "\C-cp" 'flymake-goto-prev-error)))
;;(add-hook 'post-command-hook 'show-fly-err-at-point)

;;
;; Remote machine editor
;;
(use-package docker-tramp
  :ensure docker-tramp)
(use-package tramp
  :ensure t
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
(use-package docker-compose-mode
  :ensure t)


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
  :ensure t
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
    (setq projectile-switch-project-action 'neotree-projectile-action)
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


;;;
;;; Git configuration in emacs
;;;
(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)))
(use-package diff-hl
  :ensure t
  :config
  (global-diff-hl-mode +1)
  (add-hook 'dired-mode-hook 'diff-hl-dired-mode)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh))
