;; ------------------------------------------------------------
;; Example A. string-double
;; ------------------------------------------------------------

;; 1. Data:
;; Strings represent written information.

;; 2. Signature, Purpose, Header:
;; String -> String
;; Double the given string by appending it to itself.
;; (define (string-double str) "a") ; stub

;; 3. Examples:
;; "a"    -> "aa"
;; "hi"   -> "hihi"
;; "123"  -> "123123"

;; 4. Template:
;; (define (string-double str) (... str ...))

;; 5. Definition:
(define (string-double str)
  (string-append str str))

;; 6. Tests:
(check-expect (string-double "a") "aa")
(check-expect (string-double "hi") "hihi")
(check-expect (string-double "123") "123123")
