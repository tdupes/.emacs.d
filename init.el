(setq inhibit-x-resources t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Package Manager;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
 '(
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ide features ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   (:name yasnippet ;; cool snippet library for emacs
          :after (progn
                   (yas-global-mode 1)
                   (add-hook 'prog-mode-hook #'yas-minor-mode)
                   (setq yas-snippet-dirs
                         (append yas-snippet-dirs
                                 '("~/.emacs.d/my-snippets")))
                   (defun yas/org-very-safe-expand ()
                     (let ((yas/fallback-behavior 'return-nil)) (yas/expand)))

                   (global-set-key (kbd "C-M-y") 'yas-expand)
                   (yas-reload-all)))


   (:name magit ;; git meet emacs
          :after
          (progn
            (global-set-key (kbd "C-x C-z") 'magit-status)))

   ;; code completion library
   (:name company-mode
          :after
          (progn
            (global-company-mode)
            (global-set-key (kbd "<M-tab>") 'company-complete)
            (global-set-key (kbd "<backtab>") 'company-complete)
            (define-key global-map (kbd "C-.") 'company-files)))

   (:name flycheck ; general error reporting library
          :after (progn
                   (global-flycheck-mode)
                   (defun nextError ()
                     "universal error navigation, this goes to
                      the next error in the buffer"
                     (interactive)
                     (cond
                      ((bound-and-true-p flyspell-mode)
                       (flyspell-goto-next-error))

                      ((bound-and-true-p eclim-mode)
                       (eclim-problems-next-same-window))

                      ((bound-and-true-p flycheck-mode)
                       (flycheck-next-error))

                      ((bound-and-true-p flymake-mode)
                       (flymake-goto-next-error))))

                   (defun prevError ()
                     (interactive)
                     (cond
                      ((bound-and-true-p eclim-mode)
                       (eclim-problems-previous-same-window))

                      ((bound-and-true-p flyspell-mode)
                       (flyspell-goto-previous-error (point)))

                      ((bound-and-true-p flycheck-mode)
                       (flycheck-previous-error))

                      ((bound-and-true-p flymake-mode)
                       (flymake-goto-prev-error))))

                   (require 'flymake)
                   (global-set-key (kbd "M-n") 'nextError)
                   (global-set-key (kbd "M-p") 'prevError)))
   (:name multi-term ;; better version for running terminals in emacs
          :after (progn
                   (setq multi-term-program "/bin/bash")
                   (global-set-key [(f10)] 'multi-term)
                   (setq multi-term-program "/bin/bash")
                   (setq explicit-shell-file-name "/bin/bash")

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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; elisp libraries;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   (:name dash)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; C/C++ packages;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   (:name ggtags :after
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
                          'clang-format-region)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Java (and Scala) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   (:name popup) ;; required by eclim
   (:name eclim
          :after (progn
                   (setq eclim-executable "/opt/eclipse/eclim")
                   (setq eclim-eclipse-dirs "/opt/eclipse")
                   (add-to-list 'load-path "~/.emacs.d/lisp/emacs-eclim")
                   (require 'eclim)
                   (require 'eclimd)

                                        ; don't want eclim globally
                   ;;(global-eclim-mode)
                   (setq help-at-pt-display-when-idle t)
                   (setq help-at-pt-timer-delay 0.1)
                   (help-at-pt-set-timer)
                   (require 'company-emacs-eclim)
                   (company-emacs-eclim-setup)

                   (global-set-key (kbd "<C-return>") 'company-complete-common)
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Haskell;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   (:name haskell-mode
          :after (progn
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

            ;; Add key combinations for interactive haskell-mode

            ;; GHC-MOD
            (autoload 'ghc-init "ghc" nil t)
            (autoload 'ghc-debug "ghc" nil t)

            ;; COMPANY-GHC
            (add-hook 'haskell-mode-hook
                      (lambda ()
                        (ghc-init)))

            (setq ghc-debug t)))
   (:name company-ghc
          :after
          (progn
            (add-to-list 'company-backends 'company-ghc)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Web mode;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   (:name web-mode
          :after (progn  ;; set proper files as web-mode
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
                   ;; web-mode, html tag i4 html file
                   (setq web-mode-markup-i4de4t-offset 4)
                   ;; web-mode, css i4 html file
                   (setq web-mode-css-i4de4t-offset 4)
                   ;; web-mode, js code i4 html file
                   (setq web-mode-code-i4de4t-offset 4) 
                   (setq css-i4de4t-offset 4)))
   (:name company-web
          :after (progn
                   (add-to-list 'company-backends 'company-web-html)))
   (:name web-completion-data)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Javascript ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;; Javascript code completiong and error checking.
   (:name tern
          :after (progn
                   (add-hook 'js-mode-hook (lambda ()
                                             (tern-mode t)))
                   (defun delete-tern-process ()
                     "function to stop tern"
                     (interactive)
                     (delete-process "Tern"))
                   ;; add tern to company. Not working, use C-M-I for now
                   (add-to-list 'company-backends 'company-tern)))
   (:name nodejs-repl) ;; javascript reply
   (:name jshint-mode) ;; error reporting for js
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Python ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;; (:name elpy
   ;;        :after (progn
   ;;                 (elpy-enable)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; editing packages ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   (:name avy ;; package to jump to next letter or line
          :after (progn
                   (avy-setup-default)
                   (global-set-key (kbd "C-:") 'avy-goto-char)
                   (global-set-key (kbd "C-'") 'avy-goto-char-2)
                   (global-set-key (kbd "M-g f") 'avy-goto-line)
                   (global-set-key (kbd "M-g e") 'avy-goto-word-0)))
   (:name multiple-cursors
          :after (progn
                   (global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
                   (global-set-key (kbd "C->") 'mc/mark-next-like-this)
                   (global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
                   (global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)))
   (:name expand-region
          :after (progn
                   (global-set-key (kbd "C-=") 'er/expand-region)))
   (:name flyspell)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; aesthetic packages/settings ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   (:name rainbow-delimiters    ;;; highlight unmatched parens
          :after (progn
                   (add-hook 'prog-mode-hook 'rainbow-delimiters-mode)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; extra modes ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   (:name markdown-mode)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Other Packages;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	 (:name pdf-tools ;; better system for viewing pdf files
          :after (progn
                   (pdf-tools-install)))
   (:name ledger-mode
          :after (progn
                   (add-to-list 'auto-mode-alist
                                '("\\.ledger$" . ledger-mode))
                   (eval-after-load 'ledger-mode
                     '(define-key ledger-mode-map (kbd "C-M-i")
                        'complete-symbol))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Latex ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   (:name auctex
          :after (progn
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Org Extras ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   (:name org-pomodoro)
   (:name org-gcal
          :after (progn
                   (require 'org-gcal)
                   (load-file "~/.org-gcal.el")
                   (add-hook 'org-agenda-mode-hook (lambda () (org-gcal-sync)))
                   (add-hook
                    'org-capture-after-finalize-hook
                    (lambda () (org-gcal-sync)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   )
 )
;; bootstrap el-get with el-get
(setq my-el-get-packages '(el-get))
(setq my-el-get-packages
      (append my-el-get-packages
              (mapcar #'el-get-source-name el-get-sources)))

(el-get 'sync my-el-get-packages)

;; init package.el
(package-initialize)

;; extra lisp code should be in lisp directory of .emacs.d
(add-to-list 'load-path "~/.emacs.d/lisp")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;costum commands;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

(global-set-key (kbd "C-c c")   'comment-region)
(global-set-key (kbd "C-c C")   'uncomment-region)
(global-set-key (kbd "C-c d") 'define-word-at-point)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;elisp;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-key emacs-lisp-mode-map (kbd "C-c C-f") 'find-function)
(define-key emacs-lisp-mode-map (kbd "C-c C-e") 'eval-region)

(defun eval-and-replace ()
  "Replace the preceding sexp with its value."
  (interactive)
  (backward-kill-sexp)
  (condition-case nil
      (prin1 (eval (read (current-kill 0)))
             (current-buffer))
    (error (message "Invalid expression")
           (insert (current-kill 0)))))

(global-set-key (kbd "C-c e") 'eval-and-replace)


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
  "Takes a multi-line paragraph and makes it into a single line of text."
  (interactive (progn (barf-if-buffer-read-only) '(t)))
  (let ((fill-column (point-max)))
    (fill-paragraph nil region)))

;; Handy key definition
(define-key global-map "\M-Q" 'unfill-paragraph)

(defun init ()
  "go to the init file"
  (interactive)
  (find-file user-init-file))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; aesthetics/settings ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq inhibit-startup-message t) ; get rid of the annoying start up page
(global-hl-line-mode +1)         ; highlight current line
(setq frame-title-format "%b")   ; always dispay filename as titlebar

;; make mark region a darker color.
(set-face-attribute 'region nil :background "yellow")
;; (toggle-scroll-bar -1)
;; (menu-bar-mode -1)
;; (tool-bar-mode -1)

;; use spaces instead of tabs
(setq indent-tabs-mode nil)
(setq-default indent-tabs-mode nil)

(setq-default tab-width 2)
(setq tab-width 2)
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
;; Set the fill column (column number to wrap text after) to 80, not 70
(setq-default fill-column 80)

;;;;;;;;;;;;;;;;;;get emacs to quit and not ask about processes ;;;;;;;;;;;;;;;
(require 'cl)
(defadvice save-buffers-kill-emacs (around no-query-kill-emacs activate)
  (cl-flet ((process-list ())) ad-do-it))

;; display which function the cursor is in on the modeline
(which-function-mode)

;; recent file mode
(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)

;; turn off abbrev mode
(setq-default abbrev-mode nil)

;;ido mode with M-x
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Themes ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(show-paren-mode 1) ; turn on paren match highlighting
(setq show-paren-style 'mixed);highlight entire bracket exp

(require 'linum) ;; line numbers
(add-hook 'prog-mode-hook 'linum-on) ; only turn line numbers for programing modes

;; no line numbers for doc view,
(add-hook 'doc-view-mode-hook (lambda () (linum-mode -1)))

;; always add closing brackets and parens
(electric-pair-mode 1) 

(set-frame-font "DejaVu Sans Mono-10" nil t)
(set-face-attribute 'mode-line nil :font "DejaVu Sans Mono-8")

;;; set up unicode
(prefer-coding-system                     'utf-8)
(set-default-coding-systems               'utf-8)
(set-terminal-coding-system               'utf-8)
(set-keyboard-coding-system               'utf-8)
(setq default-buffer-file-coding-system 'utf-8)
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

(global-prettify-symbols-mode +1) ;; pretty symbols like lambda 

(setq popup-use-optimized-column-computation nil)


;;add git to powerline
(vc-mode 1)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Web ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun open-in-firefox ()
  "Open the current file in firefox." 
  (interactive)
  (shell-command (concat "firefox " (buffer-name))))

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
     (define-key sgml-mode-map (kbd "C-c f") 'open-in-firefox)))

(eval-after-load 'css-mode
  '(define-key css-mode-map (kbd "C-c w b") 'web-beautify-css))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; git ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'git)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Latex;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun delete-latex-garbage()
  (interactive)
  (shell-command-ignore-buffer "rm *.aux")
  (shell-command-ignore-buffer "rm *.out")
  (shell-command-ignore-buffer "rm *.log"))

(defun shell-command-ignore-buffer (command)
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

(define-key LaTeX-mode-map [(f5)] 'make-and-view-latex)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Org-mode ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'org)
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)
(defun notes ()
  "Switch to my work dir."
  (interactive)
  (find-file
   (concat "~/Documents/"
           (read-from-minibuffer "Enter the dir:"))))

(defun newNote (className)
  (interactive "sEnter name of Class: ")
  (let* ((fileName
          (concat (format-time-string "%Y-%m-%d")   ".org"))
         (fileFullName
          (concat "~/Documents/" className "/" fileName)))
    (find-file fileFullName)))

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
            (linum-on)))

(global-set-key "\C-coa" 'org-agenda)
(global-set-key "\C-coc" 'org-capture)

;; TODO entry automatricall change to DONE when all children are done
(defun org-summary-todo (n-done n-not-done)
  "Switch entry to DONE when all subentries are done, to TODO
otherwise."
  (let (org-log-done org-log-states)   ; turn off logging
    (org-todo (if (= n-not-done 0) "DONE" "TODO"))))

(add-hook 'org-after-todo-statistics-hook 'org-summary-todo)


;; display links to images
(setq org-startup-with-inline-images t)

(add-to-list 'org-agenda-files "~/org")

(setq org-agenda-window-setup 'current-window)

(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
              (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)" "PHONE" "MEETING" "CURRENT"))))

(setq org-todo-keyword-faces
      (quote (("TODO" :foreground "red" :weight bold)
              ("NEXT" :foreground "yellow" :weight bold)
              ("DONE" :foreground "blue" :weight bold)
              ("WAITING" :foreground "magenta" :weight bold)
              ("HOLD" :foreground "green" :weight bold)
              ("CANCELLED" :foreground "purple" :weight bold)
              ("MEETING" :foreground "green" :weight bold)
              ("PHONE"  :foreground "green" :weight bold)
              ("CURRENT" :foreground "green" :weight bold))))

(setq org-use-fast-todo-selection t)
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/org/TODO.org" "Tasks")
             "* TODO %?\n  %i\n  %a")
        ("j" "Journal" entry (file+datetree "~/org/journal.org")
         "* %?\nEntered on %U\n  %i\n  %a")
        ("a" "Appointment" entry (file  "~/org/agenda.org" )
         "* %?\n\n%^T\n\n:PROPERTIES:\n\n:END:\n\n")))

;; used for org columns
(setq org-columns-default-format "%50ITEM(Task) %10CLOCKSUM %16TIMESTAMP_IA")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

(define-key org-mode-map (kbd "M-p") 'flyspell-goto-previous-error)
(add-hook 'LaTeX-mode-hook (lambda()
                             (turn-on-flyspell)
                             (linum-mode)))
(add-hook 'org-mode-hook (lambda()
                           (turn-on-flyspell)
                           (linum-mode)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;; Dired Extensions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(put 'dired-find-alternate-file 'disabled nil)
(setq doc-view-resolution 300)
(setq dired-listing-switches "-alh")
(define-key dired-mode-map (kbd "C-x w") 'wdired-change-to-wdired-mode)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;C/C++;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; make h files use c++ mode
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(add-hook 'c++-mode-hook
          (lambda ()
            (define-key c++-mode-map (kbd "C-M-x c") 'compile)
            (setq abbrev-mode nil)))

(add-hook 'c-mode-hook
          (lambda ()
            (define-key c-mode-map (kbd "C-M-x c") 'compile)
            (setq abbrev-mode nil)))
(add-hook 'c++-mode-hook
          (lambda()
            (setq flycheck-clang-language-standard "c++14")
            (setq flycheck-clang-args "-std=c++14")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SQL stuff;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; on arch mysql is through mariadb which has an odd prompt-for-change-log-name
;; which won't show up  with current set up in sqli mode
(require 'sql)
(sql-set-product-feature 'mysql :prompt-regexp "^\\(?:mysql\\|mariadb\\).*> ")
(add-hook 'sql-interactive-mode-hook (lambda () (toggle-truncate-lines t)))
(add-to-list 'company-backends 'company-edbi) ;; mysql auto complete
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; load feeds for newsticker
(if (file-exists-p "~/.feeds")
    (load-file "~/.feeds"))

;; enable the erase-buffer function
(put 'erase-buffer 'disabled nil)

(require 'server)
(if (not (server-running-p))
    (server-start))

;; (add-hook 'after-init-hook (load-file "~/.cache/wal/colors.el"))
