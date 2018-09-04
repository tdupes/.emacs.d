;;; init.el ---  my emacs init config

;; Author: Thomas DuPlessis <thomasduplessis555@gmail.com>,

;;; Commentary:

;; This is an Emacs config that uses el-get for all packages.

;;; Code:


(defconst emacs-start-time (current-time))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Package Manager ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'package)

(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/"))
(when (< emacs-major-version 24)
  (add-to-list 'package-archives
               '("gnu" . "http://elpa.gnu.org/packages/")))

(package-initialize)

(defvar prelude-packages
  '( use-package)
  "A list of packages to ensure are installed at launch.")

(require 'cl)
(defun prelude-packages-installed-p ()
  (loop for p in prelude-packages
        when (not (package-installed-p p)) do (return nil)
        finally (return t)))

(unless (prelude-packages-installed-p)
  ;; check for new packages (package versions)
  (message "%s" "Emacs Prelude is now refreshing its package database...")
  (package-refresh-contents)
  (message "%s" " done.")
  ;; install the missing packages
  (dolist (p prelude-packages)
    (when (not (package-installed-p p))
      (package-install p))))

(require 'use-package)

(require 'company)
(global-set-key (kbd "<C-return>") 'company-complete-common)
(global-set-key (kbd "M-RET") 'company-complete-common) ; for terminals that don't rec c-return
(global-set-key (kbd "C-.")  'company-files)
(define-key company-active-map (kbd "C-s")  'company-select-next)
(define-key company-active-map (kbd "C-p") 'company-select-previous)
(global-company-mode)
(setq company-dabbrev-downcase nil)

(use-package magit
  :ensure t
  :defer t
  :bind ("C-x C-z" . magit-status))

(use-package yasnippet
  :ensure t
  :bind (:map yas-minor-mode-map
              ("C-M-y" . yas-expand))
  :config (progn
            (yas-global-mode 1)
            (add-hook 'prog-mode-hook #'yas-minor-mode)
            (setq yas-snippet-dirs
                  (append yas-snippet-dirs
                          '("~/.emacs.d/my-snippets")))
            (yas-reload-all)))

(use-package flycheck
  :ensure t
  :config (global-flycheck-mode))

(use-package smex
  :ensure t
  :bind ("M-x" . smex))

(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))
(use-package expand-region :ensure t
  :bind ("C-=" . er/expand-region)
  ("C-c =" . er/expand-region))         ; for terminal

(require 'flyspell)

;; highlight unmatched parens
(use-package rainbow-delimiters
  :config (add-hook 'prog-mode-hook 'rainbow-delimiters-mode)
  :ensure t)

(require 'clang-format)
(with-eval-after-load "c++-mode"
    '(progn
       (define-key c++-mode-map
         (kbd "C-M-q")  'clang-format-region)
       (define-key c++-mode-map (kbd "M-q")  'clang-format-region)))

;;; haskell
(require 'haskell-mode)
(progn
  ;; Make Emacs look in Cabal directory for binaries
  (let ((my-cabal-path (expand-file-name "~/.cabal/bin")))
    (setenv "PATH" (concat my-cabal-path ":" (getenv "PATH")))
    (add-to-list 'exec-path my-cabal-path))

  ;; Use haskell-mode indentation
  (add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
  (add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
  (add-hook 'haskell-cabal-mode 'turn-on-haskell-indentation))

(require 'ghc)
(autoload 'ghc-init "ghc" nil t)
(autoload 'ghc-debug "ghc" nil t)
(add-hook 'haskell-mode-hook 'ghc-init)
(setq ghc-debug t)

(require 'go-mode)
(define-key go-mode-map (kbd "M-.") 'godef-jump)

;; extra lisp code should be in lisp directory of .emacs.d
(add-to-list 'load-path "~/.emacs.d/lisp")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;; costum commands ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-set-key (kbd "<C-up>")    'shrink-window)
(global-set-key (kbd "<C-down>")  'enlarge-window)
(global-set-key (kbd "<C-left>")  'shrink-window-horizontally)
(global-set-key (kbd "<C-right>") 'enlarge-window-horizontally)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;elisp;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-key emacs-lisp-mode-map (kbd "C-c C-f") 'find-function)
(define-key emacs-lisp-mode-map (kbd "C-c C-e") 'eval-region)

(defun init ()
  "Go to the init file."
  (interactive)
  (if (string-match "\.elc$" user-init-file)
      (find-file (substring user-init-file 0 -1))
    (find-file user-init-file)))

(global-set-key (kbd "C-c i") 'init)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; aesthetics/settings ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq inhibit-startup-message t) ; get rid of the annoying start up page
(global-hl-line-mode +1)         ; highlight current line
(setq frame-title-format "emacs - %b")   ; always dispay filename as titlebar

(toggle-scroll-bar 1)
(size-indication-mode)

(set-frame-font "Inconsolata-15" nil t)

;; use spaces instead of tabs
(setq indent-tabs-mode nil)
(setq-default indent-tabs-mode nil)

(setq-default tab-width 4)
(setq tab-width 4)
(setq c-default-style "bsd"
      c-basic-offset 2)

(setq backup-directory-alist '(("." . "~/.emacs.d/backup"))
      backup-by-copying t    ; Don't delink hardlinks
      version-control t      ; Use version numbers on backups
      delete-old-versions t  ; Automatically delete excess backups
      kept-new-versions 20   ; how many of the newest versions to keep
      kept-old-versions 5)   ; and how many of the old

;; column length
(setq fill-column 80)

(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)

;;make emacs camel case sensitive in programming environments
;; (add-hook 'prog-mode-hook 'subword-mode)

;; winner mode, allows undoing and redoing window configurations
(when (fboundp 'winner-mode)
  (winner-mode 1))

(setq column-number-mode 1)
(setq line-number-mode 1)

;;; Set the fill column (column number to wrap text after) to 80, not 70
(setq-default fill-column 80)

;; recent file mode
(require 'recentf)
(global-set-key (kbd"\C-x\ \C-r")  'recentf-open-files)
(recentf-mode 1)
(setq recentf-max-menu-items 100)
(setq recentf-max-saved-items 100)

;; (set-face-attribute 'region nil :background "yellow")

(put 'erase-buffer 'disabled nil) ;; enable the erase-buffer function
(require 'server)
(if (not (server-running-p))
    (server-start))

(show-paren-mode 1) ;; turn on paren match highlighting

(require 'linum)
(add-hook 'prog-mode-hook 'linum-on)

;; no line numbers for doc view,
(add-hook 'doc-view-mode-hook (lambda () (linum-mode -1)))

;; always add closing brackets and parens
(electric-pair-mode 1) 

(setq default-frame-alist '((width . 85) (height . 40)
                            ;; (font . "Inconsolata-14")
                            ;; (menu-bar-lines . 1)
                            ))

(setq initial-frame-alist default-frame-alist)

;;add git to powerline
(vc-mode 1)

(defun my-term (buffer-name)
  "Start a terminal and rename buffer."
  (interactive "sbuffer name: ")
  (term "/bin/bash")
  (rename-buffer buffer-name t))


;; (add-hook 'c-mode-common-hook 'flyspell-prog-mode)

(add-hook 'LaTeX-mode-hook (lambda()
                             (turn-on-flyspell)
                             (abbrev-mode)))


;; Dired Extensions
(setq dired-listing-switches "-alh")
(put 'dired-find-alternate-file 'disabled nil)
(with-eval-after-load "dired-mode"
  '(define-key dired-mode-map (kbd "C-x w") 'wdired-change-to-wdired-mode))

;; C++
;; make h files use c++ mode
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(add-hook 'c++-mode-hook
          (lambda ()
            (define-key c++-mode-map (kbd "C-x c") 'compile)))

(add-hook 'c-mode-hook
          (lambda ()
            (define-key c-mode-map (kbd "C-x c") 'compile)
            (setq flycheck-clang-language-standard nil)
            (setq flycheck-clang-args nil)))
(add-hook 'c++-mode-hook
          (lambda()
            (setq flycheck-clang-language-standard "c++14")
            (setq flycheck-clang-args "-std=c++14")))

(which-function-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SQL stuff ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'sql)
(with-eval-after-load "company"
  (add-to-list 'company-backends 'company-edbi)) ;; mysql auto complete

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(if (file-exists-p "~/extras.el")
    (load-file "~/extras.el"))

;; print out loading time.
(when window-system
  (let ((elapsed (float-time (time-subtract (current-time)
                                            emacs-start-time))))
    (message "Loading %s...done (%.3fs)" load-file-name elapsed))

  (add-hook 'after-init-hook
            `(lambda ()
               (let ((elapsed (float-time (time-subtract (current-time)
                                                         emacs-start-time))))
                 (message "Loading %s...done (%.3fs) [after-init]"
                          ,load-file-name elapsed)))
            t))

(defalias 'yes-or-no-p 'y-or-n-p)

(defun revert-all-buffers ()
  "Revert all open buffers."
  (interactive)
  (dolist (buffer (buffer-list) (message "Refreshed open files"))
    (when (and (buffer-file-name buffer) 
               (not (buffer-modified-p buffer))) 
      (set-buffer buffer)
      (revert-buffer t t t))))
