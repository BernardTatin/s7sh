;;
;; basic-lib.scm
;;


(define *gl_sym* #f)

(define (full-provide sym)
  (let ((symname (symbol->string sym)))
    (let ((directory 
            (let ((current-file (port-filename)))
              (begin
                ;; TODO: verify problems with length
                (format #t "<current-file: ~A~%" current-file)
                (and (memv (current-file 0) '(#\/ #\~ #\.))
                     (substring current-file 
                                0 
                                (- (length current-file) (+ 1 (length symname)))))))))
      (set! *gl_sym* sym)
      (with-let (rootlet)
                (provide *gl_sym*))
      (set! *gl_sym* #f)
      (when (and directory (not (member directory *load-path*)))
        (set! *load-path* (cons directory *load-path*))))))

(full-provide 'basic-lib.scm)

(let ((show-list (lambda (list-name L)
                   (format #t "-------------------------------~%")
                   (format #t "~A~%" list-name)
                   (for-each (lambda(e)
                               (format #t "+ ~A~%" e))
                             L))))

  (show-list "*features*" *features*)
  (show-list "*load-path*:" *load-path*))
