;; ======================================================================
;; hexdump.ss
;; ======================================================================

(use extras)
(use posix)

(define (on-fatal-error . messages)
        (display "FATAL ERROR: " (current-error-port))
        (for-each (lambda(e) (display e (current-error-port))) messages)
        (newline (current-error-port))
        (exit 1))

(define do-hexdump
  (lambda(file-name)
	(print "hexdump de " file-name)
	(with-input-from-file file-name
						  (lambda()
							(letrec ((loop
									   (lambda(addr)
										 (let ((c (read-char)))
										   (when (not (eof-object? c))
											 (when (= 0 (modulo addr 16))
											   (let ((saddr (format #f "~X" addr)))
												 (letrec ((saddr-loop
															(lambda(saddr)
															  (if (< (string-length saddr) 8)
																(saddr-loop (string-append "0" saddr))
																saddr))))
												   (printf "~%~A: " (saddr-loop saddr)))))
											 (let* ((cn (char->integer c))
													(hcn (number->string cn 16)))
											   (when (< cn 16)
												 (printf "0"))
											   (printf "~X " cn))
											 (loop (+ 1 addr)))))))
							  (loop 0))))))


(define hexdump
  (lambda(file-name)
	(if (file-read-access? file-name)
	  (do-hexdump file-name)
	  (on-fatal-error "Le fichier " file-name " n'est pas accessible"))))

(define main
  (lambda(args)
	(for-each hexdump args)))

(main (command-line-arguments))
