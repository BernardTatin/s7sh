;;
;; run-in-path.scm
;;

(let ()
  (c-define '((int fork (void)))
            ""
            "unistd.h")
  (lambda () (fork)))

(let ()
  (c-define '((char** NULL) (int execvp (char* char**)))
            ""
            "unistd.h")
  (lambda (arg) (execvp arg)))

(define (run-in-path program)
  (let ((full-path (*path-hash* program)))
    (if (not full-path)
        (format *stderr* "Cannot find ~A~%" program)
        (begin
          (format *stdout* "Running ~A (~A)~%" program full-path)))))

(let ((progs '("ls" "pipo" "more" "gvim")))
  (for-each run-in-path progs))
