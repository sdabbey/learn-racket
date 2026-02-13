;;;
;;; Exercise 42. Modify the interpretation of the sample data definition so that a state denotes the
;;; x-coordinate of the right-most edge of the car.
;;;

;; Here are the changes in the logic:
;; render now places the car by centring it at (- cw half-width);
;; X-CAR-START is the car's width (right edge when the car's left edge is at 0).
;; X-CAR-STOP is BACKGROUND-WIDTH + car-width (right edge when the car goes off-screen).

;; New physical constants
(define CAR-W (image-width CAR))
(define X-CAR-START-RIGHTMOST (image-width CAR))
(define X-CAR-STOP-RIGHTMOST BACKGROUND-WIDTH)
(define Y-CAR-RIGHTMOST (- BACKGROUND-HEIGHT (/ (image-height CAR) 2)))

;; WorldState -> Image
;; Place the car so that its centre takes into account Y-CAR-RIGHTMOST
(define (render-rightmost cw)
  (place-image CAR
               (- cw (/ CAR-W 2))
               Y-CAR-RIGHTMOST
               BACKGROUND))

;; WorldState String -> WorldState 
(define (keystroke-handler-rightmost cw ke)
  (cond
    [(equal? ke "b") X-CAR-START-RIGHTMOST]
    [(equal? ke "e") X-CAR-STOP-RIGHTMOST]
    [else cw]))

;; WorldState -> Boolean
(define (end?-rightmost cw)
  (> cw X-CAR-STOP-RIGHTMOST))

;; WorldState -> Image
;; When needed, big-bang obtains the image of the current state of the world.
;; In this case, it places the CAR on BACKGROUND+TREE at cw (x-value).
(define (render-with-tree-rightmost cw)
  (place-image CAR
               (- cw (/ CAR-W 2))
               Y-CAR-RIGHTMOST
               BACKGROUND+TREE))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Provide a hook to start the animation, and tell big-bang which functions to call
(define (main-with-tree-rightmost cw)
  (big-bang cw
            [to-draw render-with-tree-rightmost]
            [on-tick clock-tick-handler] ;; No changes here
            [on-key keystroke-handler-rightmost]
            [stop-when end?-rightmost]))

;; Start with car at X-CAR-START-RIGHTMOST
(main-with-tree-rightmost X-CAR-START-RIGHTMOST)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Testing
(check-expect (render-rightmost (+ (/ CAR-W 2) 25))
              (place-image CAR 25 Y-CAR-RIGHTMOST BACKGROUND))
(check-expect (render-rightmost (+ (/ CAR-W 2) 75))
              (place-image CAR 75 Y-CAR-RIGHTMOST BACKGROUND))

(check-expect (keystroke-handler-rightmost 20 "a") 20)
(check-expect (keystroke-handler-rightmost 20 "b") X-CAR-START-RIGHTMOST)
(check-expect (keystroke-handler-rightmost 20 "e") X-CAR-STOP-RIGHTMOST)

(check-expect (end?-rightmost (+ X-CAR-STOP-RIGHTMOST 1)) #true)
(check-expect (end?-rightmost 30) #false)

;;;
;;; Exercise 43. Let’s work through the same problem statement with a time-based data definition:
;;;
;;; An AnimationState is a Number.
;;; Interpretation: the number of clock ticks since the animation started
;;;
;;; Like the original data definition, this one also equates the states of the world with the class of
;;; numbers. Its interpretation, however, explains that the number means something entirely different.
;;; Design the functions tock and render. Then develop a big-bang expression so that once again you
;;; get an animation of a car traveling from left to right across the world’s canvas.
;;;

;; AnimationState -> AnimationState
;; Add 1 tick each clock tick
(define (clock-tick-handler-animation ticks)
  (+ ticks SPEED))

;; AnimationState -> Image
;; Render the car with right-most edge at X-CAR-START + ticks
(define (render-animation ticks)
  (place-image CAR
               ticks
               Y-CAR
               BACKGROUND+TREE))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Provide a hook to start the animation, and tell big-bang which functions to call
(define (main-animation cw)
  (big-bang cw
            [to-draw render-animation]
            [on-tick clock-tick-handler-animation] ;; No changes here
            [on-key keystroke-handler]
            [stop-when end?]))

;; Start with car at X-CAR-START
(main-animation X-CAR-START)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;; Exercise 43 Continued. Use the data definition to design a program that moves the car according to
;;; a sine wave. (Don’t try to drive like that.)
;;;

;; AnimationState -> AnimationState
;; Add 1 tick each clock tick
(define (clock-tick-handler-animation-sine x)
  (+ x (+ SPEED (* (+ 1 (sin x)) 3))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Provide a hook to start the animation, and tell big-bang which functions to call
(define (main-animation-sine cw)
  (big-bang cw
            [to-draw render-animation]
            [on-tick clock-tick-handler-animation-sine] ;; No changes here
            [on-key keystroke-handler]
            [stop-when end?]))

;; Start with car at X-CAR-START
(main-animation-sine X-CAR-START)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;; Exercise 43 Continued Again.  How do you think this program relates to animate from Prologue: How
;;; to Program?
;;;
;;; Animate works only with ticks.  Big-bang can use any world-state, not just ticks; and we need to
;;; provide the handlers that update the state.
;;;

;;;
;;; Exercise 44 — tests for `hyper`
;;;

;; Testing
(check-expect (hyper 21 10 20 "enter") 21)
(check-expect (hyper 42 10 20 "button-down") 10)
(check-expect (hyper 42 10 20 "move") 42)

; WorldState Number Number String -> WorldState
; Place the car at x-mouse if me is "button-down"
(define (hyper x-position-of-car x-mouse y-mouse me)
  (if (string=? "button-down" me)
      x-mouse
      x-position-of-car))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Provide a hook to start the animation, and tell big-bang which functions to call
(define (main-mouse cw)
  (big-bang cw
            [to-draw render-animation]
            [on-tick clock-tick-handler-animation] ;; No changes here
            [on-key keystroke-handler]
            [on-mouse hyper]
            [stop-when end?]))

;; Start with car at X-CAR-START
(main-mouse X-CAR-START)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;; Exercise 44. Formulate the examples as BSL tests. Click RUN and watch them fail.
;;;

(check-expect (hyper 21 10 20 "enter") 21)
(check-expect (hyper 42 10 20 "button-down") 10)
(check-expect (hyper 42 10 20 "move") 42)
