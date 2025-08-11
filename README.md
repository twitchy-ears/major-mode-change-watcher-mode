# major-mode-change-watcher-mode
Minor mode that runs functions when the major-mode variable changes using add-variable-watcher

Theoretically there is the run-mode-hooks function, which will call both the change-major-mode-after-body-hook and after-change-major-mode-hook (see https://www.gnu.org/software/emacs/manual/html_node/elisp/Mode-Hooks.html) however sometimes major modes in bits of software don't run that function or those hooks.

There is no universal method of watching for a major mode change in Emacs to hook for functions and sometimes you really want to do that - hence why this little minor mode was written.

When switched on operates globally, uses add-variable-watcher to look at the major-mode variable and when it has an operation performed on it then this mode runs every function in the major-mode-change-watcher-functions list giving each 4 arguments, the new-value (the mode being switched to) the old-value (the mode being switched from) the operation type (look for 'set if you want to just see mode changes) and the buffer where it is occuring.

Each configured function will run *before* the major-mode is changed too, not afterwards because of how add-variable-watcher operates.

A simple example is something like this: 

```
(use-package major-mode-change-watcher-mode
  :config
  
  (defun my/major-mode-change-watcher-test (newval oldval operation where)
    (message "my/major-mode-change-watcher-test (%s, %s, %s, %s)"
             newval
             oldval
             operation
             where))

  (add-to-list 'major-mode-change-watcher-functions
               #'my/major-mode-change-watcher-test)
  
  (major-mode-change-watcher-mode t))
```

