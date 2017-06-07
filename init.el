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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; el-get ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

(add-to-list 'el-get-recipe-path "~/.emacs.d/el-get-recipes/")

;; set local recipes, el-get-sources should only accept PLIST element
(setq
 el-get-sources
 '((:name yasnippet ;; cool snippet library for emacs
          :after
          (progn
            (yas-global-mode 1)
            (add-hook 'prog-mode-hook #'yas-minor-mode)
            (setq yas-snippet-dirs
                  (append yas-snippet-dirs
                          '("~/.emacs.d/my-snippets")))
            (defun yas/org-very-safe-expand ()
              (let
                  ((yas/fallback-behavior 'return-nil))
                (yas/expand)))
            (global-set-key (kbd "C-M-y") 'yas-expand)
            (yas-reload-all)))
   (:name magit
          :after
          (progn
            (require 'magit)
            (global-set-key (kbd "C-x C-z") 'magit-status)))
   ;; code completion library
   (:name company-mode
          :after
          (progn
            (global-company-mode)))
   (:name flycheck ; general error reporting library
          :after
          (progn
            (global-flycheck-mode)
            (defun nextError ()
              "universal error navigation, this goes to
                      the next error in the buffer"
              (interactive)
              (cond
               ((bound-and-true-p flycheck-mode)
                (flycheck-next-error))

               ((bound-and-true-p flyspell-mode)
                (flyspell-goto-next-error))

               ((bound-and-true-p eclim-mode)
                (eclim-problems-next-same-window))

               ((bound-and-true-p flymake-mode)
                (flymake-goto-next-error))))

            (defun prevError ()
              (interactive)
              (cond
               ((bound-and-true-p eclim-mode)
                (eclim-problems-previous-same-window))

               ((bound-and-true-p flycheck-mode)
                (flycheck-previous-error))

               ((bound-and-true-p flyspell-mode)
                (flyspell-goto-previous-error (point)))

               ((bound-and-true-p flymake-mode)
                (flymake-goto-prev-error))))

            (require 'flymake)
            (global-set-key (kbd "M-n") 'nextError)
            (global-set-key (kbd "M-p") 'prevError)))
   (:name projectile
          :after
          (progn
            (projectile-global-mode)
            (setq projectile-enable-caching t)
            (setq projectile-mode-line
                  '(:eval
                    (if (file-remote-p default-directory)
                        " Projectile"
                      (format " P[%s]"
                              (projectile-project-name)))))
            (setq projectile-switch-project-action 'projectile-dired)))
   (:name multi-term ;; better version for running terminals in emacs
          :after
          (progn
            (setq multi-term-program "/bin/bash")
            (global-set-key [(f10)] 'multi-term)
            (setq multi-term-program "/bin/bash")
            (setq explicit-shell-file-name "/bin/bash")
            (setq term-buffer-maximum-size 10000)
            (add-hook 'term-mode-hook
                      (lambda ()
                        (setq yas-dont-activate t)
                        (setq term-buffer-maximum-size 10000)
                        (setq show-trailing-whitespace nil)
                        ;; better pasting in terminal
                        (define-key term-raw-map (kbd "C-y")
                          'term-paste)
                        (define-key term-raw-map (kbd "C-c C-l")
                          'erase-buffer)))
            (define-key term-mode-map (kbd "C-c M-o") 'comint-clear-buffer)
            (define-key term-raw-map (kbd "C-c M-o") 'comint-clear-buffer)
            (add-to-list 'term-bind-key-alist
                         '("M-d" . term-send-forward-kill-word))
            (add-to-list 'term-bind-key-alist
                         '("<escape>" . term-send-esc))
            (add-to-list 'term-bind-key-alist
                         '("<C-backspace>" .
                           term-send-backward-kill-word))
            (add-to-list 'term-bind-key-alist
                         '("<M-backspace>" .
                           term-send-backward-kill-word))
            (add-to-list 'term-bind-key-alist
                         '("M-[" . multi-term-prev))
            (add-to-list 'term-bind-key-alist
                         '("M-]" . multi-term-next))))
   (:name dash) ;; elisp library
   (:name ggtags
          :after
          (add-hook 'c-mode-common-hook
                    (lambda ()
                      (when (derived-mode-p 'c-mode 'c++-mode 'java-mode)
                        (ggtags-mode 1)))))
   (:name clang-format
          :after
          (progn
            (add-hook 'c++-mode-hook
                      (lambda ()
                        (define-key c++-mode-map (kbd "C-M-q")
                          'clang-format-region)))

            (add-hook 'c-mode-hook
                      (lambda ()
                        (define-key c-mode-map (kbd "C-M-q")
                          'clang-format-region)))))
   (:name doxymacs
          :after
          (add-hook 'c-mode-common-hook
                    (lambda ()
                      (require 'doxymacs)
                      (doxymacs-mode t)
                      (doxymacs-font-lock))))
   (:name paredit
          :after
          (progn
            (autoload 'enable-paredit-mode "paredit"
              "Turn on pseudo-structural editing of Lisp code." t)
            (add-hook 'emacs-lisp-mode-hook #'enable-paredit-mode)
            (add-hook 'eval-expression-minibuffer-setup-hook
                      #'enable-paredit-mode)
            (add-hook 'ielm-mode-hook             #'enable-paredit-mode)
            (add-hook 'lisp-mode-hook             #'enable-paredit-mode)
            (add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
            (add-hook 'scheme-mode-hook           #'enable-paredit-mode)))
   (:name flx
          :after
          (progn
            (require 'flx-ido)
            (ido-mode 1)
            (ido-everywhere 1)
            (flx-ido-mode 1)
            ;; disable ido faces to see flx highlights.
            (setq ido-enable-flex-matching t)
            (setq ido-use-faces nil)))
   (:name smex
          :after
          (global-set-key (kbd "M-x") 'smex))
   (:name popup) ;; required by eclim
   (:name eclim
          :after
          (progn
            (setq eclim-executable "/opt/eclipse/eclim")
            (setq eclim-eclipse-dirs "/opt/eclipse")
            (add-to-list 'load-path "~/.emacs.d/lisp/emacs-eclim")
            (require 'eclim)
            (require 'eclimd)
            (setq help-at-pt-display-when-idle t)
            (setq help-at-pt-timer-delay 0.1)
            (help-at-pt-set-timer)
            (require 'company-emacs-eclim)
            (company-emacs-eclim-setup)

            (add-hook 'java-mode-hook
                      (lambda ()
                        (define-key java-mode-map (kbd "<M-tab>")
                          'company-complete-common)
                        (define-key java-mode-map (kbd "C-c C-f")
                          'eclim-java-find-declaration)
                        (define-key java-mode-map (kbd "C-c C-r")
                          'eclim-java-find-references)))

            (add-hook 'java-mode-hook
                      (lambda ()
                        (eclim-mode)))
            (add-hook 'scala-mode-hook
                      (lambda ()
                        (scala-mode-feature-electric-mode)
                        (eclim-mode)))))
   (:name haskell-mode
          :after
          (progn
            (require 'haskell-mode)
            ;; Make Emacs look in Cabal directory for binaries
            (let ((my-cabal-path (expand-file-name "~/.cabal/bin")))
              (setenv "PATH" (concat my-cabal-path ":" (getenv "PATH")))
              (add-to-list 'exec-path my-cabal-path))

            ;; Use haskell-mode indentation
            (add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
            (add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)

            (add-hook 'haskell-cabal-mode 'turn-on-haskell-indentation)
            ;; Add F8 key combination for going to imports block
            (eval-after-load 'haskell-mode
              '(define-key haskell-mode-map [f8]
                 'haskell-navigate-imports))

            (eval-after-load 'haskell-mode
              '(progn
                 ;; (define-key haskell-mode-map (kbd "C-c C-l")
                 ;; 'haskell-process-load-or-reload)
                 (define-key haskell-mode-map (kbd "C-c C-l")
                   'haskell-process-load-file)
                 (define-key haskell-mode-map (kbd "C-c C-z")
                   'haskell-interactive-switch)
                 (define-key haskell-mode-map (kbd "SPC")
                   'haskell-mode-contextual-space)))
            ;;pretty symbols for emacs
            (setq haskell-font-lock-symbols t)))
   (:name ghc-mod
          :after
          (progn
            (require 'ghc)
            (autoload 'ghc-init "ghc" nil t)
            (autoload 'ghc-debug "ghc" nil t)
            (add-hook 'haskell-mode-hook 'ghc-init)
            (setq ghc-debug t)))
   (:name company-ghc
          :after
          (add-to-list 'company-backends 'company-ghc))
   (:name sml-mode)
   (:name web-mode
          :after
          (progn
            (add-to-list 'auto-mode-alist '("\\.html$" . web-mode))
            (add-to-list 'auto-mode-alist '("\\.ssp$" . web-mode))
            (add-to-list 'auto-mode-alist '("\\.jsp$" . web-mode))
            (add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
            (add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
            (add-to-list 'auto-mode-alist '("\\.php$\\'" . web-mode))
            (add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
            (add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
            (add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
            (add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
            (add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
            (add-to-list 'auto-mode-alist '("\\.jsp$" . web-mode))
            (setq web-mode-enable-current-element-highlight t)
            (setq javascript-i4de4t-level 4) ; javascript-mode
            (setq js-i4de4t-level 4) ; js-mode
            (setq web-mode-markup-i4de4t-offset 4)
            (setq web-mode-css-i4de4t-offset 4)
            (setq web-mode-code-i4de4t-offset 4)
            (setq css-i4de4t-offset 4)))
   (:name company-web
          :after
          (add-to-list 'company-backends 'company-web-html))
   (:name web-completion-data)
   (:name tern    ;; Javascript code completiong and error checking.
          :after
          (progn
            (add-hook 'js-mode-hook (lambda () (tern-mode t)))
            (defun delete-tern-process ()
              "Function to stop tern."
              (interactive)
              (delete-process "Tern"))
            (add-to-list 'company-backends 'company-tern)))
   (:name nodejs-repl) ;; javascript repl
   (:name jshint-mode) ;; error reporting for js
   (:name elpy
          :after
          (progn
            ;; following fixes weird bug with elpy and completion in emcas 25.
            (add-hook
             'python-mode-hooke
             (lambda()
               (defun python-shell-completion-native-try ()
                 "Return non-nil if can trigger native completion."
                 (with-eval-after-load 'python
                   '(let ((python-shell-completion-native-enable t)
                          (python-shell-completion-native-output-timeout
                           python-shell-completion-native-try-output-timeout))
                      (python-shell-completion-native-get-completions
                       (get-buffer-process (current-buffer))
                       nil "_"))))))
            (add-hook 'python-mode-hooke 'elpy-enable)))
   (:name avy) ;; package to jump to next letter or line
   (:name multiple-cursors)
   (:name expand-region)
   (:name flyspell)
   ;; highlight unmatched parens
   (:name rainbow-delimiters
          :after (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))
   (:name markdown-mode)
   ;; better system for viewing pdf files
   (:name pdf-tools :after
          (progn
            (add-hook 'doc-view-mode-hook
                      (lambda ()
                        (unless (bound-and-true-p pdf-is-installed-p)
                          (progn
                            (pdf-tools-install)
                            (setq pdf-is-installed-p t)))))))
   (:name ledger-mode
          :after (progn
                   (eval-after-load 'ledger-mode
                     '(define-key ledger-mode-map (kbd "C-M-i")
                        'complete-symbol))))
   (:name auctex
          :after
          (progn
            (require 'tex)
            (TeX-global-PDF-mode t)
            (setq TeX-auto-save t)
            (setq TeX-parse-self t)
            (setq TeX-save-query nil)
            (setq TeX-PDF-mode t)))
   (:name company-auctex
          :after (progn
                   (require 'company-auctex)
                   (company-auctex-init)))
   (:name org-pomodoro
          :after
          (setq org-pomodoro-audio-player (executable-find "paplay")))
   (:name calfw
          :after (progn
                   (require 'calfw-cal)
                   (require 'calfw-org)
                   (setq cfw:org-agenda-schedule-args nil)
                   (defun my-open-calendar ()
                     (interactive)
                     (cfw:open-calendar-buffer
                      :contents-sources
                      (list
                       (cfw:org-create-source))
                      :annotation-sources
                      (list
                       (cfw:org-create-source))))))
   (:name org-gcal
          :after (progn
                   (require 'org-gcal)
                   (load-file "~/.org-gcal.el")
                   (define-key org-mode-map (kbd "C-c C-x C-SPC")
                     'org-gcal-post-at-point)
                   (add-hook 'org-agenda-mode-hook (lambda () (org-gcal-sync)))
                   (add-hook
                    'org-capture-after-finalize-hook
                    (lambda () (org-gcal-sync)))))

   (:name bbdb ;; contacts database for gnus
          :after (progn
                   (require 'bbdb)
                   (bbdb-initialize 'gnus 'message)
                   (bbdb-mua-auto-update-init 'message)
                   (setq bbdb-north-american-phone-numbers-p nil)
                   (setq bbdb-complete-name-full-completion t)
                   (setq bbdb-message-all-addresses t)
                   (setq bbdb-file "~/private-dotfiles/email/bbdb")
                   (bbdb-insinuate-message)
                   (add-hook 'gnus-startup-hook 'bbdb-insinuate-gnus)
                   (add-hook 'gnus-summary-mode-hook
                             (lambda ()
                               (define-key gnus-summary-mode-map (kbd ";")
                                 'bbdb-mua-edit-field)))
                   (setq bbdb-use-pop-up nil)
                   (setq bbdb/gnus-score-default 5)
                   (setq gnus-score-find-score-files-function
                         '(gnus-score-find-bnews bbdb/gnus-score))))
   (:name emms
          :after (progn
                   (require 'emms-setup)
                   (emms-all)
                   (setq emms-setup-default-player-list
                         '(emms-player-vlc
                           emms-player-vlc-playlist
                           emms-player-mplayer-playlist
                           emms-player-mplayer))
                   (setq emms-source-file-default-directory "~/Music/")
                   (emms-add-directory-tree "~/Music/")))
   (:name neotree
          :after (setq neo-window-width 35))
   (:name solarized-emacs)
   (:name ace-window
          :after (global-set-key (kbd "C-x o") 'ace-window))
   (:name god-mode
          :after (progn
                   (global-set-key (kbd "<escape>") 'god-local-mode)
                   (defun my-update-cursor ()
                     (setq cursor-type (if (or god-local-mode buffer-read-only)
                                           'hollow
                                         'box)))

                   (add-hook 'god-mode-enabled-hook 'my-update-cursor)
                   (add-hook 'god-mode-disabled-hook 'my-update-cursor)))))

;; bootstrap el-get with el-get
(setq my-el-get-packages '(el-get))
(setq my-el-get-packages
      (append my-el-get-packages
              (mapcar #'el-get-source-name el-get-sources)))
(el-get 'sync my-el-get-packages)
(package-initialize) ;; init package.el

;; extra lisp code should be in lisp directory of .emacs.d
(add-to-list 'load-path "~/.emacs.d/lisp")

;; For packages not available through el-get but package.el for some reason.
(defvar prelude-packages
  '(ido-vertical-mode doom)
  "A list of packages to ensure are installed at launch.")

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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;; Global modes and key bindings ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-flycheck-mode)
(global-company-mode)
(global-company-mode)
(yas-global-mode 1)
(add-hook 'prog-mode-hook #'yas-minor-mode)
(global-set-key (kbd "C-=") 'er/expand-region)
(avy-setup-default)
(global-set-key (kbd "C-:") 'avy-goto-char)
(global-set-key (kbd "C-'") 'avy-goto-char-2)
(global-set-key (kbd "M-g f") 'avy-goto-line)
(global-set-key (kbd "M-g e") 'avy-goto-word-0)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)
(global-set-key (kbd "<M-tab>") 'company-complete)
(global-set-key (kbd "<C-return>") 'company-complete-common)
(global-set-key (kbd "<backtab>") 'company-complete)
(define-key global-map (kbd "C-.") 'company-files)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;; costum commands ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;unset the arrow helpers for movements cause im not a n00b
(global-unset-key (kbd "<left>"))
(global-unset-key (kbd "<right>"))
(global-unset-key (kbd "<up>"))
(global-unset-key (kbd "<down>"))

(global-set-key (kbd "<right>")   'windmove-right)
(global-set-key (kbd "<left>")    'windmove-left)
(global-set-key (kbd "<up>")      'windmove-up)
(global-set-key (kbd "<down>")    'windmove-down)

(global-set-key (kbd "C-M-l")   'windmove-right)
(global-set-key (kbd "C-M-h")    'windmove-left)
(global-set-key (kbd "C-M-k")      'windmove-up)
(global-set-key (kbd "C-M-j")    'windmove-down)

(global-set-key (kbd "<C-up>")    'shrink-window)
(global-set-key (kbd "<C-down>")  'enlarge-window)
(global-set-key (kbd "<C-left>")  'shrink-window-horizontally)
(global-set-key (kbd "<C-right>") 'enlarge-window-horizontally)

(global-set-key (kbd "C-x c")   'comment-region)
(global-set-key (kbd "C-x C")   'uncomment-region)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;elisp;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-key emacs-lisp-mode-map (kbd "C-c C-f") 'find-function)
(define-key emacs-lisp-mode-map (kbd "C-c C-e") 'eval-region)

(defun repeat-string(n str)
  (apply 'concat (make-list n str)))

(defun str-divide(len str)
  (/ len (length str)))

;; lil function to make little section titles in any language with comment
;; character
(defun create-section-title(title)
  "creates a little title section with three lines, first line of
  all comment chars, the second is the title wrapped in comment
  chars and the third is all comment chars again"
  (interactive "sEnter the title:")
  (let* ((numReptimes
          (- (str-divide 80 comment-start)
             (length comment-end)))
         (fstAndThrdLn
          (concat
           (repeat-string numReptimes comment-start) comment-end "\n"))
         (titleLineCommentRepNum
          (/ (str-divide (- 80 (length title)) comment-start)
             2))
         (titleLine
          (concat (repeat-string titleLineCommentRepNum comment-start)
                  title
                  (repeat-string (- titleLineCommentRepNum
                                   (length comment-end))
                                comment-start)
                  comment-end
                  "\n")))
    (end-of-line)
    (newline)
    (insert (concat fstAndThrdLn
                    titleLine
                    fstAndThrdLn))))

(defun end-section-title()
  "ends a section created by 'mkSectionTitle"
  (interactive)
  (let* ((numReptimes
          (- (str-divide 80 comment-start) (length comment-end)))
         (ln (concat (repeat-string numReptimes comment-start)
                     comment-end
                     "\n")))
    (end-of-line)
    (newline)
    (insert (repeat-string 3 ln))))


;;; Stefan Monnier <foo at acm.org>. It is the opposite of fill-paragraph
(defun unfill-paragraph (&optional region)
  "Take a multiple line REGION and make it into a single line of
text."
  (interactive (progn (barf-if-buffer-read-only) '(t)))
  (let ((fill-column (point-max)))
    (fill-paragraph nil region)))

;; Handy key definition
(define-key global-map "\M-Q" 'unfill-paragraph)

(defun init ()
  "Go to the init file."
  (interactive)
  (find-file user-init-file))

(global-set-key (kbd "C-c i") 'init)

(defun my-insert-space-after-point ()
  (interactive)
  (save-excursion (insert " ")))
(global-set-key (kbd "C-;") 'my-insert-space-after-point)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; aesthetics/settings ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq inhibit-startup-message t) ; get rid of the annoying start up page
(global-hl-line-mode +1)         ; highlight current line
(setq frame-title-format "emacs - %b")   ; always dispay filename as titlebar

(toggle-scroll-bar 1)
(size-indication-mode)
(unless (display-graphic-p)
  (menu-bar-mode -1)
  (tool-bar-mode -1))

(tool-bar-mode -1)
;; (set-frame-font "Ubuntu Mono" nil t)

;; use spaces instead of tabs
(setq indent-tabs-mode nil)
(setq-default indent-tabs-mode nil)

(setq-default tab-width 8)
(setq tab-width 8)
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
(add-hook 'prog-mode-hook 'subword-mode)

;; winner mode, allows undoing and redoing window configurations
(when (fboundp 'winner-mode)
  (winner-mode 1))

(setq column-number-mode 1)
(setq line-number-mode 1)

;;; Set the fill column (column number to wrap text after) to 80, not 70
(setq-default fill-column 80)

(setq confirm-kill-emacs 'y-or-n-p)     ; ask before qutting

;; recent file mode
(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-items 50)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)

(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)
(ido-vertical-mode 1)

(setq ido-vertical-define-keys 'C-n-and-C-p-only)

(set-face-attribute 'region nil :background "yellow")

(put 'erase-buffer 'disabled nil) ;; enable the erase-buffer function
(require 'server)
(if (not (server-running-p))
    (server-start))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Themes ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(show-paren-mode 1) ;; turn on paren match highlighting
(setq show-paren-style 'mixed) ;; highlight entire bracket exp

(load-file "~/.emacs.d/lisp/gruvbox-emacs/gruvbox.el")
(add-to-list 'custom-theme-load-path "~/.emacs.d/lisp/gruvbox-emacs")

(load-theme 'gruvbox-light t)
(require 'linum)
(add-hook 'prog-mode-hook 'linum-on)

;; no line numbers for doc view,
(add-hook 'doc-view-mode-hook (lambda () (linum-mode -1)))

;; always add closing brackets and parens
(electric-pair-mode 1) 

(setq default-frame-alist '((width . 100) (height . 50)
                            (font . "Ubuntu Mono")
                            (menu-bar-lines . 1)))

(setq initial-frame-alist default-frame-alist)

;;; set up unicode
(prefer-coding-system                     'utf-8)
(set-default-coding-systems               'utf-8)
(set-terminal-coding-system               'utf-8)
(set-keyboard-coding-system               'utf-8)
(setq default-buffer-file-coding-system 'utf-8)
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

;; pretty symbols
;; (global-prettify-symbols-mode -1)

(setq popup-use-optimized-column-computation nil)

;;add git to powerline
(vc-mode 1)

(defun my-term (buffer-name)
  "Start a terminal and rename buffer."
  (interactive "sbuffer name: ")
  (term "/bin/bash")
  (rename-buffer buffer-name t))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Web ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-to-list 'load-path "~/.emacs.d/lisp/web-beautify")
(require 'web-beautify) ;; Not necessary if using ELPA package
(eval-after-load 'js-mode
  '(progn
     (define-key js-mode-map (kbd "C-c w b") 'web-beautify-js)
     (define-key js-mode-map (kbd "C-c C-i") 'nodejs-repl-load-file)))

(eval-after-load 'json-mode
  '(define-key json-mode-map (kbd "C-c w b") 'web-beautify-js))
(eval-after-load 'sgml-mode
  '(progn
     (define-key sgml-mode-map (kbd "C-c w b") 'web-beautify-html)
     (define-key sgml-mode-map (kbd "C-c w b") 'web-beautify-html)
     (define-key sgml-mode-map (kbd "C-c f") 'browse-url-of-buffer)))


(eval-after-load 'css-mode
  '(define-key css-mode-map (kbd "C-c w b") 'web-beautify-css))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; git ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'git)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Spelling ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; move point to previous error
;; based on code by hatschipuh at
;; http://emacs.stackexchange.com/a/14912/2017
(defun flyspell-goto-previous-error (arg)
  "Go to arg previous spelling error."
  (interactive "p")
  (while (not (= 0 arg))
    (let ((pos (point))
          (min (point-min)))
      (if (and (eq (current-buffer) flyspell-old-buffer-error)
               (eq pos flyspell-old-pos-error))
          (progn
            (if (= flyspell-old-pos-error min)
                ;; goto beginning of buffer
                (progn
                  (message "Restarting from end of buffer")
                  (goto-char (point-max)))
              (backward-word 1))
            (setq pos (point))))
      ;; seek the next error
      (while (and (> pos min)
                  (let ((ovs (overlays-at pos))
                        (r '()))
                    (while (and (not r) (consp ovs))
                      (if (flyspell-overlay-p (car ovs))
                          (setq r t)
                        (setq ovs (cdr ovs))))
                    (not r)))
        (backward-word 1)
        (setq pos (point)))
      ;; save the current location for next invocation
      (setq arg (1- arg))
      (setq flyspell-old-pos-error pos)
      (setq flyspell-old-buffer-error (current-buffer))
      (goto-char pos)
      (if (= pos min)
          (progn
            (message "No more miss-spelled word!")
            (setq arg 0))
        (forward-word)))))

(autoload 'flyspell-mode "flyspell" "On-the-fly spelling checker." t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Latex;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun delete-latex-garbage()
  (interactive)
  (shell-command-ignore-buffer "rm *.aux")
  (shell-command-ignore-buffer "rm *.out")
  (shell-command-ignore-buffer "rm *.log"))

(defun shell-command-ignore-buffer (command)
  "Run COMMAND in shell while ignoring the buffer."
  (with-temp-buffer
    (shell-command command t)))

;; assumes you are calling this in a .tex file
(defun make-and-view-latex()
  (interactive)
  (save-excursion
    (save-buffer)
    (shell-command-ignore-buffer (concat "pdflatex " (buffer-name)))
    (delete-latex-garbage)
    (let ((pdfname
           (concat (substring (buffer-name) 0 -4) ".pdf")))
      (if (get-buffer pdfname)
          (progn
            (switch-to-buffer pdfname)
            (revert-buffer))
        (find-file pdfname)))))

(with-eval-after-load "latex"
  '(define-key LaTeX-mode-map [(f5)]
     'make-and-view-latex))

(add-hook 'LaTeX-mode-hook (lambda()
                             (turn-on-flyspell)
                             (abbrev-mode)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Org-mode ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'org)
;; global org keys
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)

(setq org-completion-use-ido t)
(setq org-catch-invisible-edits t)

(defun new-note (class-name)
  (interactive "sEnter name of Class: ")
  (let* ((file-name
          (concat (format-time-string "%Y-%m-%d")   ".org"))
         (file-full-name
          (concat "~/Documents/" class-name "/" file-name)))
    (find-file file-full-name)))

(setq org-src-fontify-natively t)
(add-hook 'org-mode-hook
          (lambda ()
            (org-set-local 'yas/trigger-key [tab])
            (define-key yas/keymap [tab] 'yas/next-field-or-maybe-expand)
            (make-variable-buffer-local 'yas/trigger-key)
            (setq yas/trigger-key [tab])
            (add-to-list 'org-tab-first-hook 'yas/org-very-safe-expand)
            (define-key yas/keymap [tab] 'yas/next-field)
            (org-indent-mode)
            (subword-mode)))

;; display links to images
(setq org-startup-with-inline-images t)

(setq org-agenda-files '("~/org/agenda.org"
                         "~/org/TODO.org"
                         "~/org/shows.org"))


(setq org-agenda-window-setup 'current-window)

(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
              (sequence "WAITING(w)" "HOLD(h)" "|" "CANCELLED(c)")
              (sequence "PHONE" "MEETING" "|" "CANCELLED(c)"))))

(setq org-todo-keyword-faces
      (quote (("TODO"      :foreground "red"     :weight bold)
              ("NEXT"      :foreground "yellow"  :weight bold)
              ("WAITING"   :foreground "magenta" :weight bold)
              ("HOLD"      :foreground "green"   :weight bold)
              ("CANCELLED" :foreground "purple"  :weight bold)
              ("MEETING"   :foreground "green"   :weight bold)
              ("PHONE"     :foreground "green"   :weight bold)
              ("DONE"      :foreground "blue"    :weight bold))))

;; highlight the cyrrent time in org agenda.
(set-face-attribute 'org-agenda-current-time nil :foreground "purple")

;; move the habit graph further right
(setq org-habit-graph-column 60)
(setq org-use-fast-todo-selection t)
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/org/TODO.org" "General")
         "* TODO %?\n  %i\n")
        ("r" "Read" entry (file+headline "~/org/TODO.org" "Read")
             "* TODO %?\n:PROPERTIES:\n:Author:\n:Platform: Book\n:Bookmark:\n:END:")
        ("j" "Journal" entry (file+datetree "~/org/journal.org")
         "* %?\nEntered on %U\n  %i\n  %a")
        ("a" "Appointment" entry (file  "~/org/agenda.org")
         "* %?\n\n%^T\n\n:PROPERTIES:\n\n:END:\n\n")))

(setq org-columns-default-format "%50ITEM(Task) %10CLOCKSUM %16TIMESTAMP_IA")
;; (setq org-columns-default-format "%50ITEM(Task) %3PRIORITY %TAGS %10CLOCKSUM %16TIMESTAMP_IA")

(define-key org-mode-map (kbd "M-p") 'flyspell-goto-previous-error)
(add-hook 'org-mode-hook (lambda()
                           (turn-on-flyspell)
                           (abbrev-mode)))
(require 'org-habit)

;;; org babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((R . t)
   (ditaa . t)
   (dot . t)
   (emacs-lisp . t)
   (gnuplot . t)
   (haskell . nil)
   (latex . t)
   (ledger . t)
   (ocaml . nil)
   (octave . t)
   (org . t)  ;; VIP!
   (python . t)
   (ruby . t)
   (screen . nil)
   (sh . t)
   (sql . nil)
   (sqlite . t)))


(defun create-random-buffer ()
  "Creates an empty buffer with random name."
  (interactive)
  (switch-to-buffer (concat "*temp-" (concat (sha1 (number-to-string (random))) "*"))))

(defun kill-save ()
  "Kill the current buffer copying the contents to clipboard."
  (interactive)
  (kill-new (buffer-string))
  (kill-buffer (current-buffer)))

(defun email-writeup ()
  "Create a quick buffer to write an email."
  (interactive)
  (progn
    (create-random-buffer)
    (org-mode)
    (auto-fill-mode)
    (local-set-key (kbd "C-c C-c") 'kill-save)))

(global-set-key (kbd "C-c e") 'email-writeup)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;; Dired Extensions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(put 'dired-find-alternate-file 'disabled nil)
(setq doc-view-resolution 300)
(setq dired-listing-switches "-alh")
(define-key dired-mode-map (kbd "C-x w") 'wdired-change-to-wdired-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;C/C++;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; make h files use c++ mode
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(add-hook 'c++-mode-hook
          (lambda ()
            (define-key c++-mode-map (kbd "C-M-x c") 'compile)))

(add-hook 'c-mode-hook
          (lambda ()
            (define-key c-mode-map (kbd "C-M-x c") 'compile)
            (setq flycheck-clang-language-standard nil)
            (setq flycheck-clang-args nil)))
(add-hook 'c++-mode-hook
          (lambda()
            (setq flycheck-clang-language-standard "c++14")
            (setq flycheck-clang-args "-std=c++14")))

;; Semantic
;; (semantic-mode t)
;; (global-semantic-idle-completions-mode t)
;; (global-semantic-decoration-mode nil)
;; (global-semantic-highlight-func-mode t)
;; (global-semantic-stickyfunc-mode t)    ; display function title on top of screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SQL stuff ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; on arch mysql is through mariadb which has an odd prompt-for-change-log-name
;; which won't show up  with current set up in sqli mode
(require 'sql)
(sql-set-product-feature 'mysql :prompt-regexp "^\\(?:mysql\\|mariadb\\).*> ")
(add-hook 'sql-interactive-mode-hook (lambda () (toggle-truncate-lines t)))
(with-eval-after-load "company"
  (add-to-list 'company-backends 'company-edbi)) ;; mysql auto complete

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; modes ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'auto-mode-alist
             '("\\.ledger$" . ledger-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; gnus ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (setq gnus-use-full-window nil)

;; three pane gnus layout
;; (gnus-add-configuration
;;  '(article
;;    (horizontal 1.0
;;                (vertical 50
;;                          (group 1.0))
;;                (vertical 1.0
;;                          (summary 0.25 point)
;;                          (article 1.0)))))
;; (gnus-add-configuration
;;  '(summary
;;    (horizontal 1.0
;;                (vertical 50
;;                          (group 1.0))
;;                (vertical 1.0
;;                          (summary 1.0 point)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ERC ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(load "~/.emacs.d/.ercrc.el")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; (add-hook 'after-init-hook (load-file "~/.cache/wal/colors.el"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; utils ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun load-doom-theme ()
  "Load doom-one theme and turn on all features."
  (interactive)
  (progn
    (require 'doom-themes)
    (require 'doom-neotree)
    (setq org-fontify-whole-heading-line t
          org-fontify-done-headline t
          org-fontify-quote-and-verse-blocks t
            doom-one-brighter-modeline t
      doom-one-brighter-comments t)
    (load-theme 'doom-one t)))

(defun swap-windows ()
  "If you have 2 windows, it swaps them." 
  (interactive)
  (cond ((not (= (count-windows) 2))
         (message "You need exactly 2 windows to do this."))
        (t
         (let* ((w1 (first (window-list)))
                (w2 (second (window-list)))
                (b1 (window-buffer w1))
                (b2 (window-buffer w2))
                (s1 (window-start w1))
                (s2 (window-start w2)))
           (set-window-buffer w1 b2)
           (set-window-buffer w2 b1)
           (set-window-start w1 s2)
           (set-window-start w2 s1)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(org-agenda-list)

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
