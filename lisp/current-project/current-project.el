(require 'dash)

(defvar current-Project-Dirs nil "variable storing the current projects being worked on")

(if (file-exists-p "~/.emacs.d/.CurProjects")
		(load-file "~/.emacs.d/.CurProjects")
	(message "no current projects file"))

(defun add-current-Project-Dir ()
  (interactive)
	(add-to-list 'current-Project-Dirs (getDir))
	(saveCurrentProjects))


(defun getDir ()
	"gets current directory, doesn't work in dired buffers, annoyingly"
	(if (eq major-mode 'dired-mode)
			default-directory
		(mapconcat
		'identity (reverse (cdr (reverse (split-string (buffer-file-name) "/")))) "/")))


(defun openProjects ()
	"open the current projects"
  (interactive)
	(if current-Project-Dirs
			(map 'list 'find-file current-Project-Dirs)
		(message "no current projects!")))

(defun remove-Current-Dir ()
	"remove the current project being worked on from the list of current projects"
  (interactive)
  (setq current-Project-Dirs
				(delete (getDir)
								 current-Project-Dirs))
	(saveCurrentProjects))

(defun createSaveString ()
	(format "(setq current-Project-Dirs '%S )" current-Project-Dirs))

; (format "(setq current-Project-Dirs '%S ) " current-Project-Dirs)

(defun saveCurrentProjects ()
	(if (file-exists-p "~/.emacs.d/.CurProjects")
			(delete-file "~/.emacs.d/.CurProjects"))
	(write-region (createSaveString) nil "~/.emacs.d/.CurProjects" 'append))

(provide 'current-project)
