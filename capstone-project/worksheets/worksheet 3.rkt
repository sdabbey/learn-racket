;;;;;
;;;;; ============================================================================
;;;;; *** Spacewar! ***
;;;;;
;;;;; An implementation of Spacewar! in Racket, using big-bang functionality
;;;;; from BSL and design procedures outlined in HtDP/2e.
;;;;; ============================================================================
;;;;;

;;;; -----------------------------------------------------------------------------
;;;; Note: This is Worksheet 3.  Worksheet 2b has fixed the rotation problems
;;;; (both keyboard input conflicts and rotations that were not centred), and
;;;; added both thrust and crash detection, it's time to add firing.
;;;;
;;;; We could implement routines to fire missiles, but this method has two
;;;; drawbacks. First, we are only accustomed to using fixed-sized data at this
;;;; point.  Multiple missiles would most easily be implemented using lists or
;;;; some other data structure capable of keeping track of arbitrarily large
;;;; data.  Second, missiles would have position and velocity, and so are
;;;; handled very much the same as ships and collisions.  There's little new
;;;; to be learned.
;;;;
;;;; Instead, we are going to add lasers to our ships.  First, there is only
;;;; one laser per ship, so it's much easier to model than multiple missiles.
;;;; Second, a laser is (geometrically speaking) a line on the scene, so this
;;;; opens up new questions about how we should model it.
;;;;
;;;; In order to effect a laser, we are going to at least do the following:
;;;;   1. Extend the ship structure to include cooldown.  Cooldown is the number
;;;;      of ticks until the laser can be fired again, but we can also use it to
;;;;      determine when the laser is active (for both drawing and hitting).
;;;;   2. Add updaters as necessary to account for cooldown, and wire cooldown
;;;;      into big-bang so that it decreases every tick.
;;;;   3. Add a key to fire the laser in function pointed to by on-key.  Modify
;;;;      function pointed to by to-draw to draw the beam when cooldown is high;
;;;;      otherwise, do not draw the beam.
;;;;   4. Add a function that determines whether the laser hits a ship.
;;;;      Suggestion: figure out how to determine the distance from a point
;;;;      (a ship's current location) and a line (the laser beam).
;;;;
;;;; These sorts of changes involve revising code from Worksheet 2b.  Start with
;;;; the code in this file, and make your modifications.
;;;; -----------------------------------------------------------------------------



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

;; TODO: Modify by adding "cooldown" to the structure (after velocity).

;;; A Ship is (make-ship Posn Number Posn Image)
;;; interpretation:
;;;   location – the ship’s current position
;;;   rotation – its current angle, in degrees
;;;   turn     - its current turn value (+1: counterclockwise; 0: none; -1: clockwise) [change from 2]
;;;   velocity – change in position each move (dx, dy)
;;;   cooldown - the number of ticks until the laser can be fired again
;;;   image    – how the ship is drawn
(define-struct ship [location rotation turn velocity cooldown image])

;;; Better ship images (giving us ship-wedge and ship-needle)

;; A square will rotate properly; so we need to centre the image inside a square:
;; 1. The original wedge
(define raw-ship-wedge
  (isosceles-triangle 
    (/ width 35)   ; base
    (/ height 10)  ; height
    "outline" "white"))

(define raw-ship-needle
  (isosceles-triangle
    (/ width 20)    ; *narrower* base
    (/ height 40)    ; *longer* height
    "outline" "white"))

(define (ship-create raw)
  (overlay/align
    "middle" "middle"
    raw
    (square (max (image-width raw)
                 (image-width raw))
            "solid" "transparent")))

(define ship-wedge (ship-create raw-ship-wedge))
(define ship-needle (ship-create raw-ship-needle))

;;; Example ships for testing
(define example-ship-1 (make-ship (make-posn 100 150) 0 0 (make-posn 10 5) 0 ship-wedge))
(define example-ship-2 (make-ship (make-posn 250 300) 0 0 (make-posn -5 -15) 0 ship-wedge))
(define example-ship-3 (make-ship (make-posn 5 5) 0 0 (make-posn -10 -5) 0 ship-wedge))
(define example-ship-4 (make-ship (make-posn 395 395) 0 0 (make-posn 5 5) 0 ship-wedge))
(define example-ship-5 (make-ship (make-posn 100 150) 0 0 (make-posn 0 0) 0 ship-wedge))
(define example-ship-6 (make-ship (make-posn 400 300) 0 0 (make-posn 0 0) 0 ship-needle))

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

;; TODO: Check all updaters, and account for the new structure where necessary
;; In addition, we're going to want to add update-cooldown  What follows are the
;; unmodified updaters from Worksheet 2b.

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
;;;              (ship-turn ship)
;;;              (ship-velocity ship)
;;;              (ship-cooldown ship)
;;;              (ship-image ship)))
;;;
;;; Produce a ship like the given one but with its x-position changed
(check-expect (update-location-x example-ship-1 42)
              (make-ship (make-posn 42 (posn-y (ship-location example-ship-1)))
                         0
                         0
                         (ship-velocity example-ship-1)
                         0
                         ship-wedge))

(define (update-location-x ship x)
  (make-ship (update-posn-x (ship-location ship) x)
             (ship-rotation ship)
             (ship-turn ship)
             (ship-velocity ship)
             (ship-cooldown ship)
             (ship-image ship)))

;;; update-location-y : Ship Number -> Ship
;;; template:
;;; (define (update-location-y ship y)
;;;   (make-ship (update-posn-y ...)
;;;              (ship-rotation ship)
;;;              (ship-turn ship)
;;;              (ship-velocity ship)
;;;              (ship-cooldown ship)
;;;              (ship-image ship)))
;;;
;;; Produce a ship like the given one but with its y-position changed
(check-expect
  (update-location-y example-ship-1 999)
  (make-ship (make-posn (posn-x (ship-location example-ship-1)) 999)
             0
             0
             (ship-velocity example-ship-1)
             0
             ship-wedge))

(define (update-location-y ship y)
  (make-ship (update-posn-y (ship-location ship) y)
             (ship-rotation ship)
             (ship-turn ship)
             (ship-velocity ship)
             (ship-cooldown ship)
             (ship-image ship)))

;;;; update-velocity-x : Ship Number -> Ship
;;; template:
;;; (define (update-velocity-x ship x)
;;;   (make-ship (ship-location ship)
;;;              (ship-rotation ship)
;;;              (ship-turn ship)
;;;              (update-posn-x ...)
;;;              (ship-cooldown ship)
;;;              (ship-image ship)))
;;;
;;; Produce a ship with updated dx but same dy
(check-expect
  (update-velocity-x example-ship-1 3)
  (make-ship (ship-location example-ship-1)
             0
             0
             (make-posn 3 (posn-y (ship-velocity example-ship-1)))
             0
             ship-wedge))

(define (update-velocity-x ship x)
  (make-ship (ship-location ship)
             (ship-rotation ship)
             (ship-turn ship)
             (update-posn-x (ship-velocity ship) x)
             (ship-cooldown ship)
             (ship-image ship)))

;;; update-velocity-y : Ship Number -> Ship
;;; template:
;;; (define (update-velocity-y ship y)
;;;   (make-ship (ship-location ship)
;;;              (ship-rotation ship)
;;;              (ship-turn ship)
;;;              (update-posn-y ...)
;;;              (ship-cooldown ship)
;;;              (ship-image ship)))
;;;
;;; Produce a ship with updated dy but same dx
(check-expect
  (update-velocity-y example-ship-1 -7)
  (make-ship (ship-location example-ship-1)
             0
             0
             (make-posn (posn-x (ship-velocity example-ship-1)) -7)
             0
             ship-wedge))

(define (update-velocity-y ship y)
  (make-ship (ship-location ship)
             (ship-rotation ship)
             (ship-turn ship)
             (update-posn-y (ship-velocity ship) y)
             (ship-cooldown ship)
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
             0
             ship-wedge))

(define (update-rotation ship degrees)
  (make-ship (ship-location ship)
             degrees
             (ship-turn ship)
             (ship-velocity ship)
             (ship-cooldown ship)
             (ship-image ship)))

;;; update-turn : Ship Number -> Ship
;;; template:
;;; (define (update-turn ship turn)
;;;   (make-ship ...))
;;;
;;; Produce a ship with a new rotation
(check-expect
  (update-turn example-ship-1 1)
  (make-ship (ship-location example-ship-1)
             (ship-rotation example-ship-1)
             1
             (ship-velocity example-ship-1)
             0
             ship-wedge))

(define (update-turn ship turn)
  (make-ship (ship-location ship)
             (ship-rotation ship)
             turn
             (ship-velocity ship)
             (ship-cooldown ship)
             (ship-image ship)))

;;; update-cooldown : Ship Number -> Ship
;;; template:
;;; (define (update-cooldown ship cooldown)
;;;   (make-ship ...))
;;;
;;; Produce a ship with a new rotation
(check-expect
  (update-cooldown example-ship-1 1)
  (make-ship (ship-location example-ship-1)
             (ship-rotation example-ship-1)
             (ship-turn example-ship-1)
             (ship-velocity example-ship-1)
             1
             ship-wedge))

(define (update-cooldown ship cooldown)
  (make-ship (ship-location ship)
             (ship-rotation ship)
             (ship-turn ship)
             (ship-velocity ship)
             cooldown
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
             0
             pinprick))

(define (update-image ship image)
  (make-ship (ship-location ship)
             (ship-rotation ship)
             (ship-turn ship)
             (ship-velocity ship)
             (ship-cooldown ship)
             image))

;;;; -----------------------------------------------------------------------------
;;;; Movement with wraparound
;;;; -----------------------------------------------------------------------------

;; TODO: Modify all *-wrap examples to account for cooldown

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
  (make-ship (make-posn 2 100) 0 0 (make-posn -5 0) 0 ship-wedge))

(check-expect
  (move-ship-x ship-left-wrap)
  (update-location-x ship-left-wrap
                     (+ width
                        (posn-x (ship-location ship-left-wrap))
                        (posn-x (ship-velocity ship-left-wrap)))))

(define ship-right-wrap
  (make-ship (make-posn (- width 2) 100) 0 0 (make-posn 5 0) 0 ship-wedge))

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

;; TODO: Here and elsewhere, rewrite *-wrap functions to account for our new ship structure
(define ship-top-wrap
  (make-ship (make-posn 100 2) 0 0 (make-posn 0 -5) 0 ship-wedge))

(check-expect
  (move-ship-y ship-top-wrap)
  (update-location-y ship-top-wrap
                     (+ height
                        (posn-y (ship-location ship-top-wrap))
                        (posn-y (ship-velocity ship-top-wrap)))))

(define ship-bottom-wrap
  (make-ship (make-posn 100 (- height 2)) 0 0 (make-posn 0 5) 0 ship-wedge))

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
    [(key=? "a" ke) (make-sw (sw-wedge sw) (turn-ship-counterclockwise (sw-needle sw)))]
    [(key=? "d" ke) (make-sw (sw-wedge sw) (turn-ship-clockwise (sw-needle sw)))]
    [else sw]))

(define (key-release sw ke)
  (cond
    [(key=? "left" ke) (make-sw (turn-ship-stop (sw-wedge sw)) (sw-needle sw))]
    [(key=? "right" ke) (make-sw (turn-ship-stop (sw-wedge sw)) (sw-needle sw))]
    [(key=? "a" ke) (make-sw (sw-wedge sw) (turn-ship-stop (sw-needle sw)))]
    [(key=? "d" ke) (make-sw (sw-wedge sw) (turn-ship-stop (sw-needle sw)))]
    [else sw]))

;;;; -----------------------------------------------------------------------------
;;;; Add thrust
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
             (ship-cooldown ship)
             (ship-image ship)))

(define (key-event.v2 sw ke)
  (cond
    [(key=? "left" ke) (make-sw (turn-ship-counterclockwise (sw-wedge sw)) (sw-needle sw))]
    [(key=? "right" ke) (make-sw (turn-ship-clockwise (sw-wedge sw)) (sw-needle sw))]
    [(key=? "up" ke) (make-sw (thrust (sw-wedge sw)) (sw-needle sw))]
    [(key=? "a" ke) (make-sw (sw-wedge sw) (turn-ship-counterclockwise (sw-needle sw)))]
    [(key=? "d" ke) (make-sw (sw-wedge sw) (turn-ship-clockwise (sw-needle sw)))]
    [(key=? "w" ke) (make-sw (sw-wedge sw) (thrust (sw-needle sw)))]
    [else sw]))

(define (key-release.v2 sw ke)
  (cond
    [(key=? "left" ke) (make-sw (turn-ship-stop (sw-wedge sw)) (sw-needle sw))]
    [(key=? "right" ke) (make-sw (turn-ship-stop (sw-wedge sw)) (sw-needle sw))]
    [(key=? "a" ke) (make-sw (sw-wedge sw) (turn-ship-stop (sw-needle sw)))]
    [(key=? "d" ke) (make-sw (sw-wedge sw) (turn-ship-stop (sw-needle sw)))]
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
;;;; Stop on crash
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

;;;; -----------------------------------------------------------------------------
;;;; Add laser
;;;; -----------------------------------------------------------------------------

;;; Constants for the laser
(define laser-length                                        ;; Long enough to go outside scene
  (* 2 (max width height)))
(define laser-duration 4)                                   ;; Duration of beam in ticks
(define cooldown-duration 28)                               ;; Cooldown until next shot in ticks
(define hit-threshold (+ (/ (image-width ship-wedge) 2) 1)) ;; Laser "width" for determining a hit

;; TODO: add laser-target-x and laser-target-y.  These x and y coordinates determine the end-point
;; of the laser shot (we'll draw a line between the ship and these targets to represent the shot
;; visually, and also use the line do determine whether the laser hits anything).

;;; laser-target-x : ship -> number
;;; template:
;;; (define laser-target-x ship
;;;   (+ posn-x ... laser-length))
;;;
;;; Compute x for the end of the laser line (assumed to begin with ship location)

;; TODO: add laser-target-x and laser-target-y.  These x and y coordinates determine the end-point
;; of the laser shot (we'll draw a line between the ship and these targets to represent the shot
;; visually, and also use the line to determine whether the laser hits anything).

;;; laser-target-x : ship -> number
;;; template:
;;; ;#
;;; (define laser-target-x ship
;;;   (+ posn-x ... laser-length))
;;;
;;; Compute x for the end of the laser line (assumed to begin with ship location)
(define (laser-target-x ship)
  (+ (posn-x (ship-location ship))
     (* laser-length (angle->unit-x (ship-rotation ship)))))

(define (laser-target-y ship)
  (+ (posn-y (ship-location ship))
     (* laser-length (angle->unit-y (ship-rotation ship)))))



;;; draw-laser : ship scene -> scene
;;; template:
;;; (define (draw-laser ship scene)
;;;   (scene+line scene ... laser-target-x laser-target-y ...))
;;;
;;; Take a scene, and add the laser to it using scene+line.  (If we just use
;;; line, then we end up adjusting the size of the scene.  Scene+line lets us
;;; go outside the bounds of the scene without adjusting the scene size.
;;; (scene+line scene x1 y1 x2 y2 pen-or-color) → image?
(define (draw-laser ship scene)
  (scene+line scene
              (posn-x (ship-location ship))
              (posn-y (ship-location ship))
              (laser-target-x ship)
              (laser-target-y ship)
              "red"))

;;; ships-scene : Sw -> Scene
;;; template:
;;; ;#
;;; (define (ships-scene sw)
;;;   (... sw-wedge ... sw-needle ...)
;;;
;;; Draw the wedge and the needle (without lasers) on the starfield.
(define (ships-scene sw)
  (draw-ship (sw-wedge sw)
             (draw-ship (sw-needle sw)
                        starfield)))
;;;
;;; wedge-render : Sw -> Scene
;;; template:
;;; (define (wedge-render sw scene)
;;;   (if <cooldown large>?
;;;     (draw-laser ...)
;;;     (draw-ship ...)))
;;;
;;; Draw the laser only if laser-duration has not expired; otherwise, just draw the ship
(define (wedge-render sw scene)
  (if (negative? (- cooldown-duration laser-duration (ship-cooldown (sw-wedge sw))))
      (draw-laser (sw-wedge sw) (draw-ship (sw-wedge sw) scene))
      (draw-ship (sw-wedge sw) scene)))

;;; template:
;;; (define (needle-render sw scene)
;;;   (if <cooldown large>?
;;;     (draw-laser ...)
;;;     (draw-ship ...)))
;;;
;;; Draw the laser only if laser-duration has not expired; otherwise, just draw the ship
(define (needle-render sw scene)
  (if (negative? (- cooldown-duration laser-duration (ship-cooldown (sw-needle sw))))
      (draw-laser (sw-needle sw) (draw-ship (sw-needle sw) scene))
      (draw-ship (sw-needle sw) scene)))

;;; template:
;;; (define (sw-render.v4 sw)
;;;   scene)
;;;
;;; Render both the wedge and needle, with the lasers being drawn if necessary
(define (sw-render.v4 sw)
  (wedge-render sw (needle-render sw starfield)))
 
(define (go.v7 sw)
  (big-bang sw
            [to-draw sw-render.v4]
            [on-tick move-ships.v3]
            [stop-when stop?]
            [on-key key-event.v3]
            [on-release key-release.v2]))

;;; fire-laser : Ship -> Ship
;;; template:
;;; (define (fire-laser ship)
;;;    (make-ship ...)))
;;;
;;; Call when the user wants to fire the laser.  If cooldown is not below zero, do not fire.
(define (fire-laser ship)
  (update-cooldown ship
                   (if (negative? (ship-cooldown ship))
                       cooldown-duration
                       (ship-cooldown ship))))


;;; Wire up laser firing for both players.
(define (key-event.v3 sw ke)
  (cond
    [(key=? "left" ke) (make-sw (turn-ship-counterclockwise (sw-wedge sw)) (sw-needle sw))]
    [(key=? "right" ke) (make-sw (turn-ship-clockwise (sw-wedge sw)) (sw-needle sw))]
    [(key=? "up" ke) (make-sw (thrust (sw-wedge sw)) (sw-needle sw))]
    [(key=? "down" ke) (make-sw (fire-laser (sw-wedge sw)) (sw-needle sw))]
    [(key=? "a" ke) (make-sw (sw-wedge sw) (turn-ship-counterclockwise (sw-needle sw)))]
    [(key=? "d" ke) (make-sw (sw-wedge sw) (turn-ship-clockwise (sw-needle sw)))]
    [(key=? "w" ke) (make-sw (sw-wedge sw) (thrust (sw-needle sw)))]
    [(key=? "s" ke) (make-sw (sw-wedge sw) (fire-laser (sw-needle sw)))]
    [else sw]))


;;; Wire everything up to big-bang
(define (go.v8 sw)
  (big-bang sw
            [to-draw sw-render.v4]
            [on-tick tock]
            [stop-when stop?]
            [on-key key-event.v3]
            [on-release key-release.v2]))

;;(go.v8 (make-sw example-ship-1 example-ship-2))

;;;; -----------------------------------------------------------------------------
;;;; Add laser strikes
;;;; -----------------------------------------------------------------------------
;;;;
;;;;
;;;;

;; perp-distance : Ship Ship -> Number
;; template:
;; (define (perp-distance shooter target)
;;   (posn-x ... angle->unit-y ... posn-y ... angle->unit-x ...))
;;
;; Perpendicular distance from target to shooter's laser line (a cross-product)
(define (perp-distance shooter target)
  (abs
   (- (* (- (posn-x (ship-location target))
            (posn-x (ship-location shooter)))
         (angle->unit-y (ship-rotation shooter)))
      (* (- (posn-y (ship-location target))
            (posn-y (ship-location shooter)))
         (angle->unit-x (ship-rotation shooter))))))

;; forward? : Ship Ship -> Boolean
;; template:
;; (define (forward? shooter target)
;;   (posn-x ... angle->unit-y ... posn-y ... angle->unit-y ...))
;;
;; Is the target in front of the shooter (along laser direction)?
(define (forward? shooter target)
  (> (+ (* (- (posn-x (ship-location target))
              (posn-x (ship-location shooter)))
           (angle->unit-x (ship-rotation shooter)))
        (* (- (posn-y (ship-location target))
              (posn-y (ship-location shooter)))
           (angle->unit-y (ship-rotation shooter))))
     0))

;;; cooldown-ship : ship -> ship
;;; template:
;;; (define (cooldown ship)
;;;   (update-cooldown ...)))
;;;
;;; Cooldown the ship by 1 unit
(define (cooldown-ship ship)
  (update-cooldown ship (sub1 (ship-cooldown ship))))

(define (tock sw)
  (make-sw (cooldown-ship (move-ship (sw-wedge sw)))
           (cooldown-ship (move-ship (sw-needle sw)))))

;; laser-active? : Ship -> Boolean
;; template
;; (define (laser-active? ship) ...)
;; 
;; Is the laser currently active?
(define (laser-active? ship)
  (negative? (- cooldown-duration laser-duration (ship-cooldown ship))))

;; laser-hits? : Ship Ship -> Boolean
;; Does the shooter's laser hit the target?
(define (laser-hits? shooter target)
  (and (laser-active? shooter)
       (forward? shooter target)
       (< (perp-distance shooter target) hit-threshold)))


;; stop?.v2 : SW -> Boolean
;; template:
;; (define (stop?.v2)
;;   (or (too-close? ...)
;;       (laser-hits? ...<wedge, needle>)
;;       (laser-hits? ...<needle, wedge>)))
;;
;; Stop when ships crash or a laser hits
(define (stop?.v2 sw)
  (or (too-close? (ship-location (sw-wedge sw))
                  (ship-location (sw-needle sw)))    ; crash
      (laser-hits? (sw-wedge sw) (sw-needle sw))     ; wedge hits needle
      (laser-hits? (sw-needle sw) (sw-wedge sw))))   ; needle hits wedge


(define (last-scene sw)
(cond
  ;; Wedge laser hit Needle
  [(laser-hits? (sw-wedge sw) (sw-needle sw))
    (overlay/align "middle" "top"
                  (text/font "Wedge wins!" 30 "white" "monospace" 'default 'normal 'normal #f)
                  (draw-laser (sw-wedge sw) (ships-scene sw)))]

  ;; Needle laser hit Wedge
  [(laser-hits? (sw-needle sw) (sw-wedge sw))
    (overlay/align "middle" "top"
                  (text/font "Needle wins!" 30 "white" "monospace" 'default 'normal 'normal #f)
                  (draw-laser (sw-needle sw) (ships-scene sw)))]

  ;; Crash or draw condition
  [else
    (overlay/align "middle" "top"
                  (text/font "Draw!" 30 "white" "monospace" 'default 'normal 'normal #f)
                  (sw-render.v4 sw))]))



;;; Wire it up
(define (go.v9 sw)
(big-bang sw
          [to-draw sw-render.v4]
          [on-tick tock]
          [stop-when stop?.v2 last-scene]
          [on-key key-event.v3]
          [on-release key-release.v2]))




;;; Make it go
(go.v9 (make-sw example-ship-5 example-ship-6))

