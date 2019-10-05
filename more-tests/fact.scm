;; 
;; fact.scm
;;

(define (fact N)
  (define (inner-fact acc k)
    (if (< k 2)
        acc
        (inner-fact (* k acc) (- k 1))))

  (inner-fact 1 N))
