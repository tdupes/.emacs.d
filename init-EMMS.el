
(require 'emms-setup)
(emms-standard)
(defvar dired-mplayer-program "/usr/bin/vlc")
(emms-default-players)


;; now using bongo, similar but simpler then emms
(add-to-list 'load-path "~/.emacs.d/bongo")
(autoload 'bongo "bongo"
  "Start Bongo by switching to a Bongo buffer." t)

;; bongo uses volume.el
(add-to-list 'load-path "~/.emacs.d/volume-el/")

(add-to-list 'load-path "~/.emacs.d/helm-spotify")
