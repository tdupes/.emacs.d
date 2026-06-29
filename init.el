;;; init.el --- Starter Emacs configuration -*- lexical-binding: t -*-

;;; ============================================================
;;; PACKAGE.EL SETUP
;;; ============================================================

(require 'package)
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/packages/")
        ("melpa"  . "https://melpa.org/packages/")))
(package-initialize)

;; Bootstrap use-package (built-in since Emacs 29; this covers 28)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)   ; auto-install packages
(setq use-package-verbose t)         ; log what's loading (remove once stable)

(setq select-enable-clipboard t
      select-enable-primary t)

(defun wslp ()
  "Return t if Emacs is running in WSL2, nil otherwise."
  (and
   ;; Check if the system is Linux
   (eq system-type 'gnu/linux)
   ;; Check for WSL-specific file
   (file-exists-p "/proc/sys/fs/binfmt_misc/WSLInterop")
   ;; Check for WSL2-specific file
   (file-exists-p "/run/WSL")
   ;; Additional check: look for Windows-style root directory
   (file-directory-p "/mnt/c")))

(when (wslp)
  ; WSLg breaks copy-paste from Emacs into Windows
  ; see: https://www.lukas-barth.net/blog/emacs-wsl-copy-clipboard/
  (setq select-active-regions nil
        select-enable-clipboard 't
        select-enable-primary nil
        interprogram-cut-function #'gui-select-text))
;;; ============================================================
;;; CORE BEHAVIOR
;;; ============================================================

(use-package emacs
  :ensure nil
  :init
  ;; Startup
  (setq inhibit-startup-screen t
        initial-scratch-message nil)

  ;; Clean UI
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (blink-cursor-mode -1)

  ;; Sane defaults
  (setq-default
   indent-tabs-mode nil
   tab-width 4
   fill-column 80
   truncate-lines t)

  (setq
   ring-bell-function 'ignore
   make-backup-files nil
   auto-save-default nil
   create-lockfiles nil
   use-short-answers t
   confirm-kill-emacs 'y-or-n-p

   ;; Scrolling
   scroll-margin 4
   scroll-conservatively 101
   scroll-preserve-screen-position t

   display-line-numbers-type t)

  ;; Line numbers + highlight in code/text
  (add-hook 'prog-mode-hook #'display-line-numbers-mode)
  (add-hook 'text-mode-hook #'display-line-numbers-mode)
  (add-hook 'prog-mode-hook #'hl-line-mode)
  (add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

  ;; Auto-pair, matching parens
  (electric-pair-mode 1)
  (show-paren-mode 1)
  (setq show-paren-delay 0)

  ;; Quality of life
  (save-place-mode 1)
  (savehist-mode 1)
  (global-auto-revert-mode 1)
  (setq auto-revert-verbose nil)
  (setq uniquify-buffer-name-style 'forward)

  ;; UTF-8
  (prefer-coding-system 'utf-8)
  (set-default-coding-systems 'utf-8))


;;; ============================================================
;;; THEME
;;; ============================================================

;; modus-themes ships with Emacs 28+, no download needed
(use-package modus-themes
  :ensure nil
  :config
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs t
        modus-themes-mixed-fonts t)
  (load-theme 'modus-operandi :no-confirm))


;;; ============================================================
;;; FONTS
;;; ============================================================

(when (display-graphic-p)
  (set-face-attribute 'default nil
                      :family "Iosevka"   ; change to your preferred monospace
                      :height 140)
  (set-face-attribute 'fixed-pitch nil
                      :family "Iosevka"
                      :height 140)
  (set-face-attribute 'variable-pitch nil
                      :family "Inter"
                      :height 140))


;;; ============================================================
;;; MINIBUFFER: Vertico + Orderless + Marginalia + Consult
;;; ============================================================

(use-package vertico
  :init (vertico-mode 1)
  :config (setq vertico-cycle t))

(use-package orderless
  :config
  (setq completion-styles '(orderless basic)
        completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :init (marginalia-mode 1))

(use-package consult
  :bind
  (("C-x b"   . consult-buffer)
   ("C-x B"   . consult-buffer-other-window)
   ("M-y"     . consult-yank-pop)
   ("M-g g"   . consult-goto-line)
   ("M-s r"   . consult-ripgrep)
   ("M-s f"   . consult-fd)
   ("M-s l"   . consult-line)
   ("M-s L"   . consult-line-multi)))


;;; ============================================================
;;; COMPLETION: Corfu (in-buffer)
;;; ============================================================

(use-package corfu
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-delay 0.2)
  (corfu-auto-prefix 2)
  (corfu-quit-no-match 'separator)
  :init (global-corfu-mode 1))

(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))


;;; ============================================================
;;; ACTIONS: Embark
;;; ============================================================

(use-package embark
  :bind
  (("C-."   . embark-act)
   ("C-;"   . embark-dwim)
   ("C-h B" . embark-bindings))
  :config
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :hook (embark-collect-mode . consult-preview-at-point-mode))


;;; ============================================================
;;; WHICH-KEY
;;; ============================================================

;; Built-in since Emacs 30; this handles 28/29
(use-package which-key
  :init (which-key-mode 1)
  :config (setq which-key-idle-delay 0.5))


;;; ============================================================
;;; GIT: Magit
;;; ============================================================

(use-package magit
  :bind ("C-c g" . magit-status))


;;; ============================================================
;;; LSP: Eglot (built-in since Emacs 29)
;;; ============================================================

(use-package eglot
  :ensure nil
  :hook
  ((python-mode
    python-ts-mode
    js-mode
    js-ts-mode
    typescript-ts-mode
    rust-ts-mode
    c-mode
    c++-mode) . eglot-ensure)
  :config
  (setq eglot-sync-connect 1
        eglot-connect-timeout 10))


;;; ============================================================
;;; TREESITTER (Emacs 29+)
;;; ============================================================

(when (treesit-available-p)
  (setq treesit-language-source-alist
        '((python     "https://github.com/tree-sitter/tree-sitter-python")
          (javascript "https://github.com/tree-sitter/tree-sitter-javascript")
          (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
          (rust       "https://github.com/tree-sitter/tree-sitter-rust")
          (c          "https://github.com/tree-sitter/tree-sitter-c")
          (cpp        "https://github.com/tree-sitter/tree-sitter-cpp")))

  (setq major-mode-remap-alist
        '((python-mode     . python-ts-mode)
          (javascript-mode . js-ts-mode)
          (c-mode          . c-ts-mode)
          (c++-mode        . c++-ts-mode))))


;;; ============================================================
;;; LANGUAGE PACKAGES
;;; ============================================================

(use-package rust-mode
  :mode "\\.rs\\'")

(use-package markdown-mode
  :mode ("\\.md\\'" "\\.markdown\\'")
  :config (setq markdown-command "pandoc"))

(use-package yaml-mode
  :mode "\\.ya?ml\\'")

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package haskell-mode
  :mode "\\.hs\\;")


;;; ============================================================
;;; WINDOW MANAGEMENT
;;; ============================================================

(use-package ace-window
  :bind ("C-x o" . ace-window)
  :config (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))3

(winner-mode 1)


;;; ============================================================
;;; DIRED
;;; ============================================================

(use-package dired
  :ensure nil
  :config
  (setq dired-listing-switches "-lah --group-directories-first"
        dired-kill-when-opening-new-dired-buffer t
        dired-dwim-target t))

(use-package dired-subtree
  :bind (:map dired-mode-map
              ("<tab>" . dired-subtree-toggle)))


;;; ============================================================
;;; MISC QUALITY-OF-LIFE
;;; ============================================================

(use-package helpful
  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key]      . helpful-key)
  ([remap describe-command]  . helpful-command))

(use-package vundo
  :bind ("C-x u" . vundo))

(use-package avy
  :bind
  ("M-j" . avy-goto-char-timer)
  ("M-J" . avy-goto-line))

(use-package project
  :ensure nil
  :bind-keymap ("C-x p" . project-prefix-map))


;;; ============================================================
;;; EAT (terminal emulator)
;;; ============================================================
(use-package eat
  :vc (:url "https://codeberg.org/akib/emacs-eat" :rev :newest)
  :bind ("C-c t" . eat)
  :config
  (setq eat-kill-buffer-on-exit t))


;;; ============================================================
;;; AGENT SHELL
;;; ============================================================

;; Prerequisites (run once in terminal):
;;   npm install -g @anthropic-ai/claude-code
;;   npm install -g @agentclientprotocol/claude-agent-acp
(use-package exec-path-from-shell
  :ensure t
  :init (exec-path-from-shell-initialize))

(use-package agent-shell
  :ensure t
  :bind ("C-c a" . agent-shell)
  :config
  ;; Use Claude subscription login (run `claude` in terminal first to authenticate)
  (setq agent-shell-anthropic-authentication
        (agent-shell-anthropic-make-authentication :login t))

  ;; Default to Claude when invoking agent-shell
  (setq agent-shell-preferred-agent-config
        (agent-shell-anthropic-make-claude-code-config))

  ;; Show context usage and busy indicator in header
  (setq agent-shell-show-context-usage-indicator t
        agent-shell-show-busy-indicator t))


;;; ============================================================
;;; CUSTOM FILE (keep this last)
;;; ============================================================

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;;; init.el ends here
