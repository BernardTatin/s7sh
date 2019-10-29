;;================================================================
;;  FileSystem.scm
;;
;;  $Log: FileSystem.scm,v $
;;  Revision 1.7  2000/06/21 19:27:22  Scheme
;;  Joli source
;;
;;  Revision 1.6  2000/06/21 19:22:24  Scheme
;;  Tentatives d'optimisation
;;
;;  Revision 1.5  2000/06/20 20:31:15  Scheme
;;  Introduction des separateurs
;;
;;  Revision 1.4  2000/06/19 20:56:05  Scheme
;;  SuperFileAnalyser : detection des fin de lignes
;;
;;  Revision 1.3  2000/06/14 19:28:11  Scheme
;;  Passage du nom de fichier a OnBegin et OnEnd
;;
;;  Revision 1.2  2000/06/14 19:18:14  Scheme
;;  Version Unix
;;
;;
;;================================================================
;; Analyseur de fichier
(define (FileAnalyser filename OnBegin OnNewChar OnEnd)
  (letrec ((FileLoop
             (lambda(flux)
               (do ((char (read-char flux) (read-char flux)))
                 ((eof-object? char))
                 (OnNewChar char)))))
    (begin 
      (OnBegin filename)
      (call-with-input-file filename FileLoop)
      (OnEnd filename))))
;;----------------------------------------------------------------
(define (SuperFileAnalyser filename OnBegin OnNewChar OnNewLine OnSeparator OnEnd)
  (letrec (
           (CR (integer->char 13))
           (LF (integer->char 10))
           (TAB (integer->char 9))
           (sfaState 'sfaNone)
           (OnCR
             (lambda(c)
               (case sfaState
                 ('sfaNone                (set! sfaState 'sfaCR))
                 ('sfaLF                  (set! sfaState 'sfaLFCR))
                 ('sfaCR    (OnNewLine c) (set! sfaState 'sfaCR))
                 ('sfaLFCR  (OnNewLine c) (set! sfaState 'sfaCR))
                 ('sfaCRLF  (OnNewLine c) (set! sfaState 'sfaCR)))))
           (OnLF
             (lambda(c)
               (case sfaState
                 ('sfaNone                (set! sfaState 'sfaLF))
                 ('sfaLF    (OnNewLine c) (set! sfaState 'sfaLF))
                 ('sfaCR                  (set! sfaState 'sfaCRLF))
                 ('sfaLFCR  (OnNewLine c) (set! sfaState 'sfaLF))
                 ('sfaCRLF  (OnNewLine c) (set! sfaState 'sfaLF)))))
           (OnElse
             (lambda(c)
               (if (not (equal? sfaState 'sfaNone))
                   (begin
                     (OnNewLine c)
                     (set! sfaState 'sfaNone)))
               (OnNewChar c)))

           (locOnNewChar
             (lambda(c)
               (cond ((char=? c #\space) (OnSeparator) (OnElse c))
                     ((char=? c TAB)     (OnSeparator) (OnElse c))
                     ((char=? c LF)      (OnSeparator) (OnLF c))
                     ((char=? c CR)      (OnSeparator) (OnCR c))
                     (else (OnElse c)))))
           (FileLoop
             (lambda(flux)
               (do ((char (read-char flux) (read-char flux)))
                 ((eof-object? char))
                 (locOnNewChar char)))))
    (begin 
      (set! sfaState 'sfaNone)
      (OnBegin filename)
      (call-with-input-file filename FileLoop)
      (OnEnd filename))))
;;================================================================



