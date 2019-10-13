;; /home/bernard/.shs7.scm - created on Oct  9 2019 - 13:17:51

(provide 'shs7.scm)

(when (not *quiet*)
  (begin
    (format #t ".shs7.scm loaded !!!~%")
    (format #t "HOME: ~A~%" *home*)
    (format #t "PATH ~A~%" *base-path*)
    (format #t "EDITOR ~A~%" *editor*)
    (format #t "USER ~A~%" *user*)
    (format #t "*quiet* ~A~%" *quiet*)
    (format #t "*batch* ~A~%" *batch*)))
(define quit (lambda() (exit)))
