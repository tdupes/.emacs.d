(require 'purpose)

;; Thomas DuPlessis

;;This is my purpose mode set up it will have one type for main stuff,
;; ie programming buffers, writing and another for helper/info stuff
;; ** buffers, and another for interactive buffers like repls and
;; terminals


;; purposes
;; main
;; info
;; interactive


(add-to-list 'purpose-user-mode-purposes '(term-mode . interactive))
(add-to-list 'purpose-user-mode-purposes '(shell-mode . interactive))
(add-to-list 'purpose-user-mode-purposes '(dired-mode . info))
(add-to-list 'purpose-user-mode-purposes '(haskell-cabal-mode . info))
(add-to-list 'purpose-user-mode-purposes '(haskell-error-mode . info))


;; comint mode is the base mode of all interpreptor modes
(add-to-list 'purpose-user-mode-purposes '(comint-mode . interactive))
(add-to-list 'purpose-user-mode-purposes '(sql-interactive-mode . interactive))


(add-to-list 'purpose-user-name-purposes '("*Buffer List*" . info))
(add-to-list 'purpose-user-name-purposes '("*Warnings*" . info))

;; all those little emacs starred buffers are secondary
;; (add-to-list 'purpose-user-regexp-purposes '("\*.*\*" . info))
;; THIS over rides the term mode stuff

(add-to-list 'purpose-user-name-purposes '("*Messages*" . info))
(add-to-list 'purpose-user-name-purposes '("*Help*" . info))
(add-to-list 'purpose-user-regexp-purposes '(".*eclim.*" . info))
(add-to-list 'purpose-user-regexp-purposes '(".*magit.*" . info))
(add-to-list 'purpose-user-regexp-purposes '(".*compilation.*" . info))
(add-to-list 'purpose-user-regexp-purposes '(".*Compile.*" . info))

(add-to-list 'purpose-user-regexp-purposes '(".*GHC.*" . info))

(add-to-list 'purpose-user-mode-purposes '(text-mode . info))
(add-to-list 'purpose-user-name-purposes '("README.md" . info))
(add-to-list 'purpose-user-name-purposes '("README" . info))


;; programming buffers are my main concern!
(add-to-list 'purpose-user-mode-purposes '(prog-mode . main))
(add-to-list 'purpose-user-mode-purposes '(html-mode . main))
(add-to-list 'purpose-user-mode-purposes '(web-mode . main))
;;(add-to-list 'purpose-user-mode-purposes '(dired-mode . main))

;; scratch is actually programming!
(add-to-list 'purpose-user-name-purposes '("*scratch*" . main))

;; for some reason, haskell isn't in prog mode, so add this to main
(add-to-list 'purpose-user-regexp-purposes '(".*.hs$" . main))


;; add my repls to interactive purpose
(add-to-list 'purpose-user-mode-purposes '(interactive-haskell-mode . interactive))
(add-to-list 'purpose-user-mode-purposes '(haskell-interactive-mode . interactive))
(add-to-list 'purpose-user-mode-purposes '(inferior-groovy-mode . interactive))
(add-to-list 'purpose-user-mode-purposes '(inferior-octave-mode . interactive))
(add-to-list 'purpose-user-mode-purposes '(inferior-python-mode . interactive))

;; writing papers is also a main concern
(add-to-list 'purpose-user-mode-purposes '(latex-mode . main))






(add-to-list 'purpose-user-mode-purposes '(org-mode . main))
(add-to-list 'purpose-user-mode-purposes '(org-agenda-mode . info))
(add-to-list 'purpose-user-mode-purposes '(shell-mode . interactive))

(purpose-compile-user-configuration)
