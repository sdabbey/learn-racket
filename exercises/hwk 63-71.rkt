
#lang htdp/bsl
;;;
;;; Exercise 63. Evaluate the following expressions:
;;;
;;; (distance-to-0 (make-posn 3 4))
;;; (distance-to-0 (make-posn 6 (* 2 4)))
;;; (+ (distance-to-0 (make-posn 12 5)) 10)
;;;
;;; by hand. Show all steps. Assume that sqr performs its computation in a single step. Check the
;;; results with DrRacket’s stepper. 
;;;
;; distance-to-0 : Posn -> Number
(define (distance-to-0 p)
  (sqrt (+ (sqr (posn-x p))
           (sqr (posn-y p)))))

(distance-to-0 (make-posn 3 4))
;; → (sqrt (+ (sqr (posn-x (make-posn 3 4)))
;;            (sqr (posn-y (make-posn 3 4)))))
;; → (sqrt (+ (sqr 3)   ; (posn-x (make-posn 3 4)) → 3
;;            (sqr 4))) ; (posn-y (make-posn 3 4)) → 4
;; → (sqrt (+ 9 16))
;; → (sqrt 25)
;; → 5

(distance-to-0 (make-posn 6 (* 2 4)))
;; → (distance-to-0 (make-posn 6 8))                 ; (* 2 4) → 8
;; → (sqrt (+ (sqr (posn-x (make-posn 6 8)))
;;            (sqr (posn-y (make-posn 6 8)))))
;; → (sqrt (+ (sqr 6)   ; (posn-x (make-posn 6 8)) → 6
;;            (sqr 8))) ; (posn-y (make-posn 6 8)) → 8
;; → (sqrt (+ 36 64))
;; → (sqrt 100)
;; → 10

(+ (distance-to-0 (make-posn 12 5)) 10)
;; → (+ (sqrt (+ (sqr (posn-x (make-posn 12 5)))
;;               (sqr (posn-y (make-posn 12 5))))) 10)
;; → (+ (sqrt (+ (sqr 12)      ; (posn-x (make-posn 12 5)) → 12
;;               (sqr 5))) 10) ; (posn-x (make-posn 12 5)) → 5
;; → (+ (sqrt (+ 144 25)) 10)
;; → (+ (sqrt 169) 10)
;; → (+ 13 10)
;; → 23

;;;
;;; Exercise 64. The Manhattan distance of a point to the origin considers a path that follows the
;;; rectangular grid of streets found in Manhattan. See the images as examples. The left image shows a
;;; “direct” strategy, going as far left as needed, followed by as many upward steps as needed. In
;;; comparison, the right image shows a “random walk” strategy, going some blocks leftward, some
;;; upward, and so on until the destination—here, the origin—is reached.
;;;
;;; Stop! Does it matter which strategy you follow? <no>
;;;
;;; Design the function manhattan-distance, which measures the Manhattan distance of the given posn to
;;; the origin. 
;;;

;; Signature, Purpose
;; manhattan-distance : Posn -> Number
;; Compute the Manhattan distance from the origin (0,0) to the given position p.

;; Examples (and tests):
(check-expect (manhattan-distance (make-posn 3 4)) 7)
(check-expect (manhattan-distance (make-posn -5 2)) 7)
(check-expect (manhattan-distance (make-posn 0 0)) 0)

;; Template:
;; (define (manhattan-distance p)
;;   (... (posn-x p) (posn-y p) ...))

;; Definition:
(define (manhattan-distance p)
  (+ (abs (posn-x p))
     (abs (posn-y p))))

;;;
;;; Exercise 65. Take a look at the following structure type definitions:
;;;
;;;     (define-struct movie [title producer year])
;;;     (define-struct person [name hair eyes phone])
;;;     (define-struct pet [name number])
;;;     (define-struct CD [artist title price])
;;;     (define-struct sweater [material size producer])
;;;
;;; Write down the names of the functions (constructors, selectors, and predicates) that each
;;; introduces. 
;;;

#|

(define-struct movie [title producer year])
Constructor: make-movie
Predicate: movie?
Selectors:
  movie-title
  movie-producer
  movie-year

(define-struct person [name hair eyes phone])
Constructor: make-person
Predicate: person?
Selectors:
  person-name
  person-hair
  person-eyes
  person-phone

(define-struct pet [name number])
Constructor: make-pet
Predicate: pet?
Selectors:
  pet-name
  pet-number

(define-struct CD [artist title price])
Constructor: make-CD
Predicate: CD?
Selectors:
  CD-artist
  CD-title
  CD-price

(define-struct sweater [material size producer])
Constructor: make-sweater
Predicate: sweater?
Selectors:
  sweater-material
  sweater-size
  sweater-producer
|#

;;;
;;; Exercise 66. Revisit the structure type definitions of exercise 65. Make sensible guesses as to
;;; what kind of values go with which fields. Then create at least one instance per structure type
;;; definition. 
;;;

;; ------------------------------------------------------------
;; Data types (informal “type” notes):
;;
;; movie:
;;   title    : String
;;   producer : String
;;   year     : Natural (e.g., 1888..2100)
;;
;; person:
;;   name  : String
;;   hair  : String  ; e.g., "brown" "blonde" "black" "gray"
;;   eyes  : String  ; e.g., "blue" "green" "brown" "hazel"
;;   phone : String  ; keep phone numbers as strings
;;
;; pet:
;;   name   : String
;;   number : Natural ; tag / license number
;;
;; CD:
;;   artist : String
;;   title  : String
;;   price  : NonnegatveNumber ; e.g., 0, 12.99, etc.
;;
;; sweater:
;;   material : String ; e.g., "wool" "cotton" "acrylic"
;;   size     : String ; one of "XS" "S" "M" "L" "XL"
;;   producer : String
;; ------------------------------------------------------------

;;;
;;; Exercise 67. Here is another way to represent bouncing balls:
;;;
;;;     (define SPEED 3)
;;;     (define-struct balld [location direction])
;;;     (make-balld 10 "up")
;;;
;;; Interpret this code fragment and create other instances of balld. 

(define SPEED 3)
(define-struct balld [location direction])

;; Interpretation:
;; A (balld loc dir) represents a bouncing ball.
;; - loc is the number of pixels from the top of the scene.
;; - dir is a string, either "up" or "down".
;; SPEED is constant (3 pixels per tick).

;; Examples:
(make-balld 10 "up")     ; 10 pixels from top, moving up
(make-balld 50 "down")   ; 50 pixels from top, moving down
(make-balld 0 "down")    ; at top, moving down
(make-balld 100 "up")    ; near bottom, moving up

;;;
;;; Exercise 68. An alternative to the nested data representation of balls uses four fields to keep
;;; track of the four properties: 
;;;

(define-struct ballf [x y deltax deltay])

;;; Programmers call this a flat representation. Create an instance of ballf that has the same
;;; interpretation as ball1.

;; Interpretation:
;; A (make-ballf x y deltax deltay) represents a ball with location (x, y) and velocity (deltax,
;; deltay). Each clock tick, the new position is: (x + deltax, y + deltay)
;;
;; ball1 => (make-ball (make-posn 30 40) (make-vel -10 5))
;; So:
;;   x => 30
;;   y => 40
;;   deltax => -10
;;   deltay => 5

;; To do this using ballf:
(make-ballf 30 40 -10 5)

;;;
;;; Exercise 70. Spell out the laws for these structure type definitions:

(define-struct centry [name home office cell])
(define-struct phone [area number])

;;; Use DrRacket’s stepper to confirm 101 as the value of this expression:
;;;
;;;     (phone-area
;;;      (centry-office
;;;       (make-centry "Shriram Fisler"
;;;         (make-phone 207 "363-2421")
;;;         (make-phone 101 "776-1099")
;;;         (make-phone 208 "112-9981")))) 
;;;

;; Selector laws for centry:
;; (centry-name   (make-centry n h o c)) ; n
;; (centry-home   (make-centry n h o c)) ; h
;; (centry-office (make-centry n h o c)) ; o
;; (centry-cell   (make-centry n h o c)) ; c

;; Selector laws for phone:
;; (phone-area   (make-phone a num)) ; a
;; (phone-number (make-phone a num)) ; num

;; Step by step, using the laws:
;;
;; (phone-area ...)
;; Apply centry-office law => (make-phone 101 "776-1099")
;; Apply phone-area law    => 101

;;;
;;; Exercise 71. Place the following into DrRacket’s definitions area:
;;;

;;; Distances in terms of pixels:
(define HEIGHT 200)
(define MIDDLE (quotient HEIGHT 2))
(define WIDTH  400)
(define CENTER (quotient WIDTH 2))
  
(define-struct game [left-player right-player ball])
  
(define game0
  (make-game MIDDLE MIDDLE (make-posn CENTER CENTER)))

;;; Click RUN and evaluate the following expressions:

(game-ball game0)
(posn? (game-ball game0))
(game-left-player game0)

;;;
;;; Explain the results with step-by-step computations. Double-check your computations with DrRacket’s
;;; stepper. 
;;;

;; Selector laws for game and posn:
;; (game-left-player  (make-game lp rp b)) ; lp
;; (game-right-player (make-game lp rp b)) ; rp
;; (game-ball         (make-game lp rp b)) ; b
;; (posn?             (make-posn x y))     ; #true

;; Step by step, using the laws:

;; (game-ball game0)
;; Apply game-ball law => (make-posn CENTER CENTER)
;; Where CENTER => (quotient WIDTH 2) 
;; Where WIDTH  => 400
;; So    CENTER => (quotient 400 2) => 200
;; So    (make-posn 200 200)

;; (posn? (game-ball game0))
;; (posn? (make-posn 200 200)) ; From above
;; Apply posn? law => #true

;; (game-left-player game0)
;; (game-left-player (make-game MIDDLE MIDDLE (make-posn 200 200)))
;; (game-left-player MIDDLE) => 200

