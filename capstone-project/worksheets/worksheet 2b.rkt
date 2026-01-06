;;;;;
;;;;; ============================================================================
;;;;; *** Spacewar! ***
;;;;;
;;;;; An implementation of Spacewar! in Racket, using big-bang functionality
;;;;; from BSL and design procedures outlined in HtDP/2e.
;;;;; ============================================================================
;;;;;

;;;; -----------------------------------------------------------------------------
;;;; Note: This is Worksheet 2b. It's motivation is twofold from Worksheet 2a:
;;;; 1. You cannot use the keyboard to cause both ships to rotate simultaneously
;;;; 2. The rotations are not centred
;;;; 
;;;; In order to solve this problems, 2b starts with cleaned-up base code, and
;;;; then extends to account for rotation intention.  This means modifying
;;;; Worksheet 2a code directly rather than doing different versions of
;;;; functions.
;;;;
;;;; See Worksheet 2a Answers at the bottom for the issues and possible
;;;; solutions.
;;;; -----------------------------------------------------------------------------

#lang htdp/bsl

(require 2htdp/universe)
(require 2htdp/image)

;;;; -----------------------------------------------------------------------------
;;;; Graphical constants and starfield image
;;;; -----------------------------------------------------------------------------

(define width 600)
(define height 400)

;; A background is a black empty scene
(define background (empty-scene width height "black"))

;; A star is a small white circle
(define pinprick (circle 2 "solid" "white"))

;; A starfield image the same size as the background
(define starfield
  (place-image pinprick               (* 1/12 width) (* 1/5 height)
    (place-image pinprick             (* 1/5 width) (* 3/4 height)
      (place-image pinprick           (* 1/3 width) (* 3/8 height)
        (place-image pinprick         (* 7/12 width) (* 9/10 height)
          (place-image pinprick       (* 5/6 width) (* 11/20 height)
            (place-image pinprick     (* 19/20 width) (* 7/8 height)
              (place-image pinprick   (* 1/15 width) (* 5/8 height)
                (place-image pinprick (* 1/2 width) (* 1/8 height)
                  background)))))))))

;;;; -----------------------------------------------------------------------------
;;;; Ship data and image
;;;; -----------------------------------------------------------------------------

;;; A Ship is (make-ship Posn Number Posn Image)
;;; interpretation:
;;;   location – the ship’s current position
;;;   rotation – its current angle, in degrees
;;;   turn     - its current turn value (+1: counterclockwise; 0: none; -1: clockwise) [change from 2]
;;;   velocity – change in position each move (dx, dy)
;;;   image    – how the ship is drawn
(define-struct ship [location rotation turn velocity image])

;;; Example wedge ship image
;;; This has a problem: the image is not centred on the centre of the image
;; (define ship-wedge
;;   (isosceles-triangle 
;;     (/ width 30)   ; base of wedge
;;     (/ height 15)  ; height of wedge
;;     "outline" "white"))

;; A square will rotate properly; so we need to centre the image inside a square:
;; 1. The original wedge
(define raw-ship-wedge
  (isosceles-triangle 
    (/ width 30)   ; base
    (/ height 15)  ; height
    "outline" "white"))

;; 2. A square big enough to hold raw-ship-wedge
(define ship-size
  (max (image-width raw-ship-wedge)
       (image-height raw-ship-wedge)))

;; 3. Center the triangle inside that square
(define ship-wedge
  (overlay/align
   "middle" "middle"
   raw-ship-wedge
   (square ship-size "solid" "transparent")))

;;; Example ships for testing
(define example-ship-1 (make-ship (make-posn 100 150) 0 0 (make-posn 10 5) ship-wedge))
(define example-ship-2 (make-ship (make-posn 250 300) 0 0 (make-posn -5 -15) ship-wedge))
(define example-ship-3 (make-ship (make-posn 5 5) 0 0 (make-posn -10 -5) ship-wedge))
(define example-ship-4 (make-ship (make-posn 395 395) 0 0 (make-posn 5 5) ship-wedge))
(define example-ship-5 (make-ship (make-posn 100 150) 0 0 (make-posn 0 0) ship-wedge))
(define example-ship-6 (make-ship (make-posn 250 300) 0 0 (make-posn 0 0) ship-wedge))

;;;; -----------------------------------------------------------------------------
;;;; draw-ship and sw-render
;;;; -----------------------------------------------------------------------------

;;; draw-ship : Ship Image -> Image
;;; template:
;;; (define (draw-ship ship scene)
;;;   (place-image ...))
;;;
;;; Place the rotated ship image on a given background image
(check-expect
  (draw-ship example-ship-1 background)
  (place-image (rotate (ship-rotation example-ship-1) (ship-image example-ship-1))
               (posn-x (ship-location example-ship-1))
               (posn-y (ship-location example-ship-1))
               background))

(define (draw-ship ship scene)
  (place-image (rotate (ship-rotation ship) (ship-image ship))
               (posn-x (ship-location ship))
               (posn-y (ship-location ship))
               scene))

;;;; -----------------------------------------------------------------------------
;;;; Updaters
;;;; -----------------------------------------------------------------------------

;;; update-posn-x : Posn Number -> Posn
;;; template:
;;; (define (update-posn-x pos x)
;;;   (make-posn ...))

;;; Change the x-coordinate of a posn
(check-expect (update-posn-x (make-posn 10 20) 99)
              (make-posn 99 20))

(define (update-posn-x pos x)
  (make-posn x (posn-y pos)))

;;; update-posn-y : Posn Number -> Posn
;;; template:
;;; (define (update-posn-y pos y)
;;;   (make-posn ...))

;;; Change the y-coordinate of a posn
(check-expect (update-posn-y (make-posn 10 20) 77)
              (make-posn 10 77))

(define (update-posn-y pos y)
  (make-posn (posn-x pos) y))

;;; update-location-x : Ship Number -> Ship
;;; template:
;;; (define (update-location-x ship x)
;;;   (make-ship (update-posn-x ...)
;;;              (ship-rotation ship)
;;;              (ship-velocity ship)
;;;              (ship-image ship)))
;;;
;;; Produce a ship like the given one but with its x-position changed
(check-expect (update-location-x example-ship-1 42)
              (make-ship (make-posn 42 (posn-y (ship-location example-ship-1)))
                         0
                         0
                         (ship-velocity example-ship-1)
                         ship-wedge))

(define (update-location-x ship x)
  (make-ship (update-posn-x (ship-location ship) x)
             (ship-rotation ship)
             (ship-turn ship)
             (ship-velocity ship)
             (ship-image ship)))

;;; update-location-y : Ship Number -> Ship
;;; template:
;;; (define (update-location-y ship y)
;;;   (make-ship (update-posn-y ...)
;;;              (ship-rotation ship)
;;;              (ship-velocity ship)
;;;              (ship-image ship)))
;;;
;;; Produce a ship like the given one but with its y-position changed
(check-expect
  (update-location-y example-ship-1 999)
  (make-ship (make-posn (posn-x (ship-location example-ship-1)) 999)
             0
             0
             (ship-velocity example-ship-1)
             ship-wedge))

(define (update-location-y ship y)
  (make-ship (update-posn-y (ship-location ship) y)
             (ship-rotation ship)
             (ship-turn ship)
             (ship-velocity ship)
             (ship-image ship)))

;;;; update-velocity-x : Ship Number -> Ship
;;; template:
;;; (define (update-velocity-x ship x)
;;;   (make-ship (ship-location ship)
;;;              (ship-rotation ship)
;;;              (update-posn-x ...)
;;;              (ship-image ship)))
;;;
;;; Produce a ship with updated dx but same dy
(check-expect
  (update-velocity-x example-ship-1 3)
  (make-ship (ship-location example-ship-1)
             0
             0
             (make-posn 3 (posn-y (ship-velocity example-ship-1)))
             ship-wedge))

(define (update-velocity-x ship x)
  (make-ship (ship-location ship)
             (ship-rotation ship)
             (ship-turn ship)
             (update-posn-x (ship-velocity ship) x)
             (ship-image ship)))

;;; update-velocity-y : Ship Number -> Ship
;;; template:
;;; (define (update-velocity-y ship y)
;;;   (make-ship (ship-location ship)
;;;              (ship-rotation ship)
;;;              (update-posn-y ...)
;;;              (ship-image ship)))
;;;
;;; Produce a ship with updated dy but same dx
(check-expect
  (update-velocity-y example-ship-1 -7)
  (make-ship (ship-location example-ship-1)
             0
             0
             (make-posn (posn-x (ship-velocity example-ship-1)) -7)
             ship-wedge))

(define (update-velocity-y ship y)
  (make-ship (ship-location ship)
             (ship-rotation ship)
             (ship-turn ship)
             (update-posn-y (ship-velocity ship) y)
             (ship-image ship)))

;;; update-rotation : Ship Number -> Ship
;;; template:
;;; (define (update-rotation ship degrees)
;;;   (make-ship ...))
;;;
;;; Produce a ship with a new rotation
(check-expect
  (update-rotation example-ship-1 45)
  (make-ship (ship-location example-ship-1)
             45
             0
             (ship-velocity example-ship-1)
             ship-wedge))

(define (update-rotation ship degrees)
  (make-ship (ship-location ship)
             degrees
             (ship-turn ship)
             (ship-velocity ship)
             (ship-image ship)))

;;; update-turn : Ship Number -> Ship
;;; template:
;;; (define (update-rotation ship turn)
;;;   (make-ship ...))
;;;
;;; Produce a ship with a new rotation
(check-expect
  (update-turn example-ship-1 1)
  (make-ship (ship-location example-ship-1)
             (ship-rotation example-ship-1)
             1
             (ship-velocity example-ship-1)
             ship-wedge))

(define (update-turn ship turn)
  (make-ship (ship-location ship)
             (ship-rotation ship)
             turn
             (ship-velocity ship)
             (ship-image ship)))

;;; update-image : Ship Image -> Ship
;;; template:
;;; (define (update-image ship image)
;;;   (make-ship ...))
;;;
;;; Produce a ship with a new image
(check-expect
  (update-image example-ship-1 pinprick)
  (make-ship (ship-location example-ship-1)
             0
             0
             (ship-velocity example-ship-1)
             pinprick))

(define (update-image ship image)
  (make-ship (ship-location ship)
             (ship-rotation ship)
             (ship-turn ship)
             (ship-velocity ship)
             image))

;;;; -----------------------------------------------------------------------------
;;;; Movement with wraparound
;;;; -----------------------------------------------------------------------------

;;; move-ship-x : Ship -> Ship
;;; template:
;;; (define (move-ship-x ship)
;;;   (update-location-x
;;;    ship
;;;    (cond
;;;      [< x-loc 0...]
;;;      [> x-loc width...]
;;;      [else ...])))
;;;
;;; Compute new x with screen wraparound
;;; tests for three cases: normal, wrap-left, wrap-right
(check-expect
  (move-ship-x example-ship-1)
  (update-location-x example-ship-1
                     (+ (posn-x (ship-location example-ship-1))
                        (posn-x (ship-velocity example-ship-1)))))

(define ship-left-wrap
  (make-ship (make-posn 2 100) 0 0 (make-posn -5 0) ship-wedge))

(check-expect
  (move-ship-x ship-left-wrap)
  (update-location-x ship-left-wrap
                     (+ width
                        (posn-x (ship-location ship-left-wrap))
                        (posn-x (ship-velocity ship-left-wrap)))))

(define ship-right-wrap
  (make-ship (make-posn (- width 2) 100) 0 0 (make-posn 5 0) ship-wedge))

(check-expect
  (move-ship-x ship-right-wrap)
  (update-location-x ship-right-wrap
                     (- (+ (posn-x (ship-location ship-right-wrap))
                           (posn-x (ship-velocity ship-right-wrap)))
                        width)))

(define (move-ship-x ship)
  (update-location-x
    ship 
    (cond
      ;; If posn-x is less than 0, new posn-x = width + location + velocity
      [(< (+ (posn-x (ship-location ship))
             (posn-x (ship-velocity ship)))
          0)
       (+ width
          (posn-x (ship-location ship))
          (posn-x (ship-velocity ship)))]
      ;; If posn-x is greater than width, new posn-x = location + velocity - width
      [(>= (+ (posn-x (ship-location ship))
             (posn-x (ship-velocity ship)))
          width)
       (- (+ (posn-x (ship-location ship))
             (posn-x (ship-velocity ship)))
          width)]
      ;; Otherwise, just move the ship
      [else (+ (posn-x (ship-location ship))
               (posn-x (ship-velocity ship)))])))

;;; move-ship-y : Ship -> Ship
;;; template:
;;; (define (move-ship-y ship)
;;;   (update-location-y
;;;    ship
;;;    (cond
;;;      [< y-loc 0 ...]
;;;      [> y-loc height ...]
;;;      [else ...])))
;;;
;;; Compute new y with screen wraparound
;;; tests for three cases: normal, wrap-top, wrap-bottom
(check-expect
  (move-ship-y example-ship-1)
  (update-location-y example-ship-1
                     (+ (posn-y (ship-location example-ship-1))
                        (posn-y (ship-velocity example-ship-1)))))

(define ship-top-wrap
  (make-ship (make-posn 100 2) 0 0 (make-posn 0 -5) ship-wedge))

(check-expect
  (move-ship-y ship-top-wrap)
  (update-location-y ship-top-wrap
                     (+ height
                        (posn-y (ship-location ship-top-wrap))
                        (posn-y (ship-velocity ship-top-wrap)))))

(define ship-bottom-wrap
  (make-ship (make-posn 100 (- height 2)) 0 0 (make-posn 0 5) ship-wedge))

(check-expect
  (move-ship-y ship-bottom-wrap)
  (update-location-y ship-bottom-wrap
                     (- (+ (posn-y (ship-location ship-bottom-wrap))
                           (posn-y (ship-velocity ship-bottom-wrap)))
                        height)))

(define (move-ship-y ship)
  (update-location-y
    ship 
    (cond
      ;; If posn-y is less than 0, new posn-y = height + location + velocity
      [(< (+ (posn-y (ship-location ship))
             (posn-y (ship-velocity ship)))
          0)
       (+ height
          (posn-y (ship-location ship))
          (posn-y (ship-velocity ship)))]
      ;; If posn-y is greater than height new posn-y = location + velocity - height
      [(>= (+ (posn-y (ship-location ship))
             (posn-y (ship-velocity ship)))
          height)
       (- (+ (posn-y (ship-location ship))
             (posn-y (ship-velocity ship)))
          height)]
      ;; Otherwise, just move the ship
      [else (+ (posn-y (ship-location ship))
               (posn-y (ship-velocity ship)))])))

(define (turn-ship ship)
  (update-rotation ship (+ (ship-rotation ship) (* rot (ship-turn ship)))))

;;; move-ship : Ship -> Ship
;;; template:
;;; (define (move-ship ship)
;;;   (move-ship x ... move-ship-y ...))
;;;
;;; Move the ship in both x and y with wraparound
(check-expect
  (move-ship example-ship-1)
  (move-ship-x (move-ship-y example-ship-1)))

(define (move-ship ship)
  (turn-ship (move-ship-x (move-ship-y ship))))

;;;; -----------------------------------------------------------------------------
;;;; Two Moving Ships (SW World)
;;;; -----------------------------------------------------------------------------

;;; A SW (spacewar world) is (make-sw Ship Ship)
;;; interpretation:
;;;   wedge  – the first ship
;;;   needle – the second ship

(define-struct sw [wedge needle])

;;; sw-render.v3 : SW -> Image
;;; template:
;;; (define (sw-render.v3 s)
;;;   (draw-ship ... (draw-ship ... starfield)))

;; Render both ships on top of the starfield.
;; The second ship should be drawn first so the first ship appears on top.

(define (sw-render.v3 s)
  (draw-ship (sw-wedge s)
             (draw-ship (sw-needle s)
                        starfield)))


;;; move-ships.v3 : SW -> SW
;;; template:
;;; (define (move-ships.v3 s)
;;;   (make-sw (move-ship (sw-wedge s))
;;;            (move-ship (sw-needle s))))

(define (move-ships.v3 s)
  (make-sw (move-ship (sw-wedge s))
           (move-ship (sw-needle s))))

;;;; -----------------------------------------------------------------------------
;;;; Rotation
;;;; -----------------------------------------------------------------------------

(define rot 5)

(define (turn-ship-counterclockwise ship)
  (update-turn ship 1))

(define (turn-ship-clockwise ship)
  (update-turn ship -1))

(define (turn-ship-stop ship)
  (update-turn ship 0))

(define (key-event sw ke)
  (cond
    [(key=? "left" ke) (make-sw (turn-ship-counterclockwise (sw-wedge sw)) (sw-needle sw))]
    [(key=? "right" ke) (make-sw (turn-ship-clockwise (sw-wedge sw)) (sw-needle sw))]
    [(key=? "o" ke) (make-sw (sw-wedge sw) (turn-ship-counterclockwise (sw-needle sw)))]
    [(key=? "u" ke) (make-sw (sw-wedge sw) (turn-ship-clockwise (sw-needle sw)))]
    [else sw]))

(define (key-release sw ke)
  (cond
    [(key=? "left" ke) (make-sw (turn-ship-stop (sw-wedge sw)) (sw-needle sw))]
    [(key=? "right" ke) (make-sw (turn-ship-stop (sw-wedge sw)) (sw-needle sw))]
    [(key=? "o" ke) (make-sw (sw-wedge sw) (turn-ship-stop (sw-needle sw)))]
    [(key=? "u" ke) (make-sw (sw-wedge sw) (turn-ship-stop (sw-needle sw)))]
    [else sw]))

(define (go.v4 sw)
  (big-bang sw
            [to-draw sw-render.v3]
            [on-tick move-ships.v3]
            [on-key key-event]
            [on-release key-release]))
;;;
;;; Make it go
(define (play x)
  (go.v4 (make-sw example-ship-4 example-ship-6)))

;;;; -----------------------------------------------------------------------------
;;;; Stretch Goal: Add thrust
;;;; -----------------------------------------------------------------------------

;;; We need to convert the ship's 360 degrees rotation to a point on the unit circle, so we can feed
;;; that point (or a multiple of it) into the velocity

;; Radians measure angles as fractions of a circle’s circumference, with 2π radians making a circle.
(define (degrees->radians degrees)
  (* pi (/ degrees 180)))

(define (angle->unit-x degrees)
  (cos (degrees->radians (+ degrees 90))))

(define (angle->unit-y degrees)
  (sin (degrees->radians (- degrees 90))))

(define speed 5)

(define (degrees->posn degrees)
  (make-posn (* speed (angle->unit-x degrees))
             (* speed (angle->unit-y degrees))))

(define (thrust ship)
  (make-ship (ship-location ship)
             (ship-rotation ship)
             (ship-turn ship)
             (degrees->posn (ship-rotation ship))
             (ship-image ship)))

(define (key-event.v2 sw ke)
  (cond
    [(key=? "left" ke) (make-sw (turn-ship-counterclockwise (sw-wedge sw)) (sw-needle sw))]
    [(key=? "right" ke) (make-sw (turn-ship-clockwise (sw-wedge sw)) (sw-needle sw))]
    [(key=? "up" ke) (make-sw (thrust (sw-wedge sw)) (sw-needle sw))]
    [(key=? "o" ke) (make-sw (sw-wedge sw) (turn-ship-counterclockwise (sw-needle sw)))]
    [(key=? "u" ke) (make-sw (sw-wedge sw) (turn-ship-clockwise (sw-needle sw)))]
    [(key=? "." ke) (make-sw (sw-wedge sw) (thrust (sw-needle sw)))]
    [else sw]))

(define (key-release.v2 sw ke)
  (cond
    [(key=? "left" ke) (make-sw (turn-ship-stop (sw-wedge sw)) (sw-needle sw))]
    [(key=? "right" ke) (make-sw (turn-ship-stop (sw-wedge sw)) (sw-needle sw))]
    [(key=? "o" ke) (make-sw (sw-wedge sw) (turn-ship-stop (sw-needle sw)))]
    [(key=? "u" ke) (make-sw (sw-wedge sw) (turn-ship-stop (sw-needle sw)))]
    [else sw]))

(define (go.v5 sw)
  (big-bang sw
            [to-draw sw-render.v3]
            [on-tick move-ships.v3]
            [on-key key-event.v2]
            [on-release key-release.v2]))

;;;
;;; Make it go
(define (play.v2 x)
  (go.v5 (make-sw example-ship-5 example-ship-6)))

;;;; -----------------------------------------------------------------------------
;;;; Stretch Goal: Add stop on crash
;;;; -----------------------------------------------------------------------------

(define crash 10)

(define (too-close? p1 p2)
  (< (sqrt (+ (sqr (- (posn-x p1) (posn-x p2)))
              (sqr (- (posn-y p1) (posn-y p2)))))
     crash))

(define (stop? sw)
  (too-close? (ship-location (sw-wedge sw))
              (ship-location (sw-needle sw))))

(define (go.v6 sw)
  (big-bang sw
            [to-draw sw-render.v3]
            [on-tick move-ships.v3]
            [stop-when stop?]
            [on-key key-event.v2]
            [on-release key-release.v2]))

;;;
;;; Make it go
(define (play.v3 x)
  (go.v6 (make-sw example-ship-5 example-ship-6)))


