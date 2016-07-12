((avy status "installed" recipe
      (:name avy :after
	     (progn
	       (avy-setup-default)
	       (global-set-key
		(kbd "C-:")
		'avy-goto-char)
	       (global-set-key
		(kbd "C-'")
		'avy-goto-char-2)
	       (global-set-key
		(kbd "M-g f")
		'avy-goto-line)
	       (global-set-key
		(kbd "M-g e")
		'avy-goto-word-0))
	     :description "Jump to things in Emacs tree-style." :type github :pkgname "abo-abo/avy" :depends
	     (cl-lib)))
 (cl-lib status "installed" recipe
	 (:name cl-lib :builtin "24.3" :type elpa :description "Properly prefixed CL functions and macros" :url "http://elpa.gnu.org/packages/cl-lib.html"))
 (company-mode status "installed" recipe
	       (:name company-mode :after
		      (progn
			(global-company-mode)
			(global-set-key
			 (kbd "<M-tab>")
			 'company-complete)
			(global-set-key
			 (kbd "<backtab>")
			 'company-complete)
			(define-key global-map
			  (kbd "C-.")
			  'company-files)
			(set-face-attribute 'company-tooltip nil :background "#ebdbb2" :foreground "#282828")
			(set-face-attribute 'company-scrollbar-bg nil :background "#076678")
			(set-face-attribute 'company-scrollbar-fg nil :background "#d65d0e")
			(set-face-attribute 'company-tooltip-common-selection nil :background "#928374" :foreground "#f9f5d7")
			(set-face-attribute 'company-tooltip-selection nil :background "#928374" :foreground "#f9f5d7")
			(set-face-attribute 'company-tooltip-common nil :background "#79740e" :foreground "#fbf1c7"))
		      :website "http://company-mode.github.io/" :description "Modular in-buffer completion framework for Emacs" :type github :pkgname "company-mode/company-mode"))
 (company-web status "installed" recipe
	      (:name company-web :after
		     (progn
		       (add-to-list 'company-backends 'company-web-html))
		     :description "Company-web is an alternative emacs plugin for autocompletion in html-mode, web-mode, jade-mode, slim-mode and use data of ac-html. It uses company-mode." :website "https://github.com/osv/company-web" :type github :pkgname "osv/company-web"))
 (dash status "installed" recipe
       (:name dash :description "A modern list api for Emacs. No 'cl required." :type github :pkgname "magnars/dash.el"))
 (dirtree status "installed" recipe
	  (:name dirtree :description "Functions for building directory-tree lists" :type http :url "http://www.splode.com/~friedman/software/emacs-lisp/src/dirtree.el" :features dirtree))
 (eclim status "installed" recipe
	(:name eclim :after
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
		 (global-set-key
		  (kbd "<C-return>")
		  'company-complete-common)
		 (add-hook 'java-mode-hook
			   (lambda nil
			     (define-key java-mode-map
			       (kbd "<M-tab>")
			       'company-complete-common)
			     (define-key java-mode-map
			       (kbd "C-c C-f")
			       'eclim-java-find-declaration)
			     (define-key java-mode-map
			       (kbd "C-c C-r")
			       'eclim-java-find-references)))
		 (add-hook 'java-mode-hook
			   (lambda nil
			     (eclim-mode)))
		 (add-hook 'scala-mode-hook
			   (lambda nil
			     (scala-mode-feature-electric-mode)
			     (eclim-mode))))
	       :website "https://github.com/emacs-eclim/emacs-eclim/" :description "This project brings some of the great eclipse features to emacs developers." :type github :pkgname "emacs-eclim/emacs-eclim" :features eclim :depends
	       (s)
	       :post-init
	       (progn
		 (setq eclim-auto-save t)
		 (global-eclim-mode -1))))
 (el-get status "installed" recipe
	 (:name el-get :website "https://github.com/dimitri/el-get#readme" :description "Manage the external elisp bits and pieces you depend upon." :type github :branch "master" :pkgname "dimitri/el-get" :info "." :compile
		("el-get.*\\.el$" "methods/")
		:features el-get :post-init
		(when
		    (memq 'el-get
			  (bound-and-true-p package-activated-list))
		  (message "Deleting melpa bootstrap el-get")
		  (unless package--initialized
		    (package-initialize t))
		  (when
		      (package-installed-p 'el-get)
		    (let
			((feats
			  (delete-dups
			   (el-get-package-features
			    (el-get-elpa-package-directory 'el-get)))))
		      (el-get-elpa-delete-package 'el-get)
		      (dolist
			  (feat feats)
			(unload-feature feat t))))
		  (require 'el-get))))
 (emacs-async status "installed" recipe
	      (:name emacs-async :description "Simple library for asynchronous processing in Emacs" :type github :pkgname "jwiegley/emacs-async"))
 (emacs-w3m status "installed" recipe
	    (:name emacs-w3m :description "A simple Emacs interface to w3m" :type cvs :website "http://emacs-w3m.namazu.org/" :module "emacs-w3m" :url ":pserver:anonymous@cvs.namazu.org:/storage/cvsroot" :build
		   `(("autoconf")
		     ("./configure" ,(format "--with-emacs=%s" el-get-emacs))
		     ("make"))
		   :build/windows-nt
		   (("sh" "./autogen.sh")
		    ("sh" "./configure")
		    ("make"))
		   :info "doc"))
 (emms status "installed" recipe
       (:name emms :after
	      (progn
		(require 'emms-setup)
		(emms-standard)
		(defvar dired-mplayer-program "/usr/bin/vlc")
		(emms-default-players))
	      :description "The Emacs Multimedia System" :type git :url "git://git.sv.gnu.org/emms.git" :info "doc" :load-path
	      ("./lisp")
	      :features emms-setup :build
	      `(("mkdir" "-p" ,(expand-file-name
				(format "%s/emms" user-emacs-directory)))
		("make" ,(format "EMACS=%s" el-get-emacs)
		 ,(format "SITEFLAG=--no-site-file -L %s"
			  (shell-quote-argument
			   (el-get-package-directory "emacs-w3m")))
		 "autoloads" "lisp" "docs"))
	      :build/berkeley-unix
	      `(("mkdir" "-p" ,(expand-file-name
				(format "%s/emms" user-emacs-directory)))
		("gmake" ,(format "EMACS=%s" el-get-emacs)
		 ,(format "SITEFLAG=--no-site-file -L %s"
			  (shell-quote-argument
			   (el-get-package-directory "emacs-w3m")))
		 "autoloads" "lisp" "docs"))
	      :depends emacs-w3m))
 (epl status "installed" recipe
      (:name epl :description "EPL provides a convenient high-level API for various package.el versions, and aims to overcome its most striking idiocies." :type github :pkgname "cask/epl"))
 (ess status "required" recipe nil)
 (expand-region status "installed" recipe
		(:name expand-region :after
		       (progn
			 (global-set-key
			  (kbd "C-=")
			  'er/expand-region))
		       :type github :pkgname "magnars/expand-region.el" :description "Expand region increases the selected region by semantic units. Just keep pressing the key until it selects what you want." :website "https://github.com/magnars/expand-region.el#readme"))
 (flycheck status "installed" recipe
	   (:name flycheck :after
		  (progn
		    (global-flycheck-mode)
		    (defun nextError nil "universal error navigation, this goes to the next error in the\n                      buffer"
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
		    (defun prevError nil
		      (interactive)
		      (cond
		       ((bound-and-true-p eclim-mode)
			(eclim-problems-previous-same-window))
		       ((bound-and-true-p flyspell-mode)
			(flyspell-goto-previous-error
			 (point)))
		       ((bound-and-true-p flycheck-mode)
			(flycheck-previous-error))
		       ((bound-and-true-p flymake-mode)
			(flymake-goto-prev-error))))
		    (require 'flymake)
		    (global-set-key
		     (kbd "M-n")
		     'nextError)
		    (global-set-key
		     (kbd "M-p")
		     'prevError))
		  :type github :pkgname "flycheck/flycheck" :minimum-emacs-version "24.3" :description "On-the-fly syntax checking extension" :depends
		  (dash pkg-info let-alist seq)))
 (flycheck-irony status "installed" recipe
		 (:name flycheck-irony :after
			(progn
			  (eval-after-load 'flycheck
			    '(add-hook 'flycheck-mode-hook #'flycheck-irony-setup))
			  (setq flycheck-clang-language-standard "c++11")
			  (setq flycheck-clang-args "-std=c++11")
			  (setq irony-additional-clang-options
				'("-std=c++11" "-stdlib=libc++"))
			  (add-hook 'c++-mode-hook
				    (lambda nil
				      (setq flycheck-clang-language-standard "c++11")
				      (setq flycheck-clang-args "-std=c++11")
				      (setq irony-additional-clang-options
					    '("-std=c++11" "-stdlib=libc++")))))
			:description "C, C++ and Objective-C support for Flycheck, using Irony Mode" :type github :pkgname "Sarcasm/flycheck-irony"))
 (god-mode status "installed" recipe
	   (:name god-mode :after
		  (progn
		    (global-set-key
		     (kbd "C-c g")
		     'god-local-mode)
		    (defun my-update-cursor nil "update the cursor to a hollow box if we are in god mode or a read\n                      only buffer"
			   (setq cursor-type
				 (if
				     (or god-local-mode buffer-read-only)
				     'hollow 'box)))
		    (add-hook 'god-mode-enabled-hook 'my-update-cursor)
		    (add-hook 'god-mode-disabled-hook 'my-update-cursor))
		  :description "Global minor mode for entering Emacs commands without modifier keys." :type github :pkgname "chrisdone/god-mode"))
 (haskell-mode status "installed" recipe
	       (:name haskell-mode :description "A Haskell editing mode" :type github :pkgname "haskell/haskell-mode" :info "." :build
		      `(("make" ,(format "EMACS=%s" el-get-emacs)
			 "all"))
		      :post-init
		      (progn
			(require 'haskell-mode-autoloads)
			(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
			(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation))))
 (helm status "installed" recipe
       (:name helm :after
	      (progn
		(require 'helm-config)
		(global-set-key
		 (kbd "M-x")
		 'helm-M-x)
		(global-set-key
		 (kbd "C-x r b")
		 #'helm-filtered-bookmarks)
		(global-unset-key
		 (kbd "C-x C-f"))
		(global-set-key
		 (kbd "C-x C-f")
		 #'helm-find-files)
		(global-set-key
		 (kbd "C-x b")
		 'helm-buffers-list)
		(global-set-key
		 (kbd "M-y")
		 'helm-show-kill-ring)
		(helm-mode 1)
		(define-key helm-map
		  (kbd "<tab>")
		  'helm-execute-persistent-action)
		(define-key helm-map
		  (kbd "C-i")
		  'helm-execute-persistent-action)
		(define-key helm-map
		  (kbd "C-z")
		  'helm-select-action)
		(define-key helm-map
		  (kbd "M-n")
		  'helm-next-line)
		(define-key helm-map
		  (kbd "M-p")
		  'helm-previous-line)
		(helm-autoresize-mode t)
		(setq helm-split-window-in-side-p t helm-move-to-line-cycle-in-source t helm-ff-search-library-in-sexp t helm-scroll-amount 8 helm-ff-file-name-history-use-recentf t))
	      :description "Emacs incremental completion and narrowing framework" :type github :pkgname "emacs-helm/helm" :autoloads "helm-autoloads" :build
	      (("make"))
	      :build/darwin
	      `(("make" ,(format "EMACS_COMMAND=%s" el-get-emacs)))
	      :build/windows-nt
	      (let
		  ((generated-autoload-file
		    (expand-file-name "helm-autoloads.el"))
		   \
		   (backup-inhibited t))
	      (update-directory-autoloads default-directory)
	      nil)
       :features "helm-config" :post-init
       (helm-mode)))
(helm-c-flycheck status "installed" recipe
(:name helm-c-flycheck :website "https://github.com/yasuyk/helm-flycheck" :description "Show flycheck errors with helm." :type github :depends
(helm flycheck)
:pkgname "yasuyk/helm-flycheck"))
(helm-projectile status "installed" recipe
(:name helm-projectile :description "Helm integration for Projectile." :type github :pkgname "bbatsov/helm-projectile" :depends
(projectile helm dash cl-lib)))
(irony-mode status "installed" recipe
(:name irony-mode :after
(progn
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'objc-mode-hook 'irony-mode)
(defun my-irony-mode-hook nil
(define-key irony-mode-map
[remap completion-at-point]
'irony-completion-at-point-async)
(define-key irony-mode-map
[remap complete-symbol]
'irony-completion-at-point-async))
(add-hook 'irony-mode-hook 'my-irony-mode-hook)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
(eval-after-load 'company
'(add-to-list 'company-backends 'company-irony))
(eval-after-load 'company
'(add-to-list 'company-backends
'(company-irony-c-headers company-irony))))
:description "A C/C++ minor mode for Emacs powered by libclang" :type github :pkgname "Sarcasm/irony-mode" :depends
(cl-lib)
:compile "\\.el$"))
(jshint-mode status "installed" recipe
(:name jshint-mode :after
(progn
(require 'flymake-jshint))
:website "https://github.com/daleharvey/jshint-mode" :description "Integrate JSHint into Emacs via a node.js server. JSHint (http://www.jshint.com/) is a static code analysis tool for JavaScript." :type github :pkgname "daleharvey/jshint-mode"))
(let-alist status "installed" recipe
(:name let-alist :description "Easily let-bind values of an assoc-list by their names." :builtin "25.0.50" :type elpa :url "https://elpa.gnu.org/packages/let-alist.html"))
(magit status "installed" recipe
(:name magit :after
(progn
(global-set-key
(kbd "C-x C-z")
'magit-status))
:website "https://github.com/magit/magit#readme" :description "It's Magit! An Emacs mode for Git." :type github :pkgname "magit/magit" :branch "master" :minimum-emacs-version "24.4" :depends
(dash with-editor emacs-async)
:info "Documentation" :load-path "lisp/" :compile "lisp/" :build
`(("make" ,(format "EMACSBIN=%s" el-get-emacs)
"docs")
("touch" "lisp/magit-autoloads.el"))
:build/berkeley-unix
`(("gmake" ,(format "EMACSBIN=%s" el-get-emacs)
"docs")
("touch" "lisp/magit-autoloads.el"))
:build/windows-nt
(with-temp-file "lisp/magit-autoloads.el" nil)))
(markdown-mode status "installed" recipe
(:name markdown-mode :description "Major mode to edit Markdown files in Emacs" :website "http://jblevins.org/projects/markdown-mode/" :type github :pkgname "jrblevin/markdown-mode" :prepare
(add-to-list 'auto-mode-alist
'("\\.\\(md\\|mdown\\|markdown\\)\\'" . markdown-mode))))
(multi-term status "installed" recipe
(:name multi-term :after
(progn
(setq multi-term-program "/bin/zsh")
(global-set-key
[(f10)]
'multi-term)
(setq multi-term-program "/bin/zsh")
(setq explicit-shell-file-name "/bin/zsh")
(add-hook 'term-mode-hook
(lambda nil
(setq yas-dont-activate t)
(setq term-buffer-maximum-size 10000)
(setq show-trailing-whitespace nil)
(define-key term-raw-map
(kbd "C-y")
'term-paste)))
(add-to-list 'term-bind-key-alist
'("M-d" . term-send-forward-kill-word))
(add-to-list 'term-bind-key-alist
'("<C-backspace>" . term-send-backward-kill-word))
(add-to-list 'term-bind-key-alist
'("<M-backspace>" . term-send-backward-kill-word))
(add-to-list 'term-bind-key-alist
'("M-[" . multi-term-prev))
(add-to-list 'term-bind-key-alist
'("M-]" . multi-term-next)))
:description "A mode based on term.el, for managing multiple terminal buffers in Emacs." :type emacswiki :features multi-term))
(multiple-cursors status "installed" recipe
(:name multiple-cursors :after
(progn
(global-set-key
(kbd "C-S-c C-S-c")
'mc/edit-lines)
(global-set-key
(kbd "C->")
'mc/mark-next-like-this)
(global-set-key
(kbd "C-<")
'mc/mark-previous-like-this)
(global-set-key
(kbd "C-c C-<")
'mc/mark-all-like-this))
:description "An experiment in adding multiple cursors to emacs" :type github :pkgname "magnars/multiple-cursors.el"))
(nodejs-repl status "installed" recipe
(:name nodejs-repl :description "Run Node.js REPL and communicate the process" :type github :pkgname "abicky/nodejs-repl.el"))
(package status "installed" recipe
(:name package :description "ELPA implementation (\"package.el\") from Emacs 24" :builtin "24" :type http :url "https://repo.or.cz/w/emacs.git/blob_plain/ba08b24186711eaeb3748f3d1f23e2c2d9ed0d09:/lisp/emacs-lisp/package.el" :features package :post-init
(progn
(let
((old-package-user-dir
(expand-file-name
(convert-standard-filename
(concat
(file-name-as-directory default-directory)
"elpa")))))
(when
(file-directory-p old-package-user-dir)
(add-to-list 'package-directory-list old-package-user-dir)))
(setq package-archives
(bound-and-true-p package-archives))
(let
((protocol
(if
(and
(fboundp 'gnutls-available-p)
(gnutls-available-p))
"https://"
(lwarn
'(el-get tls)
:warning "Your Emacs doesn't support HTTPS (TLS)%s"
(if
(eq system-type 'windows-nt)
",\n  see https://github.com/dimitri/el-get/wiki/Installation-on-Windows." "."))
"http://"))
(archives
'(("melpa" . "melpa.org/packages/")
("gnu" . "elpa.gnu.org/packages/")
("marmalade" . "marmalade-repo.org/packages/"))))
(dolist
(archive archives)
(add-to-list 'package-archives
(cons
(car archive)
(concat protocol
(cdr archive)))))))))
(pkg-info status "installed" recipe
(:name pkg-info :description "Provide information about Emacs packages." :type github :pkgname "lunaryorn/pkg-info.el" :depends
(dash epl)))
(popup status "installed" recipe
(:name popup :website "https://github.com/auto-complete/popup-el" :description "Visual Popup Interface Library for Emacs" :type github :submodule nil :depends cl-lib :pkgname "auto-complete/popup-el"))
(projectile status "installed" recipe
(:name projectile :after
(progn
(projectile-global-mode)
(setq projectile-mode-line
'(:eval
(format " Proj[%s]"
(projectile-project-name)))))
:description "Project navigation and management library for Emacs." :type github :pkgname "bbatsov/projectile" :depends
(dash pkg-info)))
(rainbow-delimiters status "installed" recipe
(:name rainbow-delimiters :after
(progn
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode))
:website "https://github.com/Fanael/rainbow-delimiters#readme" :description "Color nested parentheses, brackets, and braces according to their depth." :type github :pkgname "Fanael/rainbow-delimiters"))
(rtags status "installed" recipe
(:name rtags :after
(progn
(add-hook 'c-mode-common-hook 'rtags-start-process-unless-running)
(add-hook 'c++-mode-common-hook 'rtags-start-process-unless-running)
(push 'company-rtags company-backends)
(setq rtags-path "~/.emacs.d/rtags/bin")
(setq rtags-autostart-diagnostics t)
(setq rtags-completions-enabled t))
:description "Client/server application that indexes C/C++ code and keeps a persistent in-memory database of references, declarations, definitions, symbolnames" :type github :website "https://github.com/Andersbakken/rtags" :pkgname "Andersbakken/rtags" :build
`(("cmake" ".")
("make" ,@el-get-parallel-make-args))
:compile "src" :load-path "src" :post-init
(setq rtags-path
(concat default-directory "/bin/"))))
(s status "installed" recipe
(:name s :description "The long lost Emacs string manipulation library." :type github :pkgname "magnars/s.el"))
(seq status "installed" recipe
(:name seq :description "Sequence manipulation library for Emacs" :builtin "25" :type github :pkgname "NicolasPetton/seq.el"))
(tern status "installed" recipe
(:name tern :after
(progn
(add-hook 'js-mode-hook
(lambda nil
(tern-mode t)
(flymake-mode t)))
(defun delete-tern-process nil "function to stop term"
(interactive)
(delete-process "Tern"))
(add-to-list 'company-backends 'company-tern))
:description "A JavaScript code analyzer for deep, cross-editor language support." :type github :pkgname "marijnh/tern" :build
'(("npm" "--production" "install"))
:prepare
(add-to-list 'auto-mode-alist
'("\\.tern-\\(project\\|\\config\\)\\'" . json-mode))
:load-path
("emacs")))
(web-completion-data status "installed" recipe
(:name web-completion-data :description "Shared completion data for ac-html and company-web" :type github :pkgname "osv/web-completion-data"))
(web-mode status "installed" recipe
(:name web-mode :after
(progn
(add-to-list 'auto-mode-alist
'("\\.html$" . web-mode))
(add-to-list 'auto-mode-alist
'("\\.ssp$" . web-mode))
(add-to-list 'auto-mode-alist
'("\\.jsp$" . web-mode))
(add-to-list 'auto-mode-alist
'("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist
'("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist
'("\\.php$\\'" . web-mode))
(add-to-list 'auto-mode-alist
'("\\.[agj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist
'("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist
'("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist
'("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist
'("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist
'("\\.jsp$" . web-mode))
(setq web-mode-enable-current-element-highlight t)
(setq javascript-i4de4t-level 4)
(setq js-i4de4t-level 4)
(setq web-mode-markup-i4de4t-offset 4)
(setq web-mode-css-i4de4t-offset 4)
(setq web-mode-code-i4de4t-offset 4)
(setq css-i4de4t-offset 4))
:description "emacs major mode for editing PHP/JSP/ASP HTML templates (with embedded CSS and JS blocks)" :type github :pkgname "fxbois/web-mode"))
(window-purpose status "installed" recipe
(:name window-purpose :after
(progn
(load-file "~/.emacs.d/PurposeConfig.el")
(purpose-mode)
(global-unset-key
(kbd "C-x C-f"))
(define-key purpose-mode-map
(kbd "C-c b")
'purpose-switch-buffer-with-purpose)
(define-key purpose-mode-map
(kbd "C-x b")
'helm-buffers-list))
:description "Organize Windows and Buffers According to Purposes." :website "https://github.com/bmag/emacs-purpose" :type github :pkgname "bmag/emacs-purpose"))
(with-editor status "installed" recipe
(:name with-editor :description "Use the Emacsclient as $EDITOR" :type github :pkgname "magit/with-editor"))
(wrap-region status "installed" recipe
(:name wrap-region :after
(progn
(wrap-region-mode t)
(wrap-region-add-wrapper "$" "$")
(wrap-region-add-wrapper "{-" "-}" "#")
(wrap-region-add-wrapper "/" "/" nil 'ruby-mode)
(wrap-region-add-wrapper "/* " " */" "#"
'(java-mode javascript-mode css-mode))
(wrap-region-add-wrapper "`" "`" nil
'(markdown-mode ruby-mode)))
:description "Wrap text with punctation or tag" :type elpa :prepare
(progn
(autoload 'wrap-region-mode "wrap-region" nil t)
(autoload 'turn-on-wrap-region-mode "wrap-region" nil t)
(autoload 'turn-off-wrap-region-mode "wrap-region" nil t)
(autoload 'wrap-region-global-mode "wrap-region" nil t))))
(yasnippet status "installed" recipe
(:name yasnippet :after
(progn
(yas-global-mode 1)
(add-hook 'prog-mode-hook #'yas-minor-mode)
(add-to-list 'yas/root-directory "~/.emacs.d/snippets/yasnippet-snippets")
(defun yas/org-very-safe-expand nil
(let
((yas/fallback-behavior 'return-nil))
(yas/expand)))
(global-set-key
(kbd "C-M-y")
'yas-expand))
:website "https://github.com/capitaomorte/yasnippet.git" :description "YASnippet is a template system for Emacs." :type github :pkgname "capitaomorte/yasnippet" :compile "yasnippet.el" :submodule nil :build
(("git" "submodule" "update" "--init" "--" "snippets")))))
