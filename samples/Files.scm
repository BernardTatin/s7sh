;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Files.scm
;; Ensemble de fonction de manip de fichier
;;
;;  $Log: Files.scm,v $
;;  Revision 1.1  2000/06/04 19:48:41  Scheme
;;  Initial revision
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;------------------------------------------------------
;; lecture bete d'un fichier pour afficher a la console
(define (f-cat filname)
  (letrec ((loop
        (lambda(flux) 
          (let ((char (read-char flux)))
            (if (not (eof-object? char))
              (begin (display char)
                (loop flux)))))))
        (begin (call-with-input-file filname loop)
          (newline))
)
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;------------------------------------------------------
;; rempli une chaine avec des zero PAR DEVANT
(define (zpad str len)
  (if (< (string-length str) len)
    (zpad (string-append "0" str) len)
    ;(string-append (make-string (- len (string-length str)) #\0) str) 
    str)
  )          
(define (zpad0 str len)
  (let ((l (string-length str) ))
    (if (< l len)
      (string-append (make-string (- len l) #\0) str) 
      str))
  )          
;;------------------------------------------------------
;; d'entier a hexa pour affichage
(define (format-hex value lng)
     (zpad (number->string value 16) lng))
;;------------------------------------------------------
;; transformation d'un caractere en sa valeur hexa
;; le retour est une chaine de caractere, pour l'affichage
(define (char->hex char)
  (let ((n (char->integer char) ))
    (if (< n 16)
      (zpad (number->string n 16) 2)
      (number->string n 16)))
)      
;;------------------------------------------------------
;; lecture bete d'un fichier pour afficher a la console
;; en hexa
(define *hex-col* 0)
(define *hex-ascii* "")
(define *hex-hex* "")
(define *hex-adr* 0)
(define *hex-point* ".")
;;------------------------------------------------------
;; reset des variables globales du dump
(define (loc-hex-reset)
  (begin
    (set! *hex-col* 0)
    (set! *hex-ascii* "")
    (set! *hex-hex* "")
    ;;(set! *hex-point* (make-string 1 #\.))
    )
  )
(define (loc-hex-reset-all)
  (begin
    (loc-hex-reset)
    (set! *hex-adr* 0)
    )
  )
;;------------------------------------------------------
;; affichage du dump
(define (loc-hex-disp)
  (begin
    (display (format-hex *hex-adr* 8))
    (display ": ")
    (display *hex-hex*)
    (display " '")
    (display *hex-ascii*)
    (display "'")
    (newline)
    (set! *hex-adr* (+ *hex-adr* 16))
    )
  )
;;------------------------------------------------------
;; ajout d'un caractere
(define (char->goodchar c)
  (let ((val (char->integer c)))
    (cond ((< val 0) (integer->char (+ val 128)))
	  ((> val 127) (integer->char (- val 128)))
	  ((char<? c #\space) #\.)
	  (else c)
	  )
    )
)
(define (loc-hex-addchar char)
  (begin 
    (set! *hex-ascii* 
        (string-append *hex-ascii* (make-string 1 (char->goodchar char))
        ))
    (set! *hex-hex* (string-append *hex-hex* (char->hex char) " "))
    (set! *hex-col* (+ *hex-col* 1))
    (if (= *hex-col* 16)
      (begin
        (loc-hex-disp)
        (loc-hex-reset)
        )
      )
    )
  )
;;------------------------------------------------------
;; dump hexa d'un fichier
(define (f-cat-hex filname)
  (letrec ((loop
        (lambda(flux) 
          (let ((char (read-char flux)))
            (if (not (eof-object? char))
              (begin 
                (loc-hex-addchar char)
                (loop flux)))))))
    (begin 
      (loc-hex-reset-all)
      (call-with-input-file filname loop)
      (loc-hex-disp)
      (newline))
    )
  )
;;------------------------------------------------------
;; dump hexa d'un fichier SANS recursivite
(define (do-cat-hex filname)
  (letrec ((loop
        (lambda(flux) 
          (do ((char (read-char flux) (read-char flux)))
            ((eof-object? char))
                (loc-hex-addchar char)))))
    (begin 
      (loc-hex-reset-all)
      (call-with-input-file filname loop)
      (loc-hex-disp)
      (newline))
    )
  )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(time (do-cat-hex "Files.scm"))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; essayer les bad cars : יטחאשךמפû
