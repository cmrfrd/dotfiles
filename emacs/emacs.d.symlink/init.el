;; Load packages from nixos/home-manager
(load-file "~/.emacs.d/load-path.el")

;; Configure all package archives
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/") t)
;(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)
(package-initialize)
(setq package-check-signature nil)
(setq warning-minimum-level :emergency)

;; Native compilation in emacs
(if (and (fboundp 'native-comp-available-p)
       (native-comp-available-p))
    (progn
      (message "Native compilation is available")
      (setq comp-deferred-compilation t))
(message "Native complation is *not* available"))


;; Ensure that use-package is installed.
;;
;; If use-package isn't already installed, it's extremely likely that this is a
;; fresh installation! So we'll want to update the package repository and
;; install use-package before loading the literate configuration.
(when (not (package-installed-p 'use-package))
  (package-refresh-contents)
  (package-install 'use-package))

;; Load personal config and ensure no prompt per eval
(setq org-confirm-babel-evaluate nil)
(org-babel-load-file "~/.emacs.d/mainconfig.org" nil)

;; Start daemon server
(server-start)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(safe-local-variable-values '((org-latex-remove-logfiles))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(lsp-ui-sideline-code-action ((t (:inherit warning)))))
