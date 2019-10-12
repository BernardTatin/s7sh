;;
;; test-path.scm
;;

(require path-to-list)

(let ((show-list (lambda (list-name L)
                   (format #t "-------------------------------~%")
                   (format #t "~A~%" list-name)
                   (for-each (lambda(e)
                               (format #t "+ ~A~%" e))
                             L))))

  (show-list "*load-path*:" *load-path*)
  (show-list "*features*:" *features*)
  (show-list "*path*:" *path*)
  (format #t "-------------------------------~%")
  (format #t "PATH: ~A~%" (getenv "PATH"))
  (format #t "-------------------------------~%"))

#|
(for-each (lambda(element)
            (format #t "~A -> ~A~%" (car element) (cdr element)))
          *path-hash*)
|#

