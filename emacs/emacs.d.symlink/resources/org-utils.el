  ;;--------------------------
  ;; Handling file properties for ‘CREATED’ & ‘LAST_MODIFIED’
  ;;--------------------------

  (defun zp/org-find-time-file-property (property &optional anywhere)
    "Return the position of the time file PROPERTY if it exists.
When ANYWHERE is non-nil, search beyond the preamble."
    (save-excursion
      (goto-char (point-min))
      (let ((first-heading
             (save-excursion
               (re-search-forward org-outline-regexp-bol nil t))))
        (when (re-search-forward (format "^#\\+%s:" property)
                                 (if anywhere nil first-heading)
                                 t)
          (point)))))

  (defun zp/org-has-time-file-property-p (property &optional anywhere)
    "Return the position of time file PROPERTY if it is defined.
As a special case, return -1 if the time file PROPERTY exists but
is not defined."
    (when-let ((pos (zp/org-find-time-file-property property anywhere)))
      (save-excursion
        (goto-char pos)
        (if (and (looking-at-p " ")
                 (progn (forward-char)
                        (org-at-timestamp-p 'lax)))
            pos
          -1))))

  (defun zp/org-set-time-file-property (property &optional anywhere pos)
    "Set the time file PROPERTY in the preamble.
When ANYWHERE is non-nil, search beyond the preamble.
If the position of the file PROPERTY has already been computed,
it can be passed in POS."
    (when-let ((pos (or pos
                        (zp/org-find-time-file-property property))))
      (save-excursion
        (goto-char pos)
        (if (looking-at-p " ")
            (forward-char)
          (insert " "))
        (delete-region (point) (line-end-position))
        (let* ((now (format-time-string "[%Y-%m-%d %a %H:%M]")))
          (insert now)))))

  (defun zp/org-set-last-modified ()
    "Update the LAST_MODIFIED file property in the preamble."
    (when (derived-mode-p 'org-mode)
      (zp/org-set-time-file-property "LAST_MODIFIED")))
