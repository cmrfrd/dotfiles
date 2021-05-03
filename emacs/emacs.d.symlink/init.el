;; Configure all package archives
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(package-initialize)
(setq package-check-signature nil)

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

;; Load packages from nixos/home-manager
(load-file "~/.emacs.d/load-path.el")

;; Load personal config and ensure no prompt per eval
(setq org-confirm-babel-evaluate nil)
(org-babel-load-file "~/.emacs.d/mainconfig.org")

;; Start daemon server
(server-start)

;; Setup tabs
(elscreen-start)
(elscreen-tab-mode)
(elscreen-tab-set-position 'top)
