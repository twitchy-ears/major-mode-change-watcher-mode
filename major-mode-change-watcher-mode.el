;;; major-mode-change-watcher-mode.el --- Minor mode that runs functions when the major-mode variable changes -*- lexical-binding: t -*-

;; Copyright 2025 - Twitchy Ears

;; Author: Twitchy Ears https://github.com/twitchy-ears/
;; URL: https://github.com/twitchy-ears/major-mode-change-watcher-mode
;; Version: 0.1
;; Package-Requires ((emacs "30.1"))
;; Keywords: buffer save

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; History
;;
;; 2025-08-11 Initial version.

;;; Commentary:

;; Theoretically there is the run-mode-hooks function, which will call
;; both the change-major-mode-after-body-hook and
;; after-change-major-mode-hook (see
;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Mode-Hooks.html)
;; however sometimes major modes in bits of software don't run that
;; function or those hooks.
;;
;; There is no universal method of watching for a major mode change in
;; Emacs to hook for functions and sometimes you really want to do
;; that - hence why this little minor mode was written.
;; 
;; When switched on operates globally, uses add-variable-watcher to
;; look at the major-mode variable and when it has an operation
;; performed on it then this mode runs every function in the
;; major-mode-change-watcher-functions list giving each 4 arguments,
;; the new-value (the mode being switched to) the old-value (the mode
;; being switched from) the operation type (look for 'set if you want
;; to just see mode changes) and the buffer where it is occuring.
;;
;; Each configured function will run *before* the major-mode is
;; changed too, not afterwards because of how add-variable-watcher
;; operates.
;;
;; A simple example is something like this: 
;; 
;; (use-package major-mode-change-watcher-mode
;;   :config
;;   
;;   (defun my/major-mode-change-watcher-test (newval oldval operation where)
;;     (message "my/major-mode-change-watcher-test (%s, %s, %s, %s)"
;;              newval
;;              oldval
;;              operation
;;              where))
;; 
;;   (add-to-list 'major-mode-change-watcher-functions
;;                #'my/major-mode-change-watcher-test)
;;   
;;   (major-mode-change-watcher-mode t))


(defvar major-mode-change-watcher-mode-after-hook
  nil
  "Functions run after major-mode-change-watcher-mode is activated/deactivated")

(defvar major-mode-change-watcher-functions
  '()
  "Functions that run just before a major-mode change, they will be passed 4 arguments (new-val old-val operation where)")

(defun major-mode-change-watcher-runner (symbol newval operation where)
  "Runs functions when major-mode is about to change.

When major-mode-change-watcher-mode is enabled then before every major-mode change this function will run, and it will then run every function it finds in major-mode-change-watcher-functions.

Each will get passed 4 arguments: 
new-value (new mode)
old-value (current mode)
operation (whats happening)
where (which buffer this is occuring in)"

  (if (>= (length major-mode-change-watcher-functions) 1)
      (mapcar (lambda (x)
                (funcall x newval major-mode operation where))
              major-mode-change-watcher-functions)))
          
(define-minor-mode major-mode-change-watcher-mode ()
  "Runs functions before changes to the major-mode

Watches for changes to major-mode and runs configured functions when that
happens.  Those functions will have four arguments passed:
new-value (new mode)
old-value (current mode)
operation (whats happening)
where (which buffer this is occuring in)

See https://www.gnu.org/software/emacs/manual/html_node/elisp/Watching-Variables.html for the list of operations.

After the mode is activated/deactivated then
major-mode-change-watcher-mode-after-hook will run."
  
  :init-value nil
  :global t
  :lighter ""
  :after-hook major-mode-change-watcher-mode-after-hook
  
  (if major-mode-change-watcher-mode

      ;; Activate
      (progn
        (add-variable-watcher 'major-mode #'major-mode-change-watcher-runner))

    ;; Deactivate
    (progn
      (remove-variable-watcher 'major-mode #'major-mode-change-watcher-runner))))

(provide 'major-mode-change-watcher-mode)
