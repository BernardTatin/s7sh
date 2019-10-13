;; 
;; fact.scm
;;

(provide 'fact.scm)

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

