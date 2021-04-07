;; https://stackoverflow.com/questions/14670371/how-to-process-a-series-of-files-with-elisp

(defun my/process-file (f)
  (message "processing %s" f)
  ;; (find-file f)
  ;; (with-current-buffer
  ;; (switch-to-buffer f)
  (with-current-buffer (find-file-noselect f)
    ;; (call-interactively 'org-mode)
    ;; (mark-whole-buffer)
    (goto-char (point-max))
    (org-fill-paragraph)
    ;; (call-interactively 'org-fill-paragraph)
    (while (= (org-backward-paragraph) 0)
      (org-fill-paragraph))
    ;; (org-fill-paragraph nil t)
    ;; (write-file f)
    (save-buffer)
    ;; (kill-buffer (current-buffer))
    ))

(defun my/process-files (dir)
  (mapc 'my/process-file
        (directory-files-recursively dir ".org$")))


(defun my/open-files (dir)
  (mapc 'find-file
        (directory-files-recursively dir ".org$")))

(my/process-files default-directory)
(message "done")

(my/open-files default-directory)
(message "done")

(defun org-fill-element (&optional justify)
  "Fill element at point, when applicable.

This function only applies to comment blocks, comments, example
blocks and paragraphs.  Also, as a special case, re-align table
when point is at one.

If JUSTIFY is non-nil (interactively, with prefix argument),
justify as well.  If `sentence-end-double-space' is non-nil, then
period followed by one space does not end a sentence, so don't
break a line there.  The variable `fill-column' controls the
width for filling.

For convenience, when point is at a plain list, an item or
a footnote definition, try to fill the first paragraph within."
  (with-syntax-table org-mode-transpose-word-syntax-table
    ;; Move to end of line in order to get the first paragraph within
    ;; a plain list or a footnote definition.
    (let ((element (save-excursion (end-of-line) (org-element-at-point))))
      ;; First check if point is in a blank line at the beginning of
      ;; the buffer.  In that case, ignore filling.
      (cl-case (org-element-type element)
        ;; Use major mode filling function is source blocks.
        ;; (src-block (org-babel-do-key-sequence-in-edit-buffer (kbd "M-q")))
        ;; Align Org tables, leave table.el tables as-is.
        ;; (table-row (org-table-align) t)
        ;; (table
        ;;  (when (eq (org-element-property :type element) 'org)
        ;;    (save-excursion
        ;;      (goto-char (org-element-property :post-affiliated element))
        ;;      (org-table-align)))
        ;;  t)
        (paragraph
         ;; Paragraphs may contain `line-break' type objects.
         (let ((beg (max (point-min)
                         (org-element-property :contents-begin element)))
               (end (min (point-max)
                         (org-element-property :contents-end element))))
           ;; Do nothing if point is at an affiliated keyword.
           (if (< (line-end-position) beg) t
             ;; Fill paragraph, taking line breaks into account.
             (save-excursion
               (goto-char beg)
               (let ((cuts (list beg)))
                 (while (re-search-forward "\\\\\\\\[ \t]*\n" end t)
                   (when (eq 'line-break
                             (org-element-type
                              (save-excursion (backward-char)
                                              (org-element-context))))
                     (push (point) cuts)))
                 (dolist (c (delq end cuts))
                   (fill-region-as-paragraph c end justify)
                   (setq end c))))
             t)))
        ;; Contents of `comment-block' type elements should be
        ;; filled as plain text, but only if point is within block
        ;; markers.
        ;; (comment-block
        ;;  (let* ((case-fold-search t)
        ;;         (beg (save-excursion
        ;;                (goto-char (org-element-property :begin element))
        ;;                (re-search-forward "^[ \t]*#\\+begin_comment" nil t)
        ;;                (forward-line)
        ;;                (point)))
        ;;         (end (save-excursion
        ;;                (goto-char (org-element-property :end element))
        ;;                (re-search-backward "^[ \t]*#\\+end_comment" nil t)
        ;;                (line-beginning-position))))
        ;;    (if (or (< (point) beg) (> (point) end)) t
        ;;      (fill-region-as-paragraph
        ;;       (save-excursion (end-of-line)
        ;;                       (re-search-backward "^[ \t]*$" beg 'move)
        ;;                       (line-beginning-position))
        ;;       (save-excursion (beginning-of-line)
        ;;                       (re-search-forward "^[ \t]*$" end 'move)
        ;;                       (line-beginning-position))
        ;;       justify))))
        ;; Fill comments.
        ;; (comment
        ;;  (let ((begin (org-element-property :post-affiliated element))
        ;;        (end (org-element-property :end element)))
        ;;    (when (and (>= (point) begin) (<= (point) end))
        ;;      (let ((begin (save-excursion
        ;;                     (end-of-line)
        ;;                     (if (re-search-backward "^[ \t]*#[ \t]*$" begin t)
        ;;                         (progn (forward-line) (point))
        ;;                       begin)))
        ;;            (end (save-excursion
        ;;                   (end-of-line)
        ;;                   (if (re-search-forward "^[ \t]*#[ \t]*$" end 'move)
        ;;                       (1- (line-beginning-position))
        ;;                     (skip-chars-backward " \r\t\n")
        ;;                     (line-end-position)))))
        ;;        ;; Do not fill comments when at a blank line.
        ;;        (when (> end begin)
        ;;          (let ((fill-prefix
        ;;                 (save-excursion
        ;;                   (beginning-of-line)
        ;;                   (looking-at "[ \t]*#")
        ;;                   (let ((comment-prefix (match-string 0)))
        ;;                     (goto-char (match-end 0))
        ;;                     (if (looking-at adaptive-fill-regexp)
        ;;                         (concat comment-prefix (match-string 0))
        ;;                       (concat comment-prefix " "))))))
        ;;            (save-excursion
        ;;              (fill-region-as-paragraph begin end justify))))))
        ;;    t))
        ;; Ignore every other element.
        (otherwise t)))))

;; (get-buffer-create "/home/thanh/git/clojure-site-org/reference/namespaces.org")
(my/process-file "/home/thanh/git/clojure-site-org/reference/namespaces.org")
(my/process-file "/home/thanh/git/clojure-site-org/guides/spec.org")
