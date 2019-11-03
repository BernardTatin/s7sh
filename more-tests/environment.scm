;;
;; environment.scm
;;
;; Using with-let and curlet

(xt-provide 'environment.scm)
(load "write.scm")

(when (not (defined? '*t-env-0*))
  (define *t-env-0*
    (with-let (unlet)
              (begin
                (let ((show-me (lambda(msg)
                                 (format #t "This is env (~A)~%" msg))))
                  (show-me "*t-env-0* is loading... loading...")
                  (curlet))))))

*t-env-0*
((*t-env-0* 'show-me) "oh... we are testing *t-env-0* !!!")

(define-macro (define-new-env env-name . body)
              `(when (not (defined? ',env-name))
                 (define ,env-name
                   (with-let (unlet)
                             (begin
                               ,@body
                               (curlet))))))

(if (defined? 'pretty-expand)
  (format #t "pretty-expand already defined~%")
  (begin
    (format #t "pretty-expand must be defined~%")
    (define-macro (pretty-expand . body)
                  `(begin
                     (format #t "~%~%")
                     (pretty-print (macroexpand ,@body))
                     (format #t "~%~%")))))

(pretty-expand
  (define-new-env *t-env*
                  (define (show-me msg)
                    (format #t "This is env (~A)~%" msg))
                  (define (re-show-me msg)
                    (format #t "This is env, one more time (~A)~%" msg))
                  (show-me "*t-env* is loading... loading...")
                  (re-show-me "*t-env* is loaded ?")))
;; (format #t "~%~%")

(define-new-env *t-env*
                (define (show-me msg)
                  (format #t "This is env (~A)~%" msg))
                (define (re-show-me msg)
                  (format #t "This is env, one more time (~A)~%" msg))
                (show-me "*t-env* is loading... loading...")
                (re-show-me "*t-env* is loaded ?"))

*t-env*
;;; simple test
((*t-env* 'show-me) "oh... we are testing *t-env* !!!")
((*t-env* 're-show-me) "oh... we are testing *t-env* !!!")
