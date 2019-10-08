;; 
;; path-to-list.scm
;;

(define-constant *HASH-TABLE-SIZE* 8192)

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

(define file-exec? 
  (let () 
    (c-define '((int X_OK) (int access (char* int))) 
              "" 
              "unistd.h") 
    (lambda (arg) (= (access arg X_OK) 0))))

(define (fill-path-hash path)
  (let ((the-hash (make-hash-table *HASH-TABLE-SIZE*)))
    (define (explore-path path)
      (define (add-file file)
        (let ((full-path (string-append path "/" file)))
          (when (and (file-exec? full-path)
                     (not (the-hash file)))
            (set! (the-hash file) full-path))))
      (let ((all-files (directory->list path)))
        (for-each add-file all-files)))
    (begin
      (for-each explore-path path)
      the-hash)))

(define *path* '())
(define *path-hash* '())


(define (init-path new-path)
  (set! *path* (path-to-list new-path))
  (set! *path-hash* (fill-path-hash *path*)))

(init-path (getenv "PATH"))
