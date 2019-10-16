;; 
;; fact.scm
;;

(full-provide 'fact.scm)

(define (fact0 N)
  (define (inner-fact acc k)
    (if (< k 2)
        acc
        (inner-fact (* k acc) (- k 1))))

  (inner-fact 1 N))

(define fact 
  (let ()
    (define (inner-fact acc k) 
      (if (< k 2)
          acc
          (inner-fact (* k acc) (- k 1))))
    (lambda (N)
      (inner-fact 1 N))))

(let ((show-list (lambda (list-name L)
                   (format #t "-------------------------------~%")
                   (format #t "~A~%" list-name)
                   (for-each (lambda(e)
                               (format #t "+ ~A~%" e))
                             L))))

  (show-list "*features*" *features*)
  (show-list "*load-path*:" *load-path*))
