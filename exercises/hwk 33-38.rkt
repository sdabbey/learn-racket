
#lang htdp/bsl
(require 2htdp/image) ;; Load image support
(require test-engine/racket-tests) ;; Load check-expect; not needed for DrRacket

;;;
;;; Exercise 33. Research the “year 2000” problem. 
;;;

#|
The Y2K problem, often called the Millennium Bug, came from the old practice of storing years with
just two digits (e.g., "99” for 1999), when memory was precious. As 2000 approached, many programs
risked reading “00” as 1900, which could disrupt banking transactions, payroll, scheduling, or even
power-grid and air-traffic systems. Throughout the late 1990s, governments and businesses spent
billions reviewing and rewriting code to avoid those errors. Because of that massive effort, January
1, 2000 arrived with only minor hiccups.  This is—a good example of how technical shortcuts can
create long-term "technical debt" and why careful, forward-looking design matters.
|#

;;;
;;; Exercise 34. Design the function `string-first`, which extracts the first character from a non-
;;; empty string. Don’t worry about empty strings. 
;;;

;; 1. Express how you wish to represent information as data.
;; Use the String data type to represent written information.

;; 2. Write down: a signature, a statement of purpose, and a function header.
;; String -> 1String
;; Extract the first character from a non-empty string.
;; (define (string-first str) "a") ;; satisfies the signature and lets us run tests

;; 3. Illustrate the signature and purpose with examples.
;; Given: "a"; Expect: "a"
;; Given: "apple"; Expect: "a"
;; Given: "12345"; Expect: "1"

;; 4. Introduce a function template (this gets more interesting later).
;; (define (string-first str) (... str ...)) ;; outlines the logical structure of the function

;; 5. Write and test the function.
(define (string-first str)
  (substring str 0 1))

;; 6. Test the function.
(string-first "a") ; "a"
(string-first "apple") ; "a"
(string-first "12345") ; "1"

(check-expect (string-first "a") "a") ; "a"
(string-first "apple") ; "a"
(string-first "12345") ; "1"

;;;
;;; Exercise 35. Design the function `string-last`, which extracts the last character from a non-empty
;;; string. 
;;;

;; 1. Express how you wish to represent information as data.
;; Use the String data type to represent written information.

;; 2. Write down: a signature, a statement of purpose, and a function header.
;; String -> 1String
;; Extract the last character from a non-empty string.
;; (define (string-last str) "a")

;; 3. Illustrate the signature and purpose with examples.
;; Given: "a"; Expect: "a"
;; Given: "apple"; Expect: "e"
;; Given: "12345"; Expect: "5"

;; 4. Introduce a function template.
;; (define (string-last str) (... str ...)) ;; lets us know we have "str" to work with

;; 5. Write and test the function.
(define (string-last str)
  (substring str (sub1 (string-length str))))

;; 6. Test the function.
(string-last "a") ; "a"
(string-last "apple") ; "e"
(string-last "12345") ; "5"

;;;
;;; Exercise 36. Design the function `image-area`, which counts the number of pixels in a given image. 
;;;

;; 1. Express how you wish to represent information as data.
;; Use the Image data type to represent pictorial information.

;; 2. Write down: a signature, a statement of purpose, and a function header.
;; Image -> Number
;; Count the number of pixels in a given image.
;; (define (image-area img) 100)

;; 3. Illustrate the signature and purpose with examples.
;; Given: (rectangle 10 5 "solid" "red"); Expect: 50
;; Given: (circle 3 "solid" "blue"); Expect: 36
;; Given: (square 4 "solid" "green"); Expect: 16

;; 4. Introduce a function template.
;; (define (image-area img) (... img ...))

;; 5. Write and test the function.
(define (image-area img)
  (* (image-width img) (image-height img)))

;; 6. Test the function.
(image-area (rectangle 10 5 "solid" "red")) ; 50
(image-area (circle 3 "solid" "blue")) ; 36
(image-area (square 4 "solid" "green")) ; 16

;;;
;;; Exercise 37. Design the function `string-rest`, which produces a string like the given one with
;;; the first character removed. 
;;;
;; 1. Express how you wish to represent information as data.
;; Use the String data type to represent written information.

;; 2. Write down: a signature, a statement of purpose, and a function header.
;; String -> String
;; Produce a string like the given one with the first character removed.
;; (define (string-rest str) "bc")

;; 3. Illustrate the signature and purpose with examples.
;; Given: "abc"; Expect: "bc"
;; Given: "apple"; Expect: "pple"
;; Given: "12345"; Expect: "2345"
;; Given: "a"; Expect: ""

;; 4. Introduce a function template (this gets more interesting later).
;; (define (string-rest str) (... str ...))

;; 5. Write and test the function.
(define (string-rest str)
  (substring str 1))

;; 6. Test the function.
(string-rest "abc") ; "bc"
(string-rest "apple") ; "pple"
(string-rest "12345") ; "2345"
(string-rest "a") ; ""

;;;
;;; Exercise 38. Design the function `string-remove-last`, which produces a string like the given one
;;; with the last character removed. 
;;;

;; 1. Express how you wish to represent information as data.
;; Use the String data type to represent written information.

;; 2. Write down: a signature, a statement of purpose, and a function header.
;; String -> String
;; Produce a string like the given one with the last character removed.
;; (define (string-remove-last str) "ab")

;; 3. Illustrate the signature and purpose with examples.
;; Given: "abc"; Expect: "ab"
;; Given: "apple"; Expect: "appl"
;; Given: "12345"; Expect: "1234"
;; Given: "a"; Expect: ""

;; 4. Introduce a function template (this gets more interesting later).
;; (define (string-remove-last str) (... str ...))

;; 5. Write and test the function.
(define (string-remove-last str)
  (substring str 0 (- (string-length str) 1)))

;; 6. Test the function.
(string-remove-last "abc") ; "ab"
(string-remove-last "apple") ; "appl"
(string-remove-last "a") ; ""


