
#lang htdp/bsl
(require 2htdp/image)
(require 2htdp/universe)
(require test-engine/racket-tests)

;;;
;;; Exercise 48. Enter the definition of reward followed by (reward 18) into the definitions area of
;;; DrRacket and use the stepper to find out how DrRacket evaluates applications of the function. 
;;;

(define (reward s)
  (cond
    [(<= 0 s 10) "bronze"]
    [(<= 10 s 20) "silver"]
    [else "gold"]))

#|

This function gives a reward name based on a score. If the score is between 0 and 10, it returns
"bronze." If it is greater than 10 but no higher than 20, it returns "silver." For any score above 20,
it returns "gold." The function uses a cond expression to check these ranges in order, and the final
else clause covers all remaining cases.

|#

;;;
;;; Exercise 49. A cond expression is really just an expression and may therefore show up in the
;;; middle of another expression:
;;;
;;; (- 200 (cond [(> y 200) 0] [else y]))
;;;
;;; Use the stepper to evaluate the expression for y as 100 and 210. 
;;;

#|
If y = 100, result = 200 - 100 = 100
If y = 210, result = 200 - 0 = 200
|#

;;;
;;; Exercise 49 (continued). Reformulate create-rocket-scene.v5 to use a nested expression; the
;;; resulting function mentions place-image only once.
;;;

(define WIDTH  100)
(define HEIGHT 60)
(define MTSCN  (empty-scene WIDTH HEIGHT))
(define ROCKET (above (triangle 20 "solid" "red")
                      (rectangle 10 25 "solid" "gray")))
(define ROCKET-CENTER-TO-TOP (- HEIGHT (/ (image-height ROCKET) 2)))

(define (create-rocket-scene.v5 h)
  (cond
    [(<= h ROCKET-CENTER-TO-TOP)
     (place-image ROCKET 50 h MTSCN)]
    [(> h ROCKET-CENTER-TO-TOP)
     (place-image ROCKET 50 ROCKET-CENTER-TO-TOP MTSCN)]))

(define (create-rocket-scene.v5a h)
  (place-image ROCKET
               50
               (cond [(<= h ROCKET-CENTER-TO-TOP) h]
                     [else ROCKET-CENTER-TO-TOP])
               MTSCN))

;;;
;;; Exercise 50. If you copy and paste the above function definition into the definitions area of
;;; DrRacket and click RUN, DrRacket highlights two of the three cond lines. This colouring tells you
;;; that your test cases do not cover the full conditional. Add enough tests to make DrRacket happy. 
;;;

(define (traffic-light-next s)
  (cond
    [(string=? s "red") "green"]
    [(string=? s "green") "yellow"]
    [(string=? s "yellow") "red"]))

(check-expect (traffic-light-next "red") "green")
(check-expect (traffic-light-next "green") "yellow")
(check-expect (traffic-light-next "yellow") "red")

;;;
;;; Exercise 51. Design a big-bang program that simulates a traffic light for a given duration. The
;;; program renders the state of a traffic light as a solid circle of the appropriate colour, and it
;;; changes state on every clock tick. 
;;;

(define LIGHT-RADIUS 50)
(define BACKGROUND-WIDTH 200)
(define BACKGROUND-HEIGHT 200)

(define (render-light s)
  (overlay (circle LIGHT-RADIUS "solid" s)
           (empty-scene BACKGROUND-WIDTH BACKGROUND-HEIGHT)))

(define (next-light s) (traffic-light-next s))

(define (traffic-light-simulation s)
  (big-bang s
    [to-draw render-light]
    [on-tick next-light 1]))

(traffic-light-simulation "red")

;;;
;;; Exercise 52. Which integers are contained in the four intervals above?
;;;

#|
[3, 5]  = {3, 4, 5}
(3, 5]  = {4, 5}
[3, 5)  = {3, 4}
(3, 5)  = {4}
|#

;;;
;;; Exercise 53. The design recipe for world programs demands that you translate information into
;;; data and vice versa to ensure a complete understanding of the data definition. 
;;;
;;; An LR (short for launching rocket) is one of:
;;; – "resting"
;;; – NonnegativeNumber
;;; interpretation: "resting" represents a grounded rocket; a number denotes the height of a rocket
;;; in flight. 
;;;

(define ROCKET-ON-PAD "resting")
(define ROCKET-JUST-LAUNCHED 0)
(define HEIGHT-EXAMPLE 100)
(define ROCKET-MID-FLIGHT 50)
(define ROCKET-HIGH 300)

;;;
;;; Exercise 54. Why would it be incorrect to use (string=? "resting" x) as the first condition in
;;; show? Conversely, formulate a completely accurate condition, that is, a Boolean expression that
;;; evaluates to #true precisely when x belongs to the first sub-class of LRCD. 
;;;

#|
(string=? "resting" x) would fail for numeric values.
Correct: (and (string? x) (string=? x "resting"))
|#

;;;
;;; Exercise 55. Take another look at show. It contains three instances of an expression with the
;;; approximate shape:
;;;    (place-image ROCKET 10 (- ... CENTER) BACKG)
;;; Define an auxiliary function that performs this work and thus shorten show.
;;;
;;; (define (show x)
;;;   (cond
;;;     [(string? x)
;;;      (place-image ROCKET 10 (- HEIGHT CENTER) BACKG)]
;;;     [(<= -3 x -1)
;;;      (place-image (text (number->string x) 20 "red")
;;;                   10 (* 3/4 WIDTH)
;;;                   (place-image ROCKET
;;;                                10 (- HEIGHT CENTER)
;;;                                BACKG))]
;;;     [(>= x 0)
;;;      (place-image ROCKET 10 (- x CENTER) BACKG)]))
;;;

(define CENTER (/ (image-height ROCKET) 2))
(define BACKG (empty-scene WIDTH HEIGHT))

(define (place-rocket y)
  (place-image ROCKET 10 (- y CENTER) BACKG))

(define (show x)
  (cond
    [(string? x)                    (place-rocket HEIGHT)]
    [(and (number? x) (<= -3 x -1)) (place-image (text (number->string x) 20 "red")
                                                 75             ; x-pos of text
                                                 (* 3/4 HEIGHT) ; y-pos of text
                                                 (place-rocket HEIGHT))]
    [(and (number? x) (>= x 0))     (place-rocket x)]))

;;;
;;; Exercise 56. Define main2 so that you can launch the rocket and watch it lift off. Read up on the
;;; on-tick clause to determine the length of one tick and how to change it. Add a stop-when clause so
;;; that the simulation stops gracefully when the rocket is out of sight.
;;;

(define (render h)
  (place-rocket h))

(define (out-of-sight? h)
  (<= h 0))

(define (main2 initial-height)
  (big-bang initial-height
    [on-tick sub1 0.1]
    [to-draw render]
    [stop-when out-of-sight?]))

(main2 100)

;;;
;;; Exercise 57. Recall that the word “height” forced us to choose one of two possible
;;; interpretations. Now that you have solved the exercises in this section, solve them again using
;;; the first interpretation of the word. Compare and contrast the solutions. 
;;;

;; Height = pixels from the ground (bottom) up to the rocket’s center.
;; 0 => rocket center at ground; larger => rocket goes up.
;; All names end with -57 to avoid clashes.

(define WIDTH-57  200)
(define HEIGHT-57 200)
(define BACKG-57  (empty-scene WIDTH-57 HEIGHT-57))
(define ROCKET-57 ROCKET) ;; Same rocket as before
(define CENTER-57 (/ (image-height ROCKET-57) 2))
(define GROUND-Y-57 (- HEIGHT-57 CENTER-57))

(define (ground->y-57 h)
  (max CENTER-57 (- GROUND-Y-57 h)))

(define (render-LR-57 v)
  (if (string? v)
      (place-image ROCKET-57 (/ WIDTH-57 2) GROUND-Y-57 BACKG-57)
      (place-image ROCKET-57 (/ WIDTH-57 2) (ground->y-57 v) BACKG-57)))

(check-expect (image-height (render-LR-57 "resting"))
              (image-height (render-LR-57 0)))

(define (resting?-57 x)
  (and (string? x) (string=? x "resting")))

(define (place-rocket-57 y)
  (place-image ROCKET-57 20 y BACKG-57))

(define (show-57 x)
  (cond
    [(resting?-57 x)
     (place-rocket-57 GROUND-Y-57)]
    [(and (number? x) (<= -3 x -1))
     (place-image (text (number->string x) 20 "red")
                  40 30
                  (place-rocket-57 GROUND-Y-57))]
    [(and (number? x) (>= x 0))
     (place-rocket-57 (ground->y-57 x))]))

(check-expect (image? (show-57 "resting")) #true)
(check-expect (image? (show-57 -2))        #true)
(check-expect (image? (show-57 75))        #true)

(define (tick-57 h) (add1 h))

(define (stop?-57 h)
  (<= (ground->y-57 h) CENTER-57))

(define (render-57 h)
  (render-LR-57 h))

(define (main2-57 initial-height)
  (big-bang initial-height
    [on-tick  tick-57 0.1]
    [to-draw  render-57]
    [stop-when stop?-57]))

(main2-57 0)

;;;
;;; Exercise 58. Introduce constant definitions that separate the intervals for low prices and luxury
;;; prices from the others so that the legislators in Tax Land can easily raise the taxes even more.
;;;

;; Constants: interval boundaries
(define LOW 1000)          ; prices < LOW are untaxed
(define LUXURY 10000)   ; prices >= LUXURY are luxury

;; Constants: tax rates
(define MID-RATE  0.05)
(define LUX-RATE  0.08)

;; Price -> Number
;; A Price falls into one of three intervals:
;; - 0 through 999
;; - 1000 through 9999
;; - 10000 and above.
;; Represents the price of an item.

;; Computes the amount of tax charged for p
(define (sales-tax p)
  (cond
    [(and (<= 0 p)   (< p LOW))    0]
    [(and (<= LOW p) (< p LUXURY)) (* MID-RATE p)]
    [(>= p LUXURY)                 (* LUX-RATE p)]))

;; Tests (boundary + interior examples)
(check-expect (sales-tax 0)      0)
(check-expect (sales-tax 537)    0)
(check-expect (sales-tax LOW)    (* MID-RATE LOW))
(check-expect (sales-tax 1282)   (* MID-RATE 1282))
(check-expect (sales-tax LUXURY) (* LUX-RATE LUXURY))
(check-expect (sales-tax 12017)  (* LUX-RATE 12017))

; TrafficLight -> TrafficLight
; yields the next state, given current state cs
(define (tl-next cs) cs)
 
; TrafficLight -> Image
; renders the current state cs as an image
(define (tl-render current-state)
  (empty-scene 90 30))

;;;
;;; Exercise 59. Finish the design of a world program that simulates the traffic light FSA. Here is
;;; the main function:
;;;
;;; TrafficLight -> TrafficLight
;;; simulates a clock-based American traffic light
;;; (define (traffic-light-simulation initial-state)
;;;   (big-bang initial-state
;;;             [to-draw tl-render]
;;;             [on-tick tl-next 1]))
;;;
;;; The function’s argument is the initial state for the big-bang expression, which tells DrRacket to
;;; redraw the state of the world with tl-render and to handle clock ticks with tl-next. Also note
;;; that it informs the computer that the clock should tick once per second.
;;;
;;; Complete the design of tl-render and tl-next. Start with copying TrafficLight, tl-next, and
;;; tl-render into DrRacket’s definitions area.
;;;
;;; Here are some test cases for the design of the latter:
;;;
;;;    (check-expect (tl-render "red") <image>)
;;;    (check-expect (tl-render "yellow") <image>)
;;;
;;; Your function may use these images directly. If you decide to create images with the functions
;;; from the 2htdp/image teachpack, design an auxiliary function for creating the image of a one-
;;; colour bulb. Then read up on the place-image function, which can place bulbs into a background
;;; scene. 
;;;

;; Constants
(define TL-WIDTH  120)
(define TL-HEIGHT 240)
(define BULB-R    30)

(define X-CENTER  (/ TL-WIDTH 2))
(define Y-RED     50)
(define Y-YELLOW  (/ TL-HEIGHT 2))
(define Y-GREEN   (- TL-HEIGHT 50))

;; A TrafficLight is one of: "red" | "yellow" | "green"

;; tl-next : TrafficLight -> TrafficLight
(define (tl-next-59 s)
  (cond
    [(string=? s "red") "green"]
    [(string=? s "green") "yellow"]
    [(string=? s "yellow") "red"]))

(check-expect (tl-next-59 "red")    "green")
(check-expect (tl-next-59 "green")  "yellow")
(check-expect (tl-next-59 "yellow") "red")

;; panel background
(define PANEL
  (place-image (rectangle (- TL-WIDTH 20) (- TL-HEIGHT 20) "solid" "black")
               X-CENTER (/ TL-HEIGHT 2)
               (empty-scene TL-WIDTH TL-HEIGHT)))

;; bulb : String Boolean -> Image
;; make a bulb with colour c; lit? chooses solid coloured vs outline gray
(define (bulb c lit?)
  (circle BULB-R
          (if lit? "solid" "outline")
          (if lit? c "gray")))

;; Precompute the scene with all three bulbs UNLIT.
(define UNLIT
  (place-image (bulb "red"    #false) X-CENTER Y-RED
  (place-image (bulb "yellow" #false) X-CENTER Y-YELLOW
  (place-image (bulb "green"  #false) X-CENTER Y-GREEN
              PANEL))))

;; Helpers to locate the lit bulb based on state.
;; pos-of : TrafficLight -> Number (y position)
(define (pos-of s)
  (cond
    [(string=? s "red")    Y-RED]
    [(string=? s "yellow") Y-YELLOW]
    [(string=? s "green")  Y-GREEN]))

;; colour-of : TrafficLight -> String
(define (colour-of s) s) ; state name is the colour

;; tl-render : TrafficLight -> Image
;; Efficient: overlay exactly ONE lit bulb onto the prebuilt UNLIT scene.
(define (tl-render-59 s)
  (place-image (bulb (colour-of s) #true) X-CENTER (pos-of s) UNLIT))

;; Tests for rendering (build expected by overlaying on UNLIT)
(define EXPECT-RED
  (place-image (bulb "red" #true) X-CENTER Y-RED UNLIT))
(define EXPECT-YELLOW
  (place-image (bulb "yellow" #true) X-CENTER Y-YELLOW UNLIT))

(check-expect (tl-render-59 "red")    EXPECT-RED)
(check-expect (tl-render-59 "yellow") EXPECT-YELLOW)

;; TrafficLight -> TrafficLight
;; simulates a clock-based American traffic light
(define (traffic-light-simulation-59 initial-state)
  (big-bang initial-state
    [to-draw tl-render-59]
    [on-tick tl-next-59 1]))

;; (traffic-light-simulation-59 "red")

;;;
;;; Exercise 60. An alternative data representation for a traffic light program may use numbers
;;; instead of strings:
;;;
;;; An N-TrafficLight is one of:
;;; – 0 interpretation the traffic light shows red
;;; – 1 interpretation the traffic light shows green
;;; – 2 interpretation the traffic light shows yellow
;;;
;;; It greatly simplifies the definition of tl-next:
;;;
;;; N-TrafficLight -> N-TrafficLight
;;; Yields the next state, given current state cs
;;; (define (tl-next-numeric cs) (modulo (+ cs 1) 3))
;;;
;;; Reformulate tl-next’s tests for tl-next-numeric.
;;;
;;; Does the tl-next function convey its intention more clearly than the tl-next-numeric function? If
;;; so, why? If not, why not? 
;;;

;;;
;;; Exercise 60. An alternative data representation for a traffic light program may use numbers
;;; instead of strings:
;;;
;;; An N-TrafficLight is one of:
;;; – 0 interpretation the traffic light shows red
;;; – 1 interpretation the traffic light shows green
;;; – 2 interpretation the traffic light shows yellow
;;;
;;; Reformulate tl-next’s tests for tl-next-numeric. Also: compare clarity.
;;;

;; Numeric next function (given)
(define (tl-next-numeric cs)
  (modulo (+ cs 1) 3))

;; Direct numeric tests (exact analog of the string version)
(check-expect (tl-next-numeric 0) 1)  ; red -> green
(check-expect (tl-next-numeric 1) 2)  ; green -> yellow
(check-expect (tl-next-numeric 2) 0)  ; yellow -> red

;; Make intention clearer with named constants
(define RED    0)
(define GREEN  1)
(define YELLOW 2)

(check-expect (tl-next-numeric RED)    GREEN)
(check-expect (tl-next-numeric GREEN)  YELLOW)
(check-expect (tl-next-numeric YELLOW) RED)

#|
Discussion:
- tl-next (string-based) is self-explanatory: the data values ("red", "green", "yellow")
  communicate meaning directly, so the tests read like English.
- tl-next-numeric is concise and elegant (just modulo arithmetic), but the intention is less
  obvious unless you define and use named constants (RED, GREEN, YELLOW) or document the mapping.
- For beginners, strings or named constants improve readability; for brevity/efficiency, the
  numeric with modulo is fine once the mapping is clear.
|#

;;;
;;; Exercise 61. As From Functions to Programs says, programs must define constants and use names
;;; instead of actual constants. In this spirit, a data definition for traffic lights must use
;;; constants, too:This form of data definition is what a seasoned designer would use.
;;;

;;;    (define RED 0)
;;;    (define GREEN 1)
;;;    (define YELLOW 2)
     
;;; An S-TrafficLight is one of:
;;; – RED
;;; – GREEN
;;; – YELLOW

;;; If the names are chosen properly, the data definition does not need an interpretation statement.

;;; S-TrafficLight -> S-TrafficLight
;;; yields the next state, given current state cs
;;;
;;; (check-expect (tl-next- ... RED) GREEN)
;;; (check-expect (tl-next- ... YELLOW) RED)
;;;
;;; Function 1:
;;; (define (tl-next-numeric cs)
;;;   (modulo (+ cs 1) 3))
;;;
;;; Function 2:
;;; (define (tl-next-symbolic cs)
;;;   (cond
;;;     [(equal? cs RED) GREEN]
;;;     [(equal? cs GREEN) YELLOW]
;;;     [(equal? cs YELLOW) RED]))
;;;
;;; Functions 1 and 2 switch the state of a traffic light in a simulation program. Which of the two is properly designed using the recipe for itemization? Which of the two continues to work if you change the constants to the following
;;; (define RED "red")
;;; (define GREEN "green")
;;; (define YELLOW "yellow")
;;;
;;; Does this help you answer the questions?
;;;
;;; Aside The equal? function in figure 27 compares two arbitrary values, regardless of what these
;;; values are. Equality is a complicated topic in the world of programming.
;;;

;;;
;;; Exercise 61.
;;; As From Functions to Programs says, programs should define constants and use names instead of
;;; literal constants. In this spirit, a data definition for traffic lights should use constants, too.
;;;

;;; Constants
;;; (define RED 0)
;;; (define GREEN 1)
;;; (define YELLOW 2)

;; An S-TrafficLight is one of:
;; – RED
;; – GREEN
;; – YELLOW

;; Function 1: numeric approach using modulo
(define (tl-next-numeric-61 cs)
  (modulo (+ cs 1) 3))

;; Function 2: symbolic approach using itemization
(define (tl-next-symbolic cs)
  (cond
    [(equal? cs RED) GREEN]
    [(equal? cs GREEN) YELLOW]
    [(equal? cs YELLOW) RED]))

;; tests
(check-expect (tl-next-numeric-61 RED)    GREEN)
(check-expect (tl-next-numeric-61 GREEN)  YELLOW)
(check-expect (tl-next-numeric-61 YELLOW) RED)

(check-expect (tl-next-symbolic RED)    GREEN)
(check-expect (tl-next-symbolic GREEN)  YELLOW)
(check-expect (tl-next-symbolic YELLOW) RED)

#|
Discussion:

The symbolic version is the better design. It follows the recipe for itemizations, because
the data definition says a traffic light can be RED, GREEN, or YELLOW, and the function
handles each of those cases separately with a cond.

The numeric version is shorter, but it only works because the lights happen to be numbered
0, 1, and 2. If we later decide to use strings instead of numbers, like
(define RED "red"), the modulo arithmetic will stop working, but the symbolic version will
still run fine.

So while the numeric version is clever, the symbolic version matches the data definition and
will keep working even if we change how the data is represented.
|#

;;;
;;; Exercise 62. During a door simulation the “open” state is barely visible. Modify door-simulation
;;; so that the clock ticks once every three seconds. Rerun the simulation.
;;;

; A DoorState is one of:
(define LOCKED "locked") ; LOCKED
(define CLOSED "closed") ; CLOSED
(define OPEN "open")     ; OPEN
    
;;; Stop!  Formulate the appropriate signatures:
;;;
;;; door-closer : DoorState -> DoorState
;;; Closes an open door during one clock tick
;;; - (used as the [on-tick ...] handler)
;;; Example: (door-closer "open") = "closed"
;;; Example: (door-closer "locked") = "locked"
;;;
;;; door-action : DoorState KeyEvent -> DoorState
;;; Handles user actions: unlock ("u"), lock ("l"), or push open (" ")
;;; - (used as the [on-key ...] handler)
;;; Example: (door-action "locked" "u") = "closed"
;;;
;;; door-render : DoorState -> Image
;;; Renders the current door state as an image for display
;;; - (used as the [to-draw ...] handler)
;;; Example: (door-render "open") = (text "open" 40 "red")

;;; DoorState -> DoorState
;;; closes an open door over the period of one tick 
;;; (define (door-closer state-of-door) state-of-door)

;;; (define (door-closer state-of-door)
;;;   (cond
;;;     [(string=? LOCKED state-of-door) ...]
;;;     [(string=? CLOSED state-of-door) ...]
;;;     [(string=? OPEN state-of-door) ...]))

;;; Door-closer function
(define (door-closer state-of-door)
  (cond
    [(string=? LOCKED state-of-door) LOCKED]
    [(string=? CLOSED state-of-door) CLOSED]
    [(string=? OPEN state-of-door) CLOSED]))

;;; Tests for door-closer
(check-expect (door-closer LOCKED) LOCKED)
(check-expect (door-closer CLOSED) CLOSED)
(check-expect (door-closer OPEN) CLOSED)

;;; DoorState KeyEvent -> DoorState
;;; turns key event k into an action on state s 
;;; (define (door-action s k)
;;;   s)

;;; Tests for door-action
(check-expect (door-action LOCKED "u") CLOSED)
(check-expect (door-action CLOSED "l") LOCKED)
(check-expect (door-action CLOSED " ") OPEN)
(check-expect (door-action OPEN "a") OPEN)
(check-expect (door-action CLOSED "a") CLOSED)
 
;;; Door-action function
(define (door-action s k)
  (cond
    [(and (string=? LOCKED s) (string=? "u" k))
     CLOSED]
    [(and (string=? CLOSED s) (string=? "l" k))
     LOCKED]
    [(and (string=? CLOSED s) (string=? " " k))
     OPEN]
    [else s]))

;;; Tests for door-render
(check-expect (door-render CLOSED) (text CLOSED 40 "red"))

; DoorState -> Image
; Translates the state s into a large text image
(define (door-render s)
  (text s 40 "red"))

;; Only the [on-tick ...] clause changes: add 3 to tick every 3 seconds.
(define (door-simulation initial-state)
  (big-bang initial-state
    [on-tick door-closer 3]  ; Tick once every 3 seconds
    [on-key  door-action]
    [to-draw door-render]))

;; (door-simulation CLOSED)
