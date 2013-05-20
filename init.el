(require 'package)
(require 'cl)

(dolist (source '(("elpa" . "http://tromey.com/elpa/")
                  ("melpa" . "http://melpa.milkbox.net/packages/")))
  (add-to-list 'package-archives source t))

(setq package-user-dir (expand-file-name "elpa" (file-name-directory load-file-name)))
(package-initialize)

(defvar prelude-packages
  '(ace-jump-mode ack-and-a-half diminish elisp-slime-nav
                  expand-region flycheck gist
                  git-commit-mode gitconfig-mode gitignore-mode
                  guru-mode helm helm-projectile
                  key-chord magit melpa
                  rainbow-mode solarized-theme undo-tree
                  volatile-highlights yasnippet zenburn-theme
                  dash starter-kit starter-kit-bindings
                  starter-kit-js starter-kit-lisp
                  starter-kit-ruby
                  evil js2-refactor)
  "A list of packages to ensure are installed at launch.")

(defun prelude-packages-installed-p ()
  (equalp 0 (length (remove-if #'package-installed-p prelude-packages))))

(defun prelude-install-packages ()
  (unless (prelude-packages-installed-p)
    ;; check for new packages (package versions)
    (message "%s" "Emacs Prelude is now refreshing its package database...")
    (package-refresh-contents)
    (message "%s" " done.")
    ;; install the missing packages
    (dolist (package (remove-if #'package-installed-p prelude-packages))
      (package-install package))))

(prelude-install-packages)

(defmacro prelude-auto-install (extension package mode)
  `(add-to-list 'auto-mode-alist
                `(,extension . (lambda ()
                                 (unless (package-installed-p ',package)
                                   (package-install ',package))
                                 (,mode)))))

(defvar prelude-auto-install-alist
  '(("\\.clj\\'" clojure-mode clojure-mode)
    ("\\.coffee\\'" coffee-mode coffee-mode)
    ("\\.css\\'" css-mode css-mode)
    ("\\.erl\\'" erlang erlang-mode)
    ("\\.feature\\'" feature-mode feature-mode)
    ("\\.groovy\\'" groovy-mode groovy-mode)
    ("\\.haml\\'" haml-mode haml-mode)
    ("\\.hs\\'" haskell-mode haskell-mode)
    ("\\.latex\\'" auctex LaTeX-mode)
    ("\\.less\\'" less-css-mode less-css-mode)
    ("\\.lua\\'" lua-mode lua-mode)
    ("\\.markdown\\'" markdown-mode markdown-mode)
    ("\\.md\\'" markdown-mode markdown-mode)
    ("\\.php\\'" php-mode php-mode)
    ("\\.py\\'" python python-mode)
    ("\\.sass\\'" sass-mode sass-mode)
    ("\\.scala\\'" scala-mode2 scala-mode)
    ("\\.scss\\'" scss-mode scss-mode)
    ("\\.slim\\'" slim-mode slim-mode)
    ("\\.yml\\'" yaml-mode yaml-mode)
    ("\\.json\\'" js2-mode js2-mode)
    ("\\.js\\" js2-mode js2-mode)))

(mapc
 (lambda (entry)
   (let ((extension (car entry))
         (package (cadr entry))
         (mode (cadr (cdr entry))))
       (prelude-auto-install extension package mode)))
 prelude-auto-install-alist)

(require 'dash)

(evil-mode 1)
(setq evil-default-cursor t)

;; use ido with recentf

(require 'recentf)
(recentf-mode 1)
(setq recentf-max-saved-items 300)

(defun recentf-ido-find-file ()
  "Use ido to select a recently opened file from the `recentf-list'"
  (interactive)
  (find-file (ido-completing-read "Open file: " recentf-list nil t)))

(global-set-key (kbd "C-x f") 'recentf-ido-find-file)

;; use tabs/set tab width for certain modes
(-each '(js2-mode-hook js-mode-hook html-mode-hook nxml-mode-hook css-mode-hook)
       (lambda (hook)
         (add-hook hook
                   (lambda ()
                     (setq tab-width 4)
                     (setq indent-tabs-mode t)))))


;; disable backup
(setq backup-inhibited t)
;; disable auto save
(setq auto-save-default nil)

;; 'a' in dired mode
(put 'dired-find-alternate-file 'disabled nil)

(set-default-font "-unknown-DejaVu Sans Mono-normal-normal-normal-*-14-*-*-*-m-0-iso10646-1")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(js-curly-indent-offset 2)
 '(js-expr-indent-offset 4)
 '(js-indent-level 4)
 '(js-paren-indent-offset 0)
 '(js2-strict-missing-semi-warning nil)
 '(projectile-git-command "git ls-tree -z -r --name-only HEAD"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;; scrollers
(global-set-key "\M-n" "\C-u1\C-v")
(global-set-key "\M-p" "\C-u1\M-v")

(require 'yasnippet)
(yas--initialize)
(yas/load-directory "/home/alex/.emacs.d/elpa/yasnippet-20130218.2229/snippets")

(global-set-key (kbd "C-x g") 'magit-status)

(projectile-global-mode)

(add-to-list 'auto-mode-alist '("\\.xml$" . nxml-mode))
(add-to-list 'auto-mode-alist '("buildfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.jsp$" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.ejs$" . nxml-mode))

(setq ido-use-filename-at-point nil)

(define-key evil-insert-state-map "\C-e" 'move-end-of-line)

(defun visit-ielm ()
  "Create or visit a `ielm' buffer."
  (interactive)
  (if (not (get-buffer "*ielm*"))
      (progn
        (split-window-sensibly (selected-window))
        (other-window 1)
        (ielm))
    (switch-to-buffer-other-window "*ielm*")))

(global-set-key (kbd "C-c C-z") 'visit-ielm)

(require 'key-chord)
(key-chord-define evil-insert-state-map "df" 'evil-normal-state)
(key-chord-define evil-visual-state-map "df" 'evil-normal-state)
(key-chord-define evil-emacs-state-map "df" 'evil-normal-state)
(key-chord-define evil-motion-state-map "df" 'evil-normal-state)
(key-chord-mode +1)

(setq dabbrev-case-replace nil)
