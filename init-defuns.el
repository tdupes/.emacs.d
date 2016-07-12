(defun repeatString(numTimes str)
  (apply 'concat (make-list numTimes str)))

(defun str-divide(len str)
  (/ len (length str)))


;; lil function to make little section titles in any language with comment
;; character
(defun mkSectionTitle(title)
  "creates a little title section with three lines, first line of
  all comment chars, the second is the title wrapped in comment
  chars and the third is all comment chars again"
  (interactive "sEnter the title:")
  (let* ((numReptimes
					(- (str-divide 80 comment-start)
						 (length comment-end)))
				 (fstAndThrdLn
					(concat
					 (repeatString numReptimes comment-start) comment-end "\n"))
				 (titleLineCommentRepNum
					(/ (str-divide (- 80 (length title)) comment-start)
						 2))
				 (titleLine
					(concat (repeatString titleLineCommentRepNum comment-start)
									title
									(repeatString (- titleLineCommentRepNum
																	 (length comment-end))
																comment-start)
									comment-end
									"\n")))
    (end-of-line)
    (newline)
    (insert (concat fstAndThrdLn
										titleLine
										fstAndThrdLn))))

(defun endSection()
  "ends a section created by 'mkSectionTitle"
  (interactive)
  (let* ((numReptimes
					(- (str-divide 80 comment-start) (length comment-end)))
				 (ln (concat (repeatString numReptimes comment-start)
										 comment-end
										 "\n")))
    (end-of-line)
    (newline)
    (insert (repeatString 3 ln))))


;;; Stefan Monnier <foo at acm.org>. It is the opposite of fill-paragraph
(defun unfill-paragraph (&optional region)
  "Takes a multi-line paragraph and makes it into a single line of text."
  (interactive (progn (barf-if-buffer-read-only) '(t)))
  (let ((fill-column (point-max)))
    (fill-paragraph nil region)))

;; Handy key definition
(define-key global-map "\M-Q" 'unfill-paragraph)

