;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Latex;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'load-path "~/.emacs.d/auctex/")

(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq TeX-save-query nil)
(setq TeX-PDF-mode t)

(add-to-list
    `flymake-err-line-patterns
    '("Runaway argument?" nil nil nil))
(defun flymake-get-tex-args (file-name)
  (list "pdflatex_nobreak"
	(list "-file-line-error" "-draftmode" "-interaction=nonstopmode" file-name)))

(add-hook 'LaTeX-mode-hook 'flymake-mode)
 	

(load "auctex.el" nil t t) 
(load "preview-latex.el" nil t t)

(add-to-list 'load-path "~/.emacs.d/lisp/company-auctex")
(require 'company-auctex)
(company-auctex-init)

(defun deleteLatexGarbage()
  (interactive)
  (shell-command-ignore-buffer "rm *.aux")
  (shell-command-ignore-buffer "rm *.out")
  (shell-command-ignore-buffer "rm *.log"))

(defun deleteEmacsGarbage()
  (interactive)
  (shell-command-ignore-buffer "rm *~")
  (shell-command-ignore-buffer "rm \#.*"))

(defun shell-command-ignore-buffer (command)
	(with-temp-buffer
		(shell-command command t)))

;; assumes you are calling this in a .tex file
(defun makeAndViewLatex()
  (interactive)
  (save-excursion
    (save-buffer)
    (shell-command-ignore-buffer (concat "pdflatex " (buffer-name)))
    (deleteLatexGarbage)
		(let ((pdfname
					 (concat (substring (buffer-name) 0 -4) ".pdf")))
			(if (get-buffer pdfname)
					(progn
						(switch-to-buffer pdfname)
						(revert-buffer))
				(find-file pdfname)))))

(define-key LaTeX-mode-map [(f5)] 'makeAndViewLatex)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
