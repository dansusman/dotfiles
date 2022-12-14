(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(column-number-mode 1)
(show-paren-mode 1)
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)
(fset 'yes-or-no-p 'y-or-n-p)

(setq mac-pass-command-to-system nil)

(setq ring-bell-function
      (lambda ()
        (let ((orig-fg (face-foreground 'mode-line)))
          (set-face-foreground 'mode-line "#F2804F")
          (run-with-idle-timer 0.1
                               nil
                               (lambda (fg) (set-face-foreground 'mode-line fg))
                               orig-fg))))

(use-package org-bullets
  :ensure t
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(setq org-log-done 'time)
(setq org-enforce-todo-dependencies t)
(setq org-agenda-start-on-weekday nil)
(add-to-list 'org-modules 'org-tempo t)

(setq-default inhibit-splash-screen t
            make-backup-files nil
            tab-width 4
            indent-tabs-mode nil
            compilation-scroll-output t
            visible-bell (equal system-type 'windows-nt))

(use-package ido
  :ensure t)
(ido-mode 1)
(ido-everywhere 1)

;; (use-package gruber-darker
;;   :ensure t)
;; (load-theme 'gruber-darker t)

(use-package yasnippet
      :ensure t
      :init
      (yas-global-mode 1))
(setq yas/triggers-in-field nil)
(use-package yasnippet-snippets
  :ensure t)

(use-package expand-region
  :ensure t
  :config 
  (global-set-key (kbd "C-=") 'er/expand-region))

(use-package iedit
  :ensure t)

(use-package isearch
  :config
  (setq search-whitespace-regexp ".*")
  (setq isearch-lax-whitespace t)
  (setq isearch-regexp-lax-whitespace nil)
  (defun ds/isearch-mark-and-exit ()
    "Marks current search string intelligently."
    (interactive)
    (push-mark isearch-other-end t 'activate)
    (setq deactivate-mark nil)
    (isearch-done)))

(use-package hungry-delete
  :ensure t
  :config
  (global-hungry-delete-mode))

(require 'merlin-iedit)
(require 'merlin-company)

(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
;; This is your old M-x.
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

(defadvice transpose-words
    (before my/transpose-words)
  "Transpose last two words when at end of line"
  (if (looking-at "$")
      (backward-word 1)))
(ad-activate 'transpose-words)

(defun my/insert-line-below ()
  "Insert an empty line below the current line."
  (interactive)
  (save-excursion
    (end-of-line)
    (open-line 1)))

(global-set-key (kbd "M-o") 'my/insert-line-below)

(defun my/insert-line-above ()
  "Insert an empty line above the current line."
  (interactive)
  (save-excursion
    (end-of-line 0)
    (open-line 1)))

(global-set-key (kbd "M-O") 'my/insert-line-above)
