;; #!/bin/sh
;; ":"; exec emacs --quick --script "$0" "$@" # -*- mode: emacs-lisp; lexical-binding: t; -*-

;;; Using defcustoms in a script is kinda pointless, but what-the-hell.
(defcustom brightness-steps '(0 1 30 60 100)
  "Brightness steps (in percetage) use when increasing/decreasing."
  :type '(repeat integer)
  :group 'brightness-control)

(defcustom brightness-icon "/usr/share/icons/Faenza-Dark/status/scalable/display-brightness-symbolic.svg"
  "Icon used on the notification."
  :type 'string
  :group 'brightness)

(defun brightness-notify-level (level)
  "Send an inotify notification of brightness level."
  (shell-command
   (format
    (mapconcat #'identity
               '("notify-send"
                 "-i %s"
                 "-h int:value:%s"
                 "-h string:x-canonical-private-synchronous:brightness"
                 "Summary &")
               " ")
    brightness-icon
    level)))

(defun brightness-get-level ()
  "Get brightness percentage."
  (round (string-to-number
          (shell-command-to-string "light -G"))))

(defun brightness-set-level (level)
  "SEt brightness percentage."
  (shell-command-to-string
   (format "light -S %s &" level)))

(defun brightness-increase ()
  "Increase brightness by one step."
  (interactive)
  (let* ((level (brightness-get-level))
         (next (car (filter (lambda (x) (and (> x level) x))
                            brightness-steps))))
    (brightness-set-and-notify next)))

(defun brightness-decrease ()
  "Decrease brightness by one step."
  (interactive)
  (let* ((level (brightness-get-level))
         (next (car (reverse
                     (filter (lambda (x) (and (< x level) x))
                             brightness-steps)))))
    (brightness-set-and-notify next)))

(defun brightness-set-and-notify (level)
  "Set the brightness and tell the user."
  (when level
    (brightness-set-level level)
    (brightness-notify-level level)))

(defun filter (pred list)
  (remove nil (mapcar pred list)))

(when argv
  (let ((arg (downcase (car argv))))
    (cond
     ((string= arg "up")
      (brightness-increase))
     ((string= arg "down")
      (brightness-decrease))
     ((setq arg (ignore-errors
                  (string-to-int arg)))
      (brightness-set-and-notify arg))
     ((message "arg not recognized: %s" argv)
      (kill-emacs 1)))))

; (kill-emacs 0)
