;;;;;
;;;;; ============================================================================
;;;;; *** Spacewar! ***
;;;;;
;;;;; An implementation of Spacewar! in Racket, using big-bang functionality
;;;;; from BSL and design procedures outlined in HtDP/2e.
;;;;; ============================================================================
;;;;;

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
;;;   velocity – change in position each move (dx, dy)
;;;   image    – how the ship is drawn
(define-struct ship [location rotation velocity image])

;;; Example wedge ship image
(define ship-wedge
  (isosceles-triangle 
    (/ width 30)   ; base of wedge
    (/ height 15)  ; height of wedge
    "outline" "white"))

;;; Example ships for testing
(define example-ship-1 (make-ship (make-posn 100 150) 0 (make-posn 10 5) ship-wedge))
(define example-ship-2 (make-ship (make-posn 250 300) 0 (make-posn -5 -15) ship-wedge))
(define example-ship-3 (make-ship (make-posn 5 5) 0 (make-posn -10 -5) ship-wedge))
(define example-ship-4 (make-ship (make-posn 395 395) 0 (make-posn 15 10) ship-wedge))

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

;;; sw-render : Ship -> Image
;;; template:
;;; (define (sw-render s)
;;;   (... s starfield))
;;;
;;; Render two example ships on top of the starfield
;;; s formal parameter allows us to call sw-render from big-bang, but we ignore s in the first
;;; instance
(check-expect
  (sw-render example-ship-1)
  (draw-ship example-ship-1
             (draw-ship example-ship-2
                        starfield)))

(define (sw-render s)
  (draw-ship example-ship-1
             (draw-ship example-ship-2
                        starfield)))

;;; go : Ship -> Ship
;;; template:
;;; (define (go s)
;;;   (big-bang s
;;;             [to-draw ...]))
;;;
;;; Run a big-bang that uses sw-render but does not animate ships.
;;; NOTE: tested manually by running (go example-ship-1),
;;; not with check-expect, because big-bang opens an interactive window.
(define (go s)
  (big-bang s
            [to-draw sw-render]))

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
                         (ship-velocity example-ship-1)
                         ship-wedge))

(define (update-location-x ship x)
  (make-ship (update-posn-x (ship-location ship) x)
             (ship-rotation ship)
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
             (ship-velocity example-ship-1)
             ship-wedge))

(define (update-location-y ship y)
  (make-ship (update-posn-y (ship-location ship) y)
             (ship-rotation ship)
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
             (make-posn 3 (posn-y (ship-velocity example-ship-1)))
             ship-wedge))

(define (update-velocity-x ship x)
  (make-ship (ship-location ship)
             (ship-rotation ship)
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
             (make-posn (posn-x (ship-velocity example-ship-1)) -7)
             ship-wedge))

(define (update-velocity-y ship y)
  (make-ship (ship-location ship)
             (ship-rotation ship)
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
             (ship-velocity example-ship-1)
             ship-wedge))

(define (update-rotation ship degrees)
  (make-ship (ship-location ship)
             degrees
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
             (ship-velocity example-ship-1)
             pinprick))

(define (update-image ship image)
  (make-ship (ship-location ship)
             (ship-rotation ship)
             (ship-velocity ship)
             image))

;;;; -----------------------------------------------------------------------------
;;;; Movement (without wraparound)
;;;; -----------------------------------------------------------------------------

;;; move-ship-x-nowrap : Ship -> Ship
;;; template:
;;; (define (move-ship-x-nowrap ship)
;;;   (update-location-x ...))
;;;
;;; Move the ship in the x direction by its x-velocity.
(check-expect
  (move-ship-x-nowrap example-ship-1)
  (update-location-x example-ship-1
                     (+ (posn-x (ship-location example-ship-1))
                        (posn-x (ship-velocity example-ship-1)))))

(define (move-ship-x-nowrap ship)
  (update-location-x ship (+ (posn-x (ship-location ship))
                             (posn-x (ship-velocity ship)))))

;;; move-ship-y-nowrap : Ship -> Ship
;;; template:
;;; (define (move-ship-y-nowrap ship)
;;;   (update-location-y ...))
;;;
;;; Move the ship in the y direction by its y-velocity.
(check-expect
  (move-ship-y-nowrap example-ship-1)
  (update-location-y example-ship-1
                     (+ (posn-y (ship-location example-ship-1))
                        (posn-y (ship-velocity example-ship-1)))))

(define (move-ship-y-nowrap ship)
  (update-location-y ship (+ (posn-y (ship-location ship))
                             (posn-y (ship-velocity ship)))))

;;; move-ship-nowrap : Ship -> Ship
;;; template:
;;; (define (move-ship-nowrap ship)
;;;   (move-ship-x-nowrap ... move-ship-y-nowrap ...))
;;;
;;; Move the ship in both x and y without wrapping
(check-expect
  (move-ship-nowrap example-ship-1)
  (move-ship-x-nowrap (move-ship-y-nowrap example-ship-1)))

(define (move-ship-nowrap ship)
  (move-ship-x-nowrap (move-ship-y-nowrap ship)))

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
  (make-ship (make-posn 2 100) 0 (make-posn -5 0) ship-wedge))

(check-expect
  (move-ship-x ship-left-wrap)
  (update-location-x ship-left-wrap
                     (+ width
                        (posn-x (ship-location ship-left-wrap))
                        (posn-x (ship-velocity ship-left-wrap)))))

(define ship-right-wrap
  (make-ship (make-posn (- width 2) 100) 0 (make-posn 5 0) ship-wedge))

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
  (make-ship (make-posn 100 2) 0 (make-posn 0 -5) ship-wedge))

(check-expect
  (move-ship-y ship-top-wrap)
  (update-location-y ship-top-wrap
                     (+ height
                        (posn-y (ship-location ship-top-wrap))
                        (posn-y (ship-velocity ship-top-wrap)))))

(define ship-bottom-wrap
  (make-ship (make-posn 100 (- height 2)) 0 (make-posn 0 5) ship-wedge))

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
  (move-ship-x (move-ship-y ship)))

;;;; -----------------------------------------------------------------------------
;;;; Rendering and animation (version 2)
;;;; -----------------------------------------------------------------------------

;;; sw-render.v2 : Ship -> Image
;;; template:
;;; (define (sw-render.v2 s)
;;;   (draw-ship ...))
;;;
;;; Render one ship over the starfield background
(check-expect
  (sw-render.v2 example-ship-1)
  (draw-ship example-ship-1 starfield))

(define (sw-render.v2 s)
  (draw-ship s starfield))

;;; go.v2 : Ship -> Ship
;;; template:
;;; (define (go.v2 s)
;;;   (big-bang s
;;;             [to-draw ...]
;;;             [on-tick ...]))
;;;
;;; Start a world where the ship moves each tick.
;;; NOTE: this is interactive and does not stop on its own,
;;; so it is tested manually by running (go.v2 example-ship-1),
;;; not with check-expect.
(define (go.v2 s)
  (big-bang s
            [to-draw sw-render.v2]
            [on-tick move-ship]))

;;;; -----------------------------------------------------------------------------
;;;; Stretch Goal: Two Moving Ships (SW World)
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


;;; go.v3 : SW -> SW
;;; Start a world with two independently moving ships.

(define (go.v3 sw)
  (big-bang sw
            [to-draw sw-render.v3]
            [on-tick move-ships.v3]))

;;; Make it go
(define (play x)
  (go.v3 (make-sw example-ship-1 example-ship-2)))

;;;; -----------------------------------------------------------------------------
;;;; Additional challenges
;;;; -----------------------------------------------------------------------------

;;; 1. Draw a Needle ship that's different from the Wedge ship.
;;; 2. Add a turn-left and turn-right functions for ships.
;;; 3. Add thrust so a ship accelerates in the direction it is facing.

