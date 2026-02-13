
#lang htdp/bsl
(require 2htdp/image) ;; Load image support
(require test-engine/racket-tests) ;; Load check-expect; not needed for DrRacket

;;;
;;; Exercise 39. Good programmers ensure that an image such as CAR can be enlarged or reduced via a
;;; single change to a constant definition.Good programmers establish a single point of control for
;;; all aspects of their programs, not just the graphical constants. Several chapters deal with this
;;; issue. We started the development of our car image with a single plain definition:
;;;
;;; (define WHEEL-RADIUS 5)
;;;
;;; The definition of WHEEL-DISTANCE is based on the wheel’s radius. Hence, changing WHEEL-RADIUS
;;; from 5 to 10 doubles the size of the car image. This kind of program organization is dubbed single
;;; point of control, and good design employs this idea as much as possible.
;;;
;;; Develop your favourite image of an automobile so that WHEEL-RADIUS remains the single point of
;;; control.
;;;

;; Physical constants
(define WHEEL-RADIUS 5)
(define WHEEL-DISTANCE (+ WHEEL-RADIUS 5))

;; Graphical constants
(define WHEEL (circle WHEEL-RADIUS "solid" "black")) ; a single black wheel
(define SPACE (rectangle (* WHEEL-RADIUS 4) 0 "outline" "white")) ; space to put between wheels
(define BOTH-WHEELS (beside WHEEL SPACE WHEEL)) ; Connect wheels and space

(define CAR-BODY
  (rectangle (* WHEEL-RADIUS 8) (* WHEEL-RADIUS 2) "solid" "red")) ; large red car body

(define CAR-TOP
  (rectangle (* WHEEL-RADIUS 4) (* WHEEL-RADIUS 2) "solid" "blue")) ; smaller blue car top

;; CAR = CAR-TOP above CAR-BODY above BOTH-WHEELS
(define CAR
  (above CAR-TOP CAR-BODY BOTH-WHEELS))

;; Calculate the background according tho the size of the car
(define BACKGROUND-WIDTH (* (image-width CAR) 8))
(define BACKGROUND-HEIGHT (* (image-height CAR) 2))
(define BACKGROUND (empty-scene BACKGROUND-WIDTH BACKGROUND-HEIGHT))

;; Display the image
(place-image CAR
             (image-width CAR)
             (- BACKGROUND-HEIGHT (/ (image-height CAR) 2))
             BACKGROUND)

;;; 
;;; Exercise 40. Formulate the examples as BSL tests, that is, using the check-expect form. Introduce
;;; a mistake. Re-run the tests. 
;;;
;;; WorldState -> WorldState 
;;; moves the car by 3 pixels for every clock tick
;;; examples: 
;;;   given: 20, expect 23
;;;   given: 78, expect 81
;;;
(define (tock cw)
  (+ cw 3))

;; Testing
(check-expect (tock 20) 23)
(check-expect (tock 78) 81)

;;;
;;; Exercise 41. Finish the sample problem and get the program to run. That is, assuming that you have
;;; solved exercise 39, define the constants BACKGROUND and Y-CAR. Then assemble all the function
;;; definitions, including their tests. When your program runs to your satisfaction, add a tree to the
;;; scenery. We used:
;;;
;;; (define tree
;;;  (underlay/xy (circle 10 "solid" "green")
;;;               9 15
;;;              (rectangle 2 20 "solid" "brown")))
;;;
;;; to create a tree-like shape. Also add a clause to the big-bang expression that stops the animation
;;; when the car has disappeared on the right side.
;;;
(require 2htdp/universe)

;; Additional physical constants
(define SPEED (/ WHEEL-RADIUS 2))

(define Y-CAR (- BACKGROUND-HEIGHT (/ (image-height CAR) 2)))
(define X-CAR-START (/ (image-width CAR-BODY) 2))
(define X-CAR-STOP (- BACKGROUND-WIDTH (/ (image-width CAR-BODY) 2)))

;; WorldState: data representing the current world (cw).  In this case, it will be the 
;; number of pixels between the left border of BACKGROUND and the middle of the car.
;;
;; WorldState -> Image
;; When needed, big-bang obtains the image of the current state of the world.
;; In this case, it places the CAR on BACKGROUND at cw (x-value).
(define (render cw)
    (place-image CAR cw Y-CAR BACKGROUND))

;; WorldState -> WorldState
;; For each tick of the clock, big-bang obtains the next state of the world.
;; In this case, it increases cw by SPEED.
(define (clock-tick-handler cw)
  (+ cw SPEED))

;; WorldState String -> WorldState 
;; For each keystroke, big-bang obtains the next state.
;; In this case: "b" moves the car to the beginning and continues
;;               "e" moves the car to the end and stops
(define (keystroke-handler cw ke)
  (cond
    [(equal? ke "b") X-CAR-START]
    [(equal? ke "e") X-CAR-STOP]
    [else cw])) ;; ignore the keystroke
 
;; WorldState -> Boolean
;; After each event, big-bang evaluates (end? cw).
;; In this case, it determines whether the car is in the stop position.
(define (end? cw)
  (> cw X-CAR-STOP))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Provide a hook to start the animation, and tell big-bang which functions to call
(define (main cw)
  (big-bang cw
            [to-draw render]
            [on-tick clock-tick-handler]
            [on-key keystroke-handler]
            [stop-when end?]))

;; Start with car at X-CAR-START
(main X-CAR-START)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Additional graphical constants (note "tree" not "TREE")
(define tree
  (underlay/xy (circle (* WHEEL-RADIUS 2) "solid" "green")
               9 15
               (rectangle (/ WHEEL-RADIUS 2)
                          (* WHEEL-RADIUS 4) "solid" "brown"))) ;; Drawing of a tree

(define BACKGROUND+TREE
  (place-image tree
               (/ BACKGROUND-WIDTH 2)
               (- BACKGROUND-HEIGHT (/ (image-height tree) 2))
               BACKGROUND))   ; on top of base scene

;; WorldState -> Image
;; When needed, big-bang obtains the image of the current state of the world.
;; In this case, it places the CAR on BACKGROUND at cw (x-value).
(define (render-with-tree cw)
    (place-image CAR cw Y-CAR
                 BACKGROUND+TREE))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Provide a hook to start the animation, and tell big-bang which functions to call
(define (main-with-tree cw)
  (big-bang cw
            [to-draw render-with-tree]
            [on-tick clock-tick-handler]
            [on-key keystroke-handler]
            [stop-when end?]))

;; Start with car at X-CAR-START
(main-with-tree X-CAR-START)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Testing
(check-expect (render 50) (place-image CAR 50 Y-CAR BACKGROUND))
(check-expect (render 100) (place-image CAR 100 Y-CAR BACKGROUND))
(check-expect (render 150) (place-image CAR 150 Y-CAR BACKGROUND))
(check-expect (render 200) (place-image CAR 200 Y-CAR BACKGROUND))

(check-expect (clock-tick-handler 20) (+ SPEED 20))
(check-expect (clock-tick-handler 78) (+ SPEED 78))

(check-expect (keystroke-handler 20 "a") 20)
(check-expect (keystroke-handler 20 "b") X-CAR-START)
(check-expect (keystroke-handler 20 "e") X-CAR-STOP)

(check-expect (end? (+ X-CAR-STOP 1)) #true)
(check-expect (end? 30) #false)



