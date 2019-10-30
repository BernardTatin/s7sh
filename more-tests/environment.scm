;;
;; environment.scm
;;

(provide 'environment.scm)

(if (not (defined? '*t-env*))
  (define *t-env*
    (with-let (unlet)
              (let ((show-me (lambda(msg)
                (format #t "This is env (~A)~%" msg))))
              (show-me "*t-env* is loading...")
    (curlet)))))

*t-env*
