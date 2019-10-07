;;
;; test-path.scm
;;

(format #t "PATH: ~A~%~%~%" (getenv "PATH"))
(for-each (lambda(element) (format #t "-> ~A~%" element)) *path*)
(format #t "-------------------------------~%")
(for-each (lambda(element)
            (format #t "~A -> ~A~%" (car element) (cdr element)))
          *path-hash*)

