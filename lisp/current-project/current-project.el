;;; package --- Summary

;;; Commentary:

;;; Code:

(require 'dash)

(defvar current-project-dirs nil
  "Variable storing the current projects being worked on.")

(if (file-exists-p "~/.emacs.d/.CurProjects")
		(load-file "~/.emacs.d/.CurProjects")
	(message "no current projects file"))

(defun add-current-project-dir ()
  "Add project to current projects."
  (interactive)
	(add-to-list 'current-project-dirs (getdir))
	(save-current-projects))


(defun getdir ()
	"Gets current directory, doesn't work in dired buffers, annoyingly."
	(if (eq major-mode 'dired-mode)
			default-directory
		(mapconcat
     'identity
     (reverse (cdr (reverse (split-string (buffer-file-name) "/")))) "/")))


(defun open-projects ()
	"Open the current projects."
  (interactive)
	(if current-project-dirs
			(map 'list 'find-file current-project-dirs)
		(message "no current projects!")))

(defun remove-current-dir ()
	"Remove the current project from the list of current projects."
  (interactive)
  (setq current-project-dirs
				(delete (getdir)
								 current-project-dirs))
	(save-current-projects))

(defun create-save-string ()
  "Create a string sexp that set the current projects."
	(format "(setq current-project-dirs '%S )" current-project-dirs))

(defun save-current-projects ()
  "Save the current projects to file."
	(if (file-exists-p "~/.emacs.d/.CurProjects")
			(delete-file "~/.emacs.d/.CurProjects"))
	(write-region (create-save-string) nil "~/.emacs.d/.CurProjects" 'append))

(provide 'current-project)
;;; current-project.el ends here
