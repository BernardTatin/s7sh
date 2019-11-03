;;
;; environment.scm
;;
;; Using with-let and curlet

(xt-provide 'environment.scm)
(load "write.scm")

;; ======================================================================
;; this is the taemplate to define a new environment
;; I can't make a macro for this template with let
(when (not (defined? '*t-env-0*))
  (define *t-env-0*
    (with-let (unlet)
              (begin
                (let ((show-me (lambda(msg)
                                 (format #t "This is env (~A)~%" msg))))
                  (show-me "*t-env-0* is loading... loading...")
                  (curlet))))))

;; create the environment
*t-env-0*
;; test it
((*t-env-0* 'show-me) "oh... we are testing *t-env-0* !!!")

;; ======================================================================
;; a macro for the definition of a new environment
(define-macro (define-new-env env-name . body)
              `(when (not (defined? ',env-name))
                 (define ,env-name
                   (with-let (unlet)
                             (begin
                               ,@body
                               (curlet))))))

;; ======================================================================
;; a macro for a pretty print of macroexpand
(if (defined? 'pretty-expand)
  (format #t "pretty-expand already defined~%")
  (begin
    (format #t "pretty-expand must be defined~%")
    (define-macro (pretty-expand . body)
                  `(begin
                     (format #t "~%~%")
                     (pretty-print (macroexpand ,@body))
                     (format #t "~%~%")))))

;; using it
(pretty-expand
  (define-new-env *t-env*
                  (define (show-me msg)
                    (format #t "This is env (~A)~%" msg))
                  (define (re-show-me msg)
                    (format #t "This is env, one more time (~A)~%" msg))
                  (show-me "*t-env* is loading... loading...")
                  (re-show-me "*t-env* is loaded ?")))

;; ======================================================================
;; definition of a new environment
(define-new-env *t-env*
                (define (show-me msg)
                  (format #t "This is env (~A)~%" msg))
                (define (re-show-me msg)
                  (format #t "This is env, one more time (~A)~%" msg))
                (show-me "*t-env* is loading... loading...")
                (re-show-me "*t-env* is loaded ?"))

;; creation of the environment
*t-env*
;;; simple test
((*t-env* 'show-me) "oh... we are testing *t-env* !!!")
((*t-env* 're-show-me) "oh... we are testing *t-env* !!!")
