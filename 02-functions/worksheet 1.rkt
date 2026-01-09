
#lang htdp/bsl
;; ------------------------------------------------------------
;; Part A: Expressions and Evaluation
;; ------------------------------------------------------------

;; 1. Type each of these into the interactions window.
;;
;;    (+ 3 (* 2 5))            ==> 13
;;    (string-append "ben" "nington")  ==> "bennington"
;;    (sqrt (+ (sqr 3) (sqr 4)))      ==> 5

(+ 3 (* 2 5)) ; 13
(string-append "ben" "nington") ; "bennington"
(sqrt (+ (sqr 3) (sqr 4))) ; 5

;; Nested evaluation occurs in the second and third examples:
;; - (string-append ...) has two sub-expressions.
;; - (sqrt (+ (sqr 3) (sqr 4))) has several layers; Stepper
;;   shows evaluation order clearly.


;; ------------------------------------------------------------
;; Part B: Defining and Using Functions
;; ------------------------------------------------------------

;; 2. Define a function `triple` that multiplies a number by 3.

(define (triple n)
  (* 3 n))

;; Tests
(triple 2)   ;; => 6
(triple -4)  ;; => -12
(triple 0)   ;; => 0


;; 3. Define a function `greeting`.

(define (greeting name)
  (string-append "Hello, " name "!"))

;; Tests
(greeting "Alice") ;; => "Hello, Alice!"
(greeting "Bob")   ;; => "Hello, Bob!"


;; ------------------------------------------------------------
;; Part C: Variables and Constants
;; ------------------------------------------------------------

;; 4. Favorite number constant and expression

(define favorite-number 7)
(+ favorite-number 100) ;; => 107

;; 5. After redefining:
(define new-favorite-number 42)
(+ new-favorite-number 100) ;; => 142

;; Explanation:
;; The name `favorite-number` is already bound; so you needed
;; a new name once it has been assigned.


;; ------------------------------------------------------------
;; Part D: Thinking with Functions
;; ------------------------------------------------------------

;; 6. Hypotenuse function

(define (hypotenuse a b)
  (sqrt (+ (sqr a) (sqr b))))

;; Test
(hypotenuse 3 4) ;; => 5


;; 7. Repeat-twice function

(define (repeat-twice s)
  (string-append s s))

;; Test
(repeat-twice "ha") ;; => "haha"


;; ------------------------------------------------------------
;; Part E: Challenge
;; ------------------------------------------------------------

;; 8. Double-words
;; Approach 1: explicitly handle three elements

(define (double-words words)
  (string-append (string-append (first words) (first words))
                 " "
                 (string-append (second words) (second words))
                 " "
                 (string-append (third words) (third words))))


;; Test
(double-words (list "a" "b" "c")) ; "aa bb cc"

;; Approach 2 (preview for later): use map
(define (double-all-words words)
  (if (empty? words) ""
      (string-append (string-append (first words) (first words) " ")
                     (double-all-words (rest words)))))

(double-all-words (list "a" "b" "c" "d"))

;; ------------------------------------------------------------
;; Part F: Drawing
;; ------------------------------------------------------------

;; 9. Use the 2htdp/image teachpack to create the image of a
;;    simple cup. Make sure you can easily change the scale of
;;    the entire image through the use of defined constants.

(require 2htdp/image)

;; Constants for easy scaling
(define image-scale 1)  ; Change this value to scale the entire cup
(define cup-width (* 80 image-scale))
(define cup-height (* 100 image-scale))
(define handle-width (* 20 image-scale))
(define handle-height (* 40 image-scale))
(define rim-width (* 90 image-scale))
(define rim-height (* 8 image-scale))

;; Colors
(define cup-color "lightblue")
(define rim-color "darkblue")
(define handle-color "lightblue")

;; Cup body - main rectangle
(define cup-body 
  (rectangle cup-width cup-height "solid" cup-color))

;; Cup rim - ellipse at the top
(define cup-rim 
  (ellipse rim-width rim-height "solid" rim-color))

;; Handle - made from two ellipses (outer and inner to create hollow effect)
(define handle-outer 
  (ellipse handle-width handle-height "solid" handle-color))

(define handle-inner 
  (ellipse (* handle-width 0.6) (* handle-height 0.6) "solid" "white"))

(define cup-handle 
  (overlay handle-inner handle-outer))

;; Combine the cup body and rim
(define cup-with-rim 
  (overlay/offset cup-rim 0 (- (/ cup-height 2) (/ rim-height 2)) cup-body))

;; Add the handle to the right side
(define simple-cup 
  (beside cup-with-rim cup-handle))

;; Display the cup
simple-cup

;; We can also scale the completed image by using the scale function
(define small-cup 
  (scale 0.5 simple-cup))

(define large-cup 
  (scale 1.5 simple-cup))

;; Display different sizes side by side
(beside small-cup 
        (rectangle 20 1 "solid" "white")  ; spacer
        simple-cup 
        (rectangle 20 1 "solid" "white")  ; spacer
        large-cup)


