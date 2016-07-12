;; on arch mysql is through mariadb which has an odd prompt-for-change-log-name
;; which won't show up  with current set up in sqli mode

;;(setq sql-mysql-options '("--prompt=mysql> "))

(require 'sql)

(sql-set-product-feature 'mysql :prompt-regexp "^\\(?:mysql\\|mariadb\\).*> ")

;; got the following mostly from
;; https://truongtx.me/2014/08/23/setup-emacs-as-an-sql-database-client/
(add-hook 'sql-interactive-mode-hook
          (lambda ()
            (toggle-truncate-lines t)))

;; auto completion
(add-to-list 'company-backends 'company-edbi)
