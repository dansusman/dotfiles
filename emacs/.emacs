;;; .emacs start file               -*- lexical-binding: t -*-

(setq max-lisp-eval-depth 10000)
(setq max-specpdl-size 10000)
(require 'package)
(load "~/.emacs.rc/rc.el")

(setq package-enable-at-startup nil)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives
 	         '("gnu" . "https://elpa.gnu.org/packages/"))
(add-to-list 'load-path "$DIR")
(load "/Users/danielsusman/.opam/default/share/emacs/site-lisp/tuareg-site-file")
(package-initialize)

;; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(org-babel-load-file (expand-file-name "~/.dotfiles/emacs/init.org"))

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
   '(merlin-ac merlin-company merlin tuareg isearch iedit yasnippet-snippets general expand-region evil yasnippet company editorconfig multiple-cursors racket-mode go-mode magit rust-mode markdown-mode gruber-darker-theme smex)))

(put 'narrow-to-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
;; ## added by OPAM user-setup for emacs / base ## 56ab50dc8996d2bb95e7856a6eddb17b ## you can edit, but keep this line
(require 'opam-user-setup "~/.emacs.d/opam-user-setup.el")
;; ## end of OPAM user-setup addition for emacs / base ## keep this line
