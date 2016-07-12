(load-file "~/.emacs.d/ProofGeneral/generic/proof-site.el")
;(setq coq-prog-name "/usr/bin/coqtop")

;; Open .v files with Proof-General's coq-mode
(require 'proof-site)

;; Load company-coq when opening Coq files
(add-hook 'coq-mode-hook #'company-coq-initialize)
