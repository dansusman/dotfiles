(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
(global-set-key (kbd "C-x a") 'org-agenda)
(setq org-log-done 'time)
(setq org-enforce-todo-dependencies t)
(setq org-agenda-start-on-weekday nil)
