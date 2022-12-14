;; This buffer is for text that is not saved, and for Lisp evaluation.
;; To create a file, visit it with C-x C-f and enter text in its buffer.

;;; auto-resize.el --- automatically maximize font size  -*- lexical-binding: t -*-

(defvar auto-resize-scale-step 1.05)

(defun resize-buffer-to-fit (&rest _ignored)
  (interactive)
  (when (and auto-resize-mode
             (eq (current-buffer) (window-buffer (selected-window))))
    (let ((inhibit-redisplay t)
          (fw (- (frame-pixel-width)
                 (cond ((consp fringe-mode) (+ (car fringe-mode) (cdr fringe-mode)))
                       ((numberp fringe-mode) (* 2 fringe-mode))
                       (t 0))))
          (fh (frame-pixel-height))
          (cols 0) (rows 0) (scale 0))
      (setq-local text-scale-mode-step auto-resize-scale-step)
      (save-excursion
        (goto-char (point-min))
        (while (zerop (forward-line 1))
          (setq cols (max cols (if (bolp)
                                 (prog2 (goto-char (1- (point)))
                                     (current-column)
                                   (goto-char (1+ (point))))
                                 (current-column)))
                rows (1+ rows)))
        (when (bolp) (setq rows (1+ rows))))
      (with-temp-buffer
        (switch-to-buffer (current-buffer))
        (setq-local buffer-undo-list t truncate-lines t)
        (insert (make-string rows ?\n) (make-string cols ?x) ?x)
        (setq-local text-scale-mode-step auto-resize-scale-step)
        (text-scale-mode 1)
        (goto-char (point-min))
        (let (p (m (point-max)))
          (while (and (setq p (posn-x-y (posn-at-point m)))
                      (> (car p) 0) (<= (car p) fw) (<= (cdr p) fh))
            (setq scale (1+ scale)
                  text-scale-mode-amount scale)
            (text-scale-mode 1)))
        (setq scale (max 0 (1- scale))))
      (setq text-scale-mode-amount scale)
      (text-scale-mode (if (zerop scale) -1 1))
      (save-excursion (goto-char (point-min)) (recenter 0 t)))))

(define-minor-mode auto-resize-mode
  "Continuously maximize font size."
  :lighter " Resizing"
  (if auto-resize-mode
    (progn
      (resize-buffer-to-fit)
      (add-hook 'after-change-functions 'resize-buffer-to-fit t t)
      (setq-local window-size-change-functions
                  (cons 'resize-buffer-to-fit window-size-change-functions)))
    (progn
      (remove-hook 'after-change-functions 'resize-buffer-to-fit t)
      (setq-local window-size-change-functions
                  (remq 'resize-buffer-to-fit window-size-change-functions)))))

;; (define-keys 'global '("C-`" auto-resize-mode))

(provide 'auto-resize)

;;; auto-resize.el ends here

