;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Themes ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Code:
(load-theme 'gruvbox t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; powerline/modeline ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'load-path "~/.emacs.d/powerline")
(require 'powerline)
(set-face-background 'powerline-active2 "#3c3836")
(set-face-background 'powerline-active2 "#928374")
(set-face-background 'mode-line "#fe8109")
(set-face-foreground 'mode-line "#fbf1c7")
;; (powerline-default-theme)
;; set powerline to gruvbox colors

;; now using spacemacs mode line theme
(add-to-list 'load-path "~/.emacs.d/lisp/spaceline/")
(require 'spaceline-config)
(spaceline-spacemacs-theme)
(setq spaceline-separator-dir-left '(left . left))
(setq spaceline-separator-dir-right '(right . right))
(setq powerline-default-separator 'wave)
(spaceline-compile)

;;add git to powerline
(vc-mode 1)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; I prefer linux style/bsd over gnu style 
(setq c-default-style "bsd"
      c-basic-offset 2)


(show-paren-mode 1) ; turn on paren match highlighting
(setq show-paren-style 'mixed);highlight entire bracket exp

;; line numbers
(require 'linum)
(add-hook 'prog-mode-hook 'linum-on) ; only turn line numbers for programing modes

; no line numbers for doc view, 
(add-hook 'doc-view-mode-hook
  (lambda () (linum-mode -1)))
(setq column-number-mode t);; Sets up column numbers 


;; always add closing brackets and parens
(electric-pair-mode 1) 

(set-frame-font "DejaVu Sans Mono for Powerline-8" nil t)

;;; set up unicode
(prefer-coding-system										'utf-8)
(set-default-coding-systems							'utf-8)
(set-terminal-coding-system							'utf-8)
(set-keyboard-coding-system							'utf-8)
(setq default-buffer-file-coding-system 'utf-8)                      
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

;; pretty symboles like lambda 
(global-prettify-symbols-mode +1)

(setq popup-use-optimized-column-computation nil)

;; rainbow delimiters
;; (set-face-attribute 'rainbow-delimiters-unmatched-face nil
;; 										:foreground 'unspecified
;; 										:inherit 'error)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

