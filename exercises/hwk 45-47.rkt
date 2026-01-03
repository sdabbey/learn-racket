
#lang htdp/bsl

;; Run this in DrRacket.  Paste the cat images from HtDP.
(define cat1 .)
(define cat2 .)

(require 2htdp/image)
(require 2htdp/universe)

;; ------------------------------------------------------------
;; Constants
;; ------------------------------------------------------------

(define cat-width (image-width cat1))
(define cat-height (image-height cat1))

(define cat-speed 3) ; pixels per tick
(define cat-scene-width 300)
(define cat-scene-height 100)

(define cat-background (empty-scene cat-scene-width cat-scene-height))
(define y-cat (- cat-scene-height (/ cat-height 2)))

;; ------------------------------------------------------------
;; WorldState
;; ------------------------------------------------------------
;; A WorldState is a Number
;; Interpretation: the x-coordinate of the *center* of the cat.

;; ------------------------------------------------------------
;; Functions
;; ------------------------------------------------------------

;; WorldState -> WorldState
;; Advance cat to the right, wrap around using modulo
(define (tock-cat x)
  (modulo (+ x cat-speed) cat-scene-width))

;; WorldState -> Image
;; Render the cat at its current x position
(define (render-cat x)
  (place-image cat1 x y-cat cat-background))

;; WorldState -> World
;; Run the virtual cat world
(define (cat-world start-x)
  (big-bang start-x
    [on-tick tock-cat]
    [to-draw render-cat]))

;; ------------------------------------------------------------
;; Start cat-world
;; ------------------------------------------------------------
; (cat-world 0)

(define (render-cat2 x)
  (cond
    [(odd? x) (place-image cat1 x y-cat cat-background)]
    [else     (place-image cat2 x y-cat cat-background)]))

;; WorldState -> World
;; Run the virtual cat world
(define (cat-world2 start-x)
  (big-bang start-x
    [on-tick tock-cat]
    [to-draw render-cat2]))

;; ------------------------------------------------------------
;; Start cat-world2
;; ------------------------------------------------------------
; (cat-world2 0)



;; ----------------------------
;; constants / visuals
;; ----------------------------
(define max-h 100)                 ; maximum happiness
(define decay-per-tick 0.1)        ; ↓ each tick
(define down-multiplier (/ 1 5))   ; ↓ on "down" key  = 0.2
(define up-multiplier   (/ 1 3))   ; ↑ on "up" key    ≈ 0.333...

(define gauge-w 300)
(define gauge-h 30)

(define scene-w 320)
(define scene-h 100)

(define background (empty-scene scene-w scene-h))
(define img-frame (rectangle gauge-w gauge-h "outline" "black"))

;; ----------------------------
;; Helpers
;; ----------------------------
;; Number Number Number -> Number
;; clamp n into [lo, hi]
(define (clamp n lo hi)
  (cond [(< n lo) lo]
        [(> n hi) hi]
        [else n]))

;; ----------------------------
;; worldstate = Number in [0, max-h]
;; interpretation: current happiness level
;; ----------------------------

;; worldstate -> worldstate
;; decay a little each tick, never below 0
(define (tock-gauge h)
  (clamp (- h decay-per-tick) 0 max-h))

;; worldstate String -> worldstate
;; adjust happiness on arrow keys, clamp to [0, max-h]
(define (on-key-gauge h ke)
  (clamp (cond [(string=? ke "down") (- h (* max-h down-multiplier))]
               [(string=? ke "up")   (+ h (* max-h up-multiplier))]
               [else h])
         0 max-h))

;; worldstate -> image
;; draw a red bar whose width is proportional to happiness, with a black frame
(define (render-gauge h)
  (place-image
   (overlay
    img-frame
    (beside
     (rectangle (* gauge-w (/ h max-h)) gauge-h "solid" "red")
     (rectangle (- gauge-w (* gauge-w (/ h max-h))) gauge-h "solid" "white")))
   (/ scene-w 2) (/ scene-h 2)
   background))

;; Number -> world
;; run the gauge program from an initial happiness (0..max-h)
(define (gauge-prog start-h)
  (big-bang (clamp start-h 0 max-h)
    [on-tick tock-gauge]
    [on-key  on-key-gauge]
    [to-draw render-gauge]))

;; example run:
(gauge-prog 75)

