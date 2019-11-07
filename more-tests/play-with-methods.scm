;;
;; play-with-methods
;;

(xt-require 'stuff.scm)
(xt-require 'write.scm)

(define-macro (for-int idx from to initialize . body)
              `(let ()
                 (begin
                   ,initialize)
                 (define (ifrom ,idx)
                   (when (< ,idx ,to)
                     (begin
                       ,@body)
                       (ifrom (+ ,idx 1))))
                 (ifrom ,from)))
(pretty-expand
  (for-int k 0 15
           (begin
             (format #t "Fact from 0 to 14")
             (define nK (new-Int 0)))
           (format #t "~3D -- " k)
           (display-fact-N nK)
           (incN nK)))

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
                 (format #t "~3D! = ~A~%"
                         vN
                         (factg N))))
(for-int k 0 15
           (begin
             (format #t "Fact from 0 to 14~%")
             (define nK (new-Int 0)))
           (format #t "~3D -- " k)
           (display-fact-N nK)
           (incN nK))

(for-int k 0 15
           (begin
             (format #t "Fact from 14 to 0~%")
             (define nK (new-Int 14)))
           (format #t "~3D -- " k)
           (display-fact-N nK)
           (decN nK))
