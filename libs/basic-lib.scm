;;
;; basic-lib.scm
;;


;; is sym (a symbol) in *features* ?
(define (in-features? sym)
  (member sym *features*))

;; is path in *load-path* ?
(define (in-load-path? path)
  (member path *load-path*))

;; add directory in *load-path if it is not already present
(define (add-load-path directory)
  (when (not (in-load-path? directory))
    (set! *load-path* (cons directory *load-path*))))

;; quit, alias for exit
(define quit (lambda() (exit)))

;;
;; full-provide sym (a symbol)
;; add sym tu *features,
;; add the directory of the current file to *load-path*
;; TODO: errors management!
;; TODO: must be a macro
;; NOTE: *ql_sym* is a bad hack in case of mult-threading
;; NOTE: or in a simpler way: *ql_sym* is a bad hack 

(define *gl_sym* #f)
(define-macro (full-provide sym)
              `(let ((provide-sym (lambda()
                                    (when (not (in-features? ,sym))
                                      (set! *gl_sym* ,sym)
                                      (with-let (rootlet)
                                                (provide *gl_sym*))
                                      (set! *gl_sym* #f)))))
                 (let ((symname (symbol->string ,sym)))
                   (let ((directory 
                           (let ((current-file (port-filename)))
                             (begin
                               ;; TODO: verify problems with length
                               (format #t "<current-file: ~A~%" current-file)
                               (and (memv (current-file 0) '(#\/ #\~ #\.))
                                    (substring 
                                      current-file 
                                      0 
                                      (- (length current-file) 
                                         (+ 1 (length symname)))))))))
                     (provide-sym)
                     (when (and directory (not (in-load-path? directory)))
                       (set! *load-path* (cons directory *load-path*)))))))

;; using full-provide
(full-provide 'basic-lib.scm)

;; debugging full-provide
(let ((show-list (lambda (list-name L)
                   (format #t "-------------------------------~%")
                   (format #t "~A~%" list-name)
                   (for-each (lambda(e)
                               (format #t "+ ~A~%" e))
                             L))))

  (show-list "*features*" *features*)
  (show-list "*load-path*:" *load-path*))
