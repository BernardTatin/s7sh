;;
;; fact.scm
;;

(xt-provide 'fact.scm)
(load "stuff.scm")

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

(define-class Int ()
              '((value 0)))

(define (new-Int k)
  (if (not (integer? k))
    #f
    (let ((i (make-Int)))
      (set! (i 'value) k)
      i)))

(define-generic factg)
(define-method (factg (N Int))
               (define (inner-fact acc k)
                 (if (< k 2)
                   acc
                   (inner-fact (* k acc) (- k 1))))

               (inner-fact 1 (N 'value)))

(define-method (decN (N Int))
               (set! (N 'value) (- (N 'value) 1)))

(define-method (incN (N Int))
               (set! (N 'value) (+ (N 'value) 1)))


(define-method (display-fact-N (N Int))
               (let ((vN (N 'value)))
                 (format #t "~A! = ~A~%"
                         vN
                         (factg N))))
(define N (new-Int 5))
(display-fact-N N)
