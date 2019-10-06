;; 
;; path-to-list.scm
;;

(define (path-to-list path)
  (define (safe-rev-append the-list element)
    (if (not the-list)
        (list element)
        (cons element the-list)))

    (define (mk-path-list acc new-path)
      (let ((position (char-position #\: new-path)))
        (if (not position)
            (reverse (safe-rev-append acc new-path))
            (mk-path-list (safe-rev-append acc (substring new-path 0 position))
                          (substring new-path (+ 1 position))))))
    (mk-path-list '() path))

(define *path* (path-to-list (getenv "PATH")))
