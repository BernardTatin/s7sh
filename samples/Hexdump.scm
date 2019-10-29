;;================================================================
;; Hexdump.scm
;; Dump hexa de fichiers
;;
;;  $Log: Hexdump.scm,v $
;;  Revision 1.5  2000/06/14 19:20:29  Scheme
;;  Des blancs en plus
;;
;;  Revision 1.4  2000/06/11 21:01:29  Scheme
;;  Ca marche nickel, et sous forme de script GUILE !!
;;
;;  Revision 1.3  2000/06/11 20:41:17  Scheme
;;  Fonctionne bien avec gsi et guile sous Linux,
;;  ET AVEC DES MACROS
;;
;;  Revision 1.2  2000/06/11 20:10:29  Scheme
;;  Fonctionne bien sous Linux gsi
;;
;;  Revision 1.1  2000/06/11 19:14:49  Scheme
;;  Initial revision
;;
;;
;;================================================================
(load "samples/FileSystem.scm")
;;================================================================
;; remplissage d'une chaine de caracteres avec des 0
;; A GAUCHE
(define (zpad str len)
  (let ((l (string-length str) ))
    (if (< l len)
        (string-append (make-string (- len l) #\0) str)
        str)))
;;------------------------------------------------------
;; Variables du systeme
;;
(define *hex-col* 0)      ;; numero de colone en cours (de 0 a 15)
(define *hex-ascii* "")   ;; l'ascii
(define *hex-hex* "")     ;; l'hexa
(define *hex-adr* 0)      ;; l'adresse
;;------------------------------------------------------
;; transforme un nombre en chaine ASCII / HEXA
(define-macro (number-hexstr n)
              `(number->string ,n 16))
;;------------------------------------------------------
;; d'entier a  hexa pour affichage
(define-macro (format-hex value lng)
              `(zpad (number-hexstr ,value) ,lng))
;;------------------------------------------------------
;; transformation d'un caractere en sa valeur hexa
;; le retour est une chaine de caractere, pour l'affichage
(define (char->hex char)
  (let ((n (char->integer char) ))
    (if (< n 16)
        (string-append "0" (number-hexstr n) )
        (number-hexstr n))))
;;------------------------------------------------------
;; reset des variables de fonctionnement du dump
(define (loc-hex-reset)
  (begin
    (set! *hex-col* 0)
    (set! *hex-ascii* "")
    (set! *hex-hex* "")))
;;------------------------------------------------------
;; meme que ci-dessus, avec RAZ de l'adresse
(define (loc-hex-reset-all . rest)
  (begin
    (loc-hex-reset)
    (set! *hex-adr* 0)))
;;------------------------------------------------------
;; remplissage a DROITE d'une chaine avec des espaces
(define (fill-with-space s l)
  (if (>= (string-length s) l)
      s
      (fill-with-space (string-append s " ") l)))
;;------------------------------------------------------
;; affichage d'une ligne
(define (loc-hex-disp)
  (let ((str (string-append  (format-hex *hex-adr* 8)
                             ": "
                             *hex-hex*
                             " '"
                             *hex-ascii*
                             "'")))
    (begin
      (display str)
      (newline)
      (set! *hex-adr* (+ *hex-adr* 16)))))
;;------------------------------------------------------
;; dernier affichage
(define (last-hex-disp . rest)
  (begin
    (display (format-hex *hex-adr* 8))
    (display ": ")
    (display (fill-with-space *hex-hex* 48))
    (display " '")
    (display *hex-ascii*)
    (display "'")
    (newline)
    (set! *hex-adr* (+ *hex-adr* 16))))
;;------------------------------------------------------
;; ajout d'un caractère
(define (loc-hex-addchar char)
  (let
    ;; Linux n'aime pas toujours les caractËres dont le bit 7 est ‡ 1
    ;; Alors, on sucre
    ((get-good-ascii
       (lambda(c)
         (cond ((char<? c #\space) ".")
               ((char>? c (integer->char 127)) ".")
               (else (make-string 1 c)))))) ; fin du let

    (begin
      (set! *hex-ascii* (string-append *hex-ascii* (get-good-ascii char)))
      (set! *hex-hex* (string-append *hex-hex* (char->hex char) " "))
      (set! *hex-col* (+ *hex-col* 1))
      (if (= *hex-col* 16)
          (begin
            (loc-hex-disp)
            (loc-hex-reset))))))
;;------------------------------------------------------
;; dump hexa d'un fichier SANS récursivité
(define (hexdump filname)
  (FileAnalyser filname loc-hex-reset-all loc-hex-addchar last-hex-disp))
(define (lhexdump l)
  (if (null? l)
      '()
      (begin
        (let ((filename (car l)))
          (display filename)
          (newline)
          (hexdump filename)
          (lhexdump (cdr l))))))
;;================================================================
;; pour guile : command-line est une fonction renvoyant la liste de 
;; -- le ligne de commande.
;; dans ces conditions, la ligne suivante fonctionne BIEN
;; (lhexdump (command-line))
(hexdump "samples/hexdump.ss")
;;================================================================
