;;; .emacs main file               -*- lexical-binding: t -*-
(package-initialize)

(load "~/.emacs.rc/rc.el")

;; General Appearance
(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(column-number-mode 1)
(show-paren-mode 1)

;; Bell
(setq ring-bell-function
      (lambda ()
        (let ((orig-fg (face-foreground 'mode-line)))
          (set-face-foreground 'mode-line "#F2804F")
          (run-with-idle-timer 0.1 nil
                               (lambda (fg) (set-face-foreground 'mode-line fg))
                               orig-fg))))

;; Splash Screen OFF
(setq-default inhibit-splash-screen t
              make-backup-files nil
              tab-width 4
              indent-tabs-mode nil
              compilation-scroll-output t
              default-input-method "russian-computer"
              visible-bell (equal system-type 'windows-nt))

;;; ido
(rc/require 'smex 'ido-completing-read+)

(require 'ido-completing-read+)

(ido-mode 1)
(ido-everywhere 1)
(ido-ubiquitous-mode 1)

;;; Company
(rc/require 'company)
(require 'company)

(global-company-mode)

;;; yasnippet
(rc/require 'yasnippet)

(require 'yasnippet)

(setq yas/triggers-in-field nil)
(setq yas-snippet-dirs '("~/.emacs.snippets/"))

(yas-global-mode 1)

;;; editorconfig
(editorconfig-mode 1)

;;; evil-mode

;; Pre-load configuration
(setq evil-want-integration t)
(setq evil-want-keybinding nil)
(setq evil-want-C-u-scroll t)
(setq evil-want-C-i-jump nil)
(setq evil-respect-visual-line-mode t)
(setq evil-undo-system 'undo-tree)

 ;; Activate 
(evil-mode 1)

(define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
(define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

;; Use visual line motions even outside of visual-line-mode buffers
(evil-global-set-key 'motion "j" 'evil-next-visual-line)
(evil-global-set-key 'motion "k" 'evil-previous-visual-line)

(defun dw/dont-arrow-me-bro ()
    (interactive)
    (message "Arrow keys are bad, you know?"))

;; Disable arrow keys in normal and visual modes
(define-key evil-normal-state-map (kbd "<left>") 'dw/dont-arrow-me-bro)
(define-key evil-normal-state-map (kbd "<right>") 'dw/dont-arrow-me-bro)
(define-key evil-normal-state-map (kbd "<down>") 'dw/dont-arrow-me-bro)
(define-key evil-normal-state-map (kbd "<up>") 'dw/dont-arrow-me-bro)
(evil-global-set-key 'motion (kbd "<left>") 'dw/dont-arrow-me-bro)
(evil-global-set-key 'motion (kbd "<right>") 'dw/dont-arrow-me-bro)
(evil-global-set-key 'motion (kbd "<down>") 'dw/dont-arrow-me-bro)
(evil-global-set-key 'motion (kbd "<up>") 'dw/dont-arrow-me-bro)

(evil-set-initial-state 'messages-buffer-mode 'normal)
(evil-set-initial-state 'dashboard-mode 'normal)

;; Is this a bug in evil-collection?
(setq evil-collection-company-use-tng nil)

;; Font
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Iosevka Nerd Font Mono" :foundry "nil" :slant normal :weight normal :height 181 :width normal)))))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(gruber-darker))
 '(custom-safe-themes
   '("3d2e532b010eeb2f5e09c79f0b3a277bfc268ca91a59cdda7ffd056b868a03bc" default))
 '(package-selected-packages
   '(evil yasnippet company editorconfig multiple-cursors racket-mode go-mode magit rust-mode markdown-mode gruber-darker-theme smex)))

;; Remaps
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
;; This is your old M-x.
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

;; First Buffer
(dired ".")
