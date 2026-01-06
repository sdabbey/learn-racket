#lang htdp/bsl
(require 2htdp/image)
(require 2htdp/universe)

;; Paste the two cat images from HtDP into cat1 and cat2:
#;
(define cat1 .)
#;
(define cat2 .)

;; ------------------------------------------------------------
;; Constants (from Virtual Pet Worlds suggestion)
;; ------------------------------------------------------------
(define cat-width (image-width cat1))
(define cat-height (image-height cat1))

(define scene-width 300)
(define scene-height 125)

(define cat-speed 3)        ; pixels per tick
(define decay-per-tick 0.2) ; happiness ↓ each tick
(define pet-boost 8)        ; ↑ for "up" key (pet)
(define feed-boost 15)      ; ↑ for "f" key (feed)
(define max-happiness 100)  ; maximum happiness

(define background (empty-scene scene-width scene-height))
(define y-cat (- scene-height (/ cat-height 2)))

;;;
;;; Exercise 88. Define a structure type that keeps track of the cat’s x-coordinate and its happiness.
;;; Then formulate a data definition for cats, dubbed VCat, including an interpretation.
;;;

(define-struct vcat [x h])
;; A VCat is (make-vcat Number Number)
;; interpretation:
;;   (make-vcat x h) represents the virtual cat’s state where
;;   - x is the x-coordinate (center) of the cat on a scene-width by scene-height canvas.
;;     The cat moves to the right each tick and wraps around at scene-width.
;;   - h is the cat’s happiness, as an interval [0, max-happiness].
;;     Happiness decreases a little each tick, and increases when the player pets (up arrow) or
;;     feeds ("f" key) the cat.

;; Example VCat states
(define VC0 (make-vcat 0 max-happiness))
(define VC1 (make-vcat 150 73))

;;;
;;; Exercise 89. Design the happy-cat world program, which manages a walking cat and its happiness
;;; level. Let’s assume that the cat starts out with perfect happiness.
;;;

;; tock-cat : VCat -> VCat
;; Move right by SPEED with wraparound; decay happiness but not below 0.
(define (tock-cat vc)
  (make-vcat
   (modulo (+ (vcat-x vc) cat-speed) scene-width)
   (max 0 (- (vcat-h vc) decay-per-tick))))

;; choose-cat-image : Number -> Image
;; Alternate cat images for walking effect.
(define (choose-cat-image x)
  (if (odd? (round x)) cat1 cat2))

;; filled-bar : Number -> Image
;; Make a red bar whose width is proportional to happiness h in [0, MAX-H].
(define (filled-bar h)
  (rectangle (* scene-width (/ (min (max h 0) max-happiness) max-happiness))
             6 "solid" "red"))

;; gauge-image : Number -> Image
;; Red bar with a black outline frame, aligned to the top-left.
(define (gauge-image h)
  (overlay/align "left" "top"
                 (rectangle scene-width 6 "outline" "black")
                 (filled-bar h)))

;; render-cat : VCat -> Image
;; Draw the walking cat and a happiness bar.
(define (render-cat vc)
  (place-image (choose-cat-image (vcat-x vc)) (vcat-x vc) y-cat
               (place-image/align (gauge-image (vcat-h vc))
                                  0 0 "left" "top"
                                  background)))

;; on-key-cat : VCat KeyEvent -> VCat
;; Pet with "up", feed with "f". Limit happiness to MAX-H.
(define (on-key-cat vc key)
  (cond [(key=? key "up")
         (make-vcat (vcat-x vc)
                    (min max-happiness (+ (vcat-h vc) pet-boost)))]
        [(key=? key "f")
         (make-vcat (vcat-x vc)
                    (min max-happiness (+ (vcat-h vc) feed-boost)))]
        [else vc]))

;; happy-cat : Number -> World
;; Start at x0 with perfect happiness.
(define (happy-cat x)
  (big-bang (make-vcat x max-happiness)
    [on-tick tock-cat]
    [on-key  on-key-cat]
    [to-draw render-cat]))

;; Try: (happy-cat 0)

;;;
;;; Exercise 90. Modify the happy-cat program from the preceding exercises so that it stops whenever
;;; the cat’s happiness falls to 0.
;;;

;; sad? : VCat -> Boolean
(define (sad? vc)
  (<= (vcat-h vc) 0))

;; last-picture : VCat -> Image
(define (last-picture vc)
  (overlay (text "The cat’s happiness fell to 0." 12 "black")
           (render-cat vc)))

;; happy-cat-stop : Number -> World
(define (happy-cat-stop x)
  (big-bang (make-vcat x max-happiness)
    [on-tick tock-cat]
    [on-key  on-key-cat]
    [to-draw render-cat]
    [stop-when sad? last-picture]))

;; Try: (happy-cat-stop 0)

(check-expect (sad? (make-vcat 0 0)) #true)
(check-expect (sad? (make-vcat 0 0.1)) #false)

;;;
;;; Exercise 91. Extend your structure type definition and data definition from exercise 88 to include
;;; a direction field. Adjust your happy-cat program so that the cat moves in the specified direction.
;;; The program should move the cat in the current direction, and it should turn the cat around when
;;; it reaches either end of the scene.
;;;

(define-struct vcat-d [x h dir])
;; A VCat-D is (make-vcat-d Number Number Number)
;; interpretation:
;;   x   : x-coordinate (center) on the scene (0 .. scene-width)
;;   h   : happiness (we limit with min/max where needed)
;;   dir : direction of motion, 1 = right, -1 = left

;; face-by-dir : Image Number -> Image
;; Flip the sprite if moving left.
(define (face-by-dir img dir)
  (if (= dir -1) (flip-horizontal img) img))

;; next-x : Number Number -> Number
;; Compute the tentative next x given direction.
(define (next-x x dir)
  (+ x (* dir cat-speed)))

;; bounce-step : Number Number -> (make-vcat-d Number Number Number)
;; Compute the bounced position and possibly flipped direction when
;; the cat would step beyond the scene edges. (H component is filler 0 here.)
(define (bounce-step x dir)
  (cond [(>= (next-x x dir) scene-width) (make-vcat-d scene-width 0 -1)]
        [(<= (next-x x dir) 0)           (make-vcat-d 0           0  1)]
        [else                            (make-vcat-d (next-x x dir) 0 dir)]))

;; tock-cat-d : VCat-D -> VCat-D
;; Move according to dir with bouncing; happiness decays but not below 0.
(define (tock-cat-d vc)
    (make-vcat-d (vcat-d-x (bounce-step (vcat-d-x vc) (vcat-d-dir vc)))
                 (max 0 (- (vcat-d-h vc) decay-per-tick))
                 (vcat-d-dir (bounce-step (vcat-d-x vc) (vcat-d-dir vc)))))


;; render-cat-d : VCat-D -> Image
;; Draw cat facing its direction; reuse gauge-image from earlier.
(define (render-cat-d vc)
  (place-image
   (face-by-dir (choose-cat-image (vcat-d-x vc)) (vcat-d-dir vc))
   (vcat-d-x vc) y-cat
   (place-image/align (gauge-image (vcat-d-h vc))
                      0 0 "left" "top"
                      background)))

;; on-key-cat-d : VCat-D KeyEvent -> VCat-D
;; "up" pets, "f" feeds (cap at max-happiness); optional arrow keys set direction.
(define (on-key-cat-d vc key)
  (cond [(key=? key "up")
         (make-vcat-d (vcat-d-x vc)
                      (min max-happiness (+ (vcat-d-h vc) pet-boost))
                      (vcat-d-dir vc))]
        [(key=? key "f")
         (make-vcat-d (vcat-d-x vc)
                      (min max-happiness (+ (vcat-d-h vc) feed-boost))
                      (vcat-d-dir vc))]
        [(key=? key "left")
         (make-vcat-d (vcat-d-x vc) (vcat-d-h vc) -1)]
        [(key=? key "right")
         (make-vcat-d (vcat-d-x vc) (vcat-d-h vc)  1)]
        [else vc]))

;; happy-cat-dir : Number -> World
;; Start at x0 with perfect happiness, moving right (dir = 1).
(define (happy-cat-dir x0)
  (big-bang (make-vcat-d x0 max-happiness 1)
    [on-tick tock-cat-d]
    [on-key  on-key-cat-d]
    [to-draw render-cat-d]))

;; Example runs:
;; (happy-cat-dir 0)
;; (big-bang (make-vcat-d 150 80 -1) [on-tick tock-cat-d] [on-key on-key-cat-d] [to-draw render-cat-d])
;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.

;; Exercise 92.
;; Design the cham program,
;; which has the chameleon continuously walking
;; across the canvas from left to right.
;; To make the chameleon happy,
;; you feed it (down arrow, two points only);
;; petting isn’t allowed.
;; "r" turns the chameleon red, "b" blue, and "g" green.
;; Start with a data definition, VCham, for representing chameleons.



;;; Constants and Data Definitions

;; A Score is a Number
;; in an interval [0, 100]
;; Represents a happiness level.

(define RED "red")
(define GREEN "green")
(define BLUE "blue")
;; A Color is one of:
;; - RED,
;; - GREEN,
;; - BLUE.

(define-struct vCham [x color score])
;; A VCham is a structure:
;; (make-vCham Number Color Score)
;; (make-vCham x c s) represents a walking cham
;; which is located on an x-coordinate x,
;; has a color c, and
;; a happiness level s.

(define CHAM1 (bitmap "./images/cham-v3-1.png"))
(define CHAM2 (bitmap "./images/cham-v3-2.png"))
(define CHAM3 (bitmap "./images/cham-v3-1.png"))
(define CHAM-WIDTH (image-width CHAM1))
(define CHAM-HEIGHT (image-height CHAM1))
(define CANVAS-WIDTH (* CHAM-WIDTH 6))
(define CANVAS-HEIGHT (* CHAM-HEIGHT 3))
(define CHAM-Y (- CANVAS-HEIGHT (/ CHAM-HEIGHT 2) 1))
(define CHAM-VELOCITY 3)

(define SCORE-MAX 100)
(define SCORE-MIN 0)
(define SCORE-DECREASE 0.1)
(define SCORE-FEED 2)
(define GAUGE-HEIGHT 10)
(define FRAME-WIDTH SCORE-MAX)
(define FRAME-HEIGHT (+ GAUGE-HEIGHT 2))


;;; Functions

;; VCham -> VCham
;; Usage: (cham (make-vCham 0 "green" 100))
(define (cham cham)
  (big-bang cham
    [to-draw render]
    [on-tick tick-handler]
    [on-key key-handler]
    [stop-when end?]))

;; VCham -> Image
;; Produces an image of a walking cham
;; and a happiness gauge.
(define (render cham)
  (place-image
   (overlay
    (cham-image (vCham-x cham))
    (cham-background (vCham-color cham)))
   (vCham-x cham) CHAM-Y
   (if (> (vCham-score cham) SCORE-MAX)
       (draw-gauge SCORE-MAX)
       (draw-gauge (vCham-score cham)))))

;; Number -> Image
;; Returns a particular image of a chameleon
;; that depends on the chameleon's position.
(check-expect (cham-image 12) CHAM2)
(check-expect (cham-image 24) CHAM1)
(check-expect (cham-image 36) CHAM3)
(check-expect (cham-image 48) CHAM1)
(define (cham-image x)
  (cond
    [(or (= 0 (cham-step x)) (= 2 (cham-step x))) CHAM1]
    [(= 1 (cham-step x)) CHAM2]
    [(= 3 (cham-step x)) CHAM3]))


;; Color -> Image
;; Produces a rectangle of a specified color.
(check-expect (cham-background RED)
              (rectangle CHAM-WIDTH CHAM-HEIGHT "solid" RED))
(check-expect (cham-background GREEN)
              (rectangle CHAM-WIDTH CHAM-HEIGHT "solid" GREEN))
(check-expect (cham-background BLUE)
              (rectangle CHAM-WIDTH CHAM-HEIGHT "solid" BLUE))
(define (cham-background color)
  (rectangle CHAM-WIDTH CHAM-HEIGHT "solid" color))

;; Number -> Number
;; Calculates current step of the cham animation
;; using a given x-coordinate.
(check-expect (cham-step 0) 0)
(check-expect (cham-step 4) 0)
(check-expect (cham-step 12) 1)
(check-expect (cham-step 24) 2)
(check-expect (cham-step 36) 3)
(check-expect (cham-step 48) 0)
(check-expect (cham-step 120) 2)
(define (cham-step x)
  (modulo (round (/ x 12)) 4))

;; Score -> Image
;; Produces a happiness gauge image.
(define (draw-gauge level)
  (underlay/align/offset
   "left" "top"
   (empty-scene CANVAS-WIDTH CANVAS-HEIGHT)
   1 20
   (overlay/align
    "left" "middle"
    (rectangle FRAME-WIDTH FRAME-HEIGHT "outline" "black")
    (rectangle level GAUGE-HEIGHT "solid" "red"))))

;; VCham -> VCham
;; Constructs VCham structure for the current world clock tick.
(check-expect (tick-handler (make-vCham 0 RED 101)) (make-vCham 3 RED 100))
(check-expect (tick-handler (make-vCham 0 GREEN 0)) (make-vCham 3 GREEN 0))
(check-expect (tick-handler (make-vCham 0 BLUE 10)) (make-vCham 3 BLUE 9.9))
(check-expect (tick-handler (make-vCham 50 RED 15.5)) (make-vCham 53 RED 15.4))
(define (tick-handler cham)
  (make-vCham
   (next (vCham-x cham))
   (vCham-color cham)
   (cond
     [(> (vCham-score cham) SCORE-MAX) SCORE-MAX]
     [(<= (vCham-score cham) SCORE-DECREASE) 0]
     [else (- (vCham-score cham) SCORE-DECREASE)])))

;; Number -> Number
;; Calculates next x-coordinate of the walking cham position,
;; starting over from the left, whenever the cham leaves the canvas.
(check-expect (next 0) 3)
(check-expect (next 100) 103)
(define (next x)
  (modulo
   (+ CHAM-VELOCITY x)
   (round (+ CANVAS-WIDTH (/ CHAM-WIDTH 2)))))

;; VCham KeyEvent -> VCham
;; Changes chameleon state on a key press:
;; - "down" increases cham's happiness level,
;; - "r" changes cham's color to red,
;; - "b" changes cham's color to blue,
;; - "g" changes cham's color to green.
(check-expect (key-handler (make-vCham 0 RED 30) "down")
              (make-vCham 0 RED (+ 30 SCORE-FEED)))
(check-expect (key-handler (make-vCham 0 RED 30) "g")
              (make-vCham 0 GREEN 30))
(check-expect (key-handler (make-vCham 0 GREEN 30) "b")
              (make-vCham 0 BLUE 30))
(check-expect (key-handler (make-vCham 0 BLUE 30) "r")
              (make-vCham 0 RED 30))
(check-expect (key-handler (make-vCham 0 GREEN 30) "a")
              (make-vCham 0 GREEN 30))
(define (key-handler cham key)
  (make-vCham
   (vCham-x cham)
   (cond
     [(key=? key "r") RED]
     [(key=? key "g") GREEN]
     [(key=? key "b") BLUE]
     [else (vCham-color cham)])
   (cond
     [(key=? key "down") (score+ (vCham-score cham) SCORE-FEED)]
     [else (vCham-score cham)])))

;; Score Number -> Number
;; Increases score value by n points.
(check-expect (score+ SCORE-MAX 1) SCORE-MAX)
(check-expect (score+ 30 3) 33)
(define (score+ score n)
  (if (> (+ score n) SCORE-MAX)
      SCORE-MAX
      (+ score n)))

;; VCham -> Boolean
;; Identifies if to shut down the program.
(check-expect (end? (make-vCham 100 RED 80)) #false)
(check-expect (end? (make-vCham 100 RED 0)) #true)
(define (end? cham)
  (= (vCham-score cham) 0))

;;; Application

;(cham (make-vCham 0 "green" 100))

