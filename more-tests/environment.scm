;;
;; environment.scm
;;

(xt-provide 'environment.scm)

(when (not (defined? '*t-env*))
  (define *t-env*
    (with-let (unlet)
              (let ((show-me (lambda(msg)
                (format #t "This is env (~A)~%" msg))))
              (show-me "*t-env* is loading... loading...")
    (curlet)))))

*t-env*

;;; simple test
((*t-env* 'show-me) "oh... we are testing *t-env* !!!")
