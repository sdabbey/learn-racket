
#lang htdp/bsl
;;;
;;; Exercise 11
;;; Define a function that consumes two numbers, x and y, and that computes the
;;; distance of point (x,y) to the origin.
;;;
;;; In exercise 1 you developed the right-hand side of this function for concrete
;;; values of x and y. Now add a header.
;;;

(define (dist x y)
  (sqrt (+ (sqr x) (sqr y))))

(dist 2 3)

;;;
;;; Exercise 12
;;; Define the function cvolume, which accepts the length of a side of an equilateral
;;; cube and computes its volume. If you have time, consider defining csurface, too.
;;;
;;; Hint: An equilateral cube is a three-dimensional container bounded by six squares.
;;; You can determine the surface of a cube if you know that the square’s area is its
;;; length multiplied by itself. Its volume is the length multiplied with the area of
;;; one of its squares. (Why?) 
;;;

(define (cvolume side-length)
  (* (* side-length side-length) ; Surface area of a side
     side-length)) ;; Cube volume

(cvolume 2)

(define (csurface side-length)
  (* (* side-length side-length) ; Surface area of a side
     6))

(csurface 2)

;;;
;;; Exercise 13
;;; Define the function string-first, which extracts the first 1String from a
;;; non-empty string.
;;;

(define (string-first str)
  (substring str 0 1))

(string-first "abc")

;;;
;;; Exercise 14
;;; Define the function string-last, which extracts the last 1String from a
;;; non-empty string. 
;;;

(define (string-last str)
  (substring str (sub1 (string-length str))))

(string-last "hello")

;;;
;;; Exercise 15
;;; Define ==>. The function consumes two Boolean values, call them sunny
;;; and friday. Its answer is #true if sunny is false or friday is true. Note
;;; Logicians call this Boolean operation implication, and they use the
;;; notation sunny => friday for this purpose.
;;;

(define (==> sunny friday)
  (or (not sunny) friday))

(==> #true #true)
(==> #false #true)
(==> #true #false)

;;;
;;; Exercise 16
;;; Define the function image-area, which counts the number ol pixels in a
;;; given image. See exercise 6 for ideas.
;;;
(require 2htdp/image)

(define (image-area img)
  (* (image-width img) (image-height img))) ;; Width x Height gives us the total number of pixels

(define cat (bitmap "/Users/darcy/Documents/Courses/Computer Science 1 (Fall 2025)/Exercises/Images/cat1.png"))

(image-area cat)

;;;
;;; Exercise 17
;;; Define the function image-classify, which consumes an image and conditionally
;;; produces "tall" if the image is taller than wide, "wide" if it is wider than
;;; tall, or "square" if its width and height are the same. See exercise 8 for ideas. 
;;;

(define (image-classify img)
  (if (< (image-width img) (image-height img)) "tall"
      (if (> (image-width img) (image-height img)) "wide"
          "square")))

(define rect (rectangle 30 40 "solid" "grey"))

(image-classify rect)

;;;
;;; Exercise 18
;;; Define the function string-join, which consumes two strings and appends them with
;;; "_" in between. See exercise 2 for ideas. 
;;;

(define (string_join prefix suffix)
  (string-append prefix "_" suffix))

(string_join "hello" "world")

;;;
;;; Exercise 19
;;; Define the function string-insert, which consumes a string str plus a number i and
;;; inserts "_" at the ith position of str. Assume i is a number between 0 and the length
;;; of the given string (inclusive). See exercise 3 for ideas. Ponder how string-insert
;;; copes with "". 
;;;

(define (string-insert str i)
  (string-append (substring str 0 i)
                 "_"
                 (substring str i (string-length str))))

(string-insert "helloworld" 5)
(string-insert "" 0)

;;;
;;; Exercise 20
;;; Define the function string-delete, which consumes a string plus a number i and deletes
;;; the ith position from str. Assume i is a number between 0 (inclusive) and the length of
;;; the given string (exclusive). See exercise 4 for ideas. Can string-delete deal with
;;; empty strings?
;;;

(define (string-delete str i)
  (string-append (substring str 0 i)
                 (substring str (add1 i) (string-length str))))

(string-delete "helloworld" 9)
;; (string-delete "" 0) ; No, string-delete can't deal with empty strings

;;;
;;; Exercise 21
;;; Use DrRacket’s stepper to evaluate (ff (ff 1)) step-by-step. Also try (+ (ff 1) (ff 1)).
;;; Does DrRacket’s stepper reuse the results of computations?
;;;

(define (ff a)
  (* 10 a))

(ff (ff 1))

;; No, the stepper does not reuse results

;;;
;;; Exercise 22
;;; Use DrRacket’s stepper on this program fragment:
;;; (define (distance-to-origin x y) (sqrt (+ (sqr x) (sqr y)))) (distance-to-origin 3 4)
;;; Does the explanation match your intuition?
;;;

(define (distance-to-origin x y)
  (sqrt (+ (sqr x) (sqr y))))

(distance-to-origin 3 4)

;; Yes, the explnation matches my intuition

;;;
;;; Exercise 23. The first 1String in "hello world" is "h". How does the following function
;;; compute this result?
;;; (define (string-first s) (substring s 0 1))
;;; Use the stepper to confirm your ideas.
;;;

;; When we apply string-first to s, Racket substitutes whatever was submited as the formal
;; paramater s in the procedure defiintion for the s in the body of the procedure.

(string-first "hello")

;;;
;;; Exercise 24
;;; Here is the definition of ==>:
;;; (define (==> x y) (or (not x) y))
;;; Use the stepper to determine the value of (==> #true #false).

(==> #true #false) ; #false

;;;
;;; Exercise 25
;;; Take a look at this attempt to solve exercise 17:
;;; (define (image-classify img)
;;;   (cond
;;;     [(>= (image-height img) (image-width img)) "tall"]
;;;     [(= (image-height img) (image-width img)) "square"]
;;;     [(<= (image-height img) (image-width img)) "wide"]))
;;; Does stepping through an application suggest a fix? 
;;;

(define (image-classify-with-error img)
  (cond
    [(>= (image-height img) (image-width img)) "tall"]
    [(= (image-height img) (image-width img)) "square"]
    [(<= (image-height img) (image-width img)) "wide"]))

(define sq (rectangle 30 30 "solid" "grey"))
(image-classify-with-error sq)

;; Yes, stepping through suggests that the first line of cond is triggered
;; when it shouldn't be.

;;;
;;; Exercise 26.
;;; What do you expect as the value of this program:
;;;
;;; (define (string-insert s i)
;;;   (string-append (substring s 0 i)
;;;                  "_"
;;;                  (substring s i)))
;;;
;;; (string-insert "helloworld" 6)
;;;
;;; Confirm your expectation with DrRacket and its stepper
;;;

;; This program will modify s by inserting "_" at position i+1.

;;;
;;; Exercise 27.
;;; Our solution to the sample problem contains several constants in the middle of functions. As One
;;; Program, Many Definitions already points out, it is best to give names to such constants so that
;;; future readers understand where these numbers come from. Collect all definitions in DrRacket’s
;;; definitions area and change them so that all magic numbers are refactored into constant
;;; definitions. 
;;;

(define base-attendance 120)
(define base-price 5.0)
(define attendance-change 15)
(define price-change 0.1)
(define base-cost 180)
(define cost-per-attendant 0.04)

(define (attendees ticket-price)
  (- base-attendance (* (- ticket-price base-price) (/ attendance-change price-change))))

(define (revenue ticket-price)
  (* ticket-price (attendees ticket-price)))

(define (cost ticket-price)
  (+ base-cost (* cost-per-attendant (attendees ticket-price))))

(define (profit ticket-price)
  (- (revenue ticket-price)
     (cost ticket-price)))

;;;
;;; Exercise 28.
;;; Determine the potential profit for these ticket prices: $1, $2, $3, $4, and $5. Which price-change
;;; maximizes the profit of the movie theatre? Determine the best ticket price to a dime. 
;;;

(profit 1) ; 511.2
(profit 2) ; 937.2
(profit 3) ; 1063.2
(profit 4) ; 889.2
(profit 5) ; 415.2

(profit 3.10) ; 1059.3
(profit 2.90) ; 1064.1
(profit 2.80) ; 1062.0
(profit 2.70) ; 1056.9

;; So, a price for $2.90 has the greatest profit.

;;;
;;; Exercise 29.
;;; After studying the costs of a show, the owner discovered several ways of lowering the cost. As a
;;; result of these improvements, there is no longer a fixed cost; a variable cost of $1.50 per
;;; attendee remains.
;;;
(define revised-base-attendance 120)
(define revised-base-price 5.0)
(define revised-attendance-change 15)
(define revised-price-change 0.1)
(define revised-base-cost 0)
(define revised-cost-per-attendant 1.5)

(define (revised-attendees ticket-price)
  (- base-attendance (* (- ticket-price base-price) (/ attendance-change price-change))))

(define (revised-revenue ticket-price)
  (* ticket-price (attendees ticket-price)))

(define (revised-cost ticket-price)
  (+ base-cost (* cost-per-attendant (attendees ticket-price))))

(define (revised-profit ticket-price)
  (- (revenue ticket-price)
     (cost ticket-price)))

(revised-profit 3) ; 1063.2
(revised-profit 4) ; 889.2
(revised-profit 5) ; 415.2

;; The changes: set revised-based-cost to 0, and revised-cost-per-attendant to 1.5.
;; As a result, the $3 ticket price generates the most profit.

;;;
;;; Exercise 30.
;;; Define constants for the price optimization program at the movie theatre so that the price  
;;; sensitivity of attendance (15 people for every 10 cents) becomes a computed constant.
;;;

(define price-sensitivity
  (/ revised-attendance-change revised-price-change)) ; 15 people per $0.10 = 150 per $1

;;;
;;; Exercise 31. Recall the letter program from Composing Functions. Here is how to launch the program 
;;; and have it write its output to the interactions area:
;;;
;;; (write-file 'stdout (letter "Matthew" "Fisler" "Felleisen"))
;;;
;;; Dear Matthew,
;;; 
;;; We have discovered that all people with the last name Fisler have won our lottery. So, Matthew,
;;; hurry and pick up your prize.
;;;
;;; Sincerely, 
;;; Felleisen
;;; 'stdout
;;;
;;; Of course, programs are useful because you can launch them for many different inputs. Run letter
;;; on three inputs of your choice. Here is a letter-writing batch program that reads names from three 
;;; files and writes a letter to one:
;;;
;;; (define (main in-fst in-lst in-signature out)
;;;   (write-file out
;;;               (letter (read-file in-fst)
;;;                       (read-file in-lst)
;;;                       (read-file in-signature))))
;;;
;;; The function consumes four strings: the first three are the names of input files and the last one 
;;; serves as an output file. It uses the first three to read one string each from the three named 
;;; files, hands these strings to letter, and eventually writes the result of this function call into 
;;; the file named by out, the fourth argument to main.
;;;
;;; Create appropriate files, launch main, and check whether it delivers the expected letter in a 
;;; given file. 
;;;
(require 2htdp/batch-io)

(define (main in-fst in-lst in-signature out)
  (write-file out
              (letter (read-file in-fst)
                      (read-file in-lst)
                      (read-file in-signature))))

(define (letter first last signature)
  (string-append "Dear " first " " last ",\n\n"
                 "Thank you for your message.\n\n"
                 "Sincerely,\n" signature))

; Uncomment to write to disk
; (main "in-fst.txt" "in-lst.txt" "in-signature.txt" "out.txt")

;;;
;;; Exercise 32. Most people no longer use desktop computers just to run applications but also employ 
;;; cell phones, tablets, and their cars’ information control screen. Soon people will use wearable 
;;; computers in the form of intelligent glasses, clothes, and sports gear. In the somewhat more 
;;; distant future, people may come with built-in bio computers that directly interact with body 
;;; functions. Think of ten different forms of events that software applications on such computers 
;;; will have to deal with. 
;;;
;; 1. Touch gestures (tap, swipe, pinch) on screens or surfaces.
;; 2. Voice commands and speech recognition.
;; 3. Eye movement or gaze tracking.
;; 4. Heart rate or other biometric sensor changes.
;; 5. Location changes (GPS movement, geofencing).
;; 6. Proximity detection (nearby devices or objects).
;; 7. Gesture recognition (hand, arm, or body movements).
;; 8. Environmental changes (light, temperature, humidity).
;; 9. Notifications from other devices or cloud services.
;; 10. Brain-computer interface signals (thought patterns, neural activity).
;;

(require 2htdp/universe)

(define (number->square s)
  (square s "solid" "red"))

; Uncomment to run big-bang
; (big-bang 100 [to-draw number->square])

; Uncomment to run big-bang
; (big-bang 100 [to-draw number->square] [on-tick sub1] [stop-when zero?])

(define (reset s ke)
  100)

; Uncomment to run big-bang
; (big-bang 100 [to-draw number->square] [on-tick sub1] [stop-when zero?] [on-key reset])

