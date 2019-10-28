;; 
;; show-facts.scm
;;

;; (require fact.scm)
(load "more-tests/fact.scm")

(define (show-facts N)
  (format #t "~2D! = ~D~%" N (fact N))
  (if (> N 1)
      (show-facts (- N 1))))

(show-facts 15)
