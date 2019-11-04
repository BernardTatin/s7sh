# macros

## a good example

```scheme
(define-macro (while test . body)      ; while loop with predefined break and continue
              `(call-with-exit
                 (lambda (break)
                   (let continue ()
                     (if (let () ,test)
                       (begin
                         (let () ,@body)
                         (continue))
                       (break))))))
```
