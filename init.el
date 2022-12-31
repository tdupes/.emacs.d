(setq gc-cons-threshold 64000000)
(add-hook 'after-init-hook #'(lambda ()
                               ;; restore after startup
                               (setq gc-cons-threshold 800000)))

(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (when no-ssl
    (warn "\
Your version of Emacs does not support SSL connections,
which is unsafe because it allows man-in-the-middle attacks.
nnnnnnThere are two things you can do about this warning:
1. Install an Emacs version that does support SSL and be safe.
2. Remove this warning from your init file so you won't see it again."))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives (cons "gnu" (concat proto "://elpa.gnu.org/packages/")))))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(set-frame-font "Roboto Mono-14")
(show-paren-mode 1)
(electric-pair-mode 1)
(global-hl-line-mode +1)        ; highlight current line
(global-auto-revert-mode 1)
(put 'erase-buffer 'disabled nil) ;; enable the erase-buffer function
(global-linum-mode)
(setq column-numbder-mode t)
;; Always ask for y/n, never yes/no.
(defalias 'yes-or-no-p 'y-or-n-p)
;; Persistent desktops (which buffers are open)
(setq desktop-save t) ;; always save

(defun kill-line-or-region () 
 "kill region if active only or kill line normally"
  (interactive)
  (if (region-active-p)
      (call-interactively 'kill-region)
    (call-interactively 'kill-line)))
(global-set-key (kbd "C-k") 'kill-line-or-region)
(global-set-key (kbd "C-w") 'backward-kill-word)
(require 'server)
(if (not (server-running-p))
    (server-start))


;; Don’t ask to save files before compilation, just save them.
(setq compilation-ask-about-save nil)

;; Don’t ask to kill currently running compilation, just kill it.
(setq compilation-always-kill t)

;; recent file mode
(use-package recentf
  :bind ("\C-x\ \C-r" . recentf-open-files)
  :config 
  (recentf-mode 1)
  (setq recentf-max-menu-items 100)
  (setq recentf-max-saved-items 100))
(global-set-key "\C-x\ \C-r" 'recentf-open-files)
(setq inhibit-startup-message t)
(require 'use-package)

(use-package company
  :ensure t
  :init (global-company-mode))

(use-package eglot
  :ensure t)

(use-package haskell-mode
  :defer
  :ensure t)

(use-package which-key
  :ensure t
  :init (progn (which-key-mode)
	       (setq which-key-idle-delay 0.01)
	       (setq which-key-idle-secondary-delay 0.01)))

(use-package yasnippet
  :ensure t
  :init (yas-global-mode 1))
(use-package yasnippet-snippets
  :ensure t
  :init (yas-reload-all))

(use-package magit
  :ensure t
  :defer t
 :bind (("C-x g" . magit-status))
  )

;; highlight unmatched parens
(use-package rainbow-delimiters
  :config (add-hook 'prog-mode-hook 'rainbow-delimiters-mode)
  :ensure t)

(use-package multiple-cursors
  :ensure t
  :defer t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))
(use-package expand-region :ensure t
  :defer t
  :bind ("C-=" . er/expand-region)
  ("C-c =" . er/expand-region))         ; for terminal

(use-package flyspell :ensure t)

(use-package latex
    :defer t
    :config
    (use-package preview)
    (add-hook 'LaTeX-mode-hook 'reftex-mode))

(use-package go-mode
  :defer t
  :ensure t
  :bind (:map go-mode-map ("M-." . godef-jump)))

(use-package dired
  :init (progn
          (setq dired-listing-switches "-alh")
          (put 'dired-find-alternate-file 'disabled nil))
  :bind (:map dired-mode-map
              ("C-x w" . wdired-change-to-wdired-mode)))

(defun go-to-config (arg)
  (interactive "p")
  (find-file user-init-file))

(fido-mode)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :extend nil :stipple nil :background "white" :foreground "black" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight regular :height 143 :width normal :foundry "GOOG" :family "Roboto Mono"))))
 '(font-lock-comment-face ((t (:foreground "#a31515"))))
 '(font-lock-function-name-face ((t (:foreground "black"))))
 '(font-lock-keyword-face ((t (:foreground "black" :weight bold))))
 '(font-lock-string-face ((t (:foreground "green"))))
 '(font-lock-type-face ((t (:foreground "black")))))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(magit which-key yasnippet-snippets yaml-mode use-package tree-sitter rust-mode multiple-cursors markdown-mode haskell-mode expand-region eglot company)))
