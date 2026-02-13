
#lang htdp/bsl
;;;
;;; Exercise 1
;;;
;;; Add the following definitions for x and y to DrRacket’s definitions area:
;;; (define x 3)
;;; (define y 4)
;;; Now imagine that x and y are the coordinates of a Cartesian point. Write
;;; down an expression that computes the distance of this point to the origin,
;;; that is, a point with the coordinates (0,0).
;;;

(define x 3)
(define y 4)

(sqrt (+ (* x x) (* y y)))

;;;
;;; Exercise 2
;;;
;;; Add the following two lines to the definitions area:
;;; (define prefix "hello")
;;; (define suffix "world")
;;; Then use string primitives to create an expression that concatenates prefix
;;; and suffix and adds "_" between them. When you run this program, you will see
;;; "hello_world" in the interactions area.
;;;

(define prefix "hello")
(define suffix "world")

(string-append prefix "_" suffix)

;;;
;;; Exercise 3
;;;
;;; Add the following two lines to the definitions area:
;;; (define str "helloworld")
;;; (define i 5)
;;; Then create an expression using string primitives that adds "_" at position i.
;;; In general this means the resulting string is longer than the original one; here
;;; the expected result is "hello_world".
;;;

(define str "helloworld")
(define i 9)

(string-append (substring str 0 i)
               "_"
               (substring str i (string-length str)))

;;;
;;; Exercise 4
;;;
;;; Use the same setup as in exercise 3 to create an expression that deletes the ith
;;; position from str. Clearly this expression creates a shorter string than the given
;;; one. Which values for i are legitimate?
;;;

(string-append (substring str 0 i)
               (substring str (add1 i) (string-length str)))

;; Legitimate values for i are from 0 to (sub1 (string-length str))

;;; 
;;; Exercise 5
;;;
;;; Use the 2htdp/image teachpack to create the image of a simple boat or tree. Make
;;; sure you can easily change the scale of the entire image.   
;;;

(require 2htdp/image)

(define height 300)
(define width 300)

;; Define shapes for each of the parts of the boat, in terms of height and width
(define sail (isosceles-triangle (* height 0.5) 40 "solid" "yellow"))
(define mast (rectangle (* width 0.02) (* height 0.1) "solid" "brown"))
(define hull (rectangle (* width 0.8) (* height 0.1) "solid" "red"))
(define water (rectangle (* width 1.5) (* height 0.1) "solid" "blue"))

;; Put the boat together, and include the water
(above sail mast hull water)

;;;
;;; Exercise 6
;;;
;;; Add the following line to the definitions area:Copy and paste the image into your DrRacket.
;;; (define cat ...)
;;; Create an expression that counts the number of pixels in the image. 
;;;

(define cat (bitmap "/Users/darcy/Documents/Courses/Computer Science 1 (Fall 2025)/Exercises/Images/cat1.png"))

(* (image-width cat) (image-height cat)) ;; Width x Height gives us the total number of pixels

;;;
;;; Exercise 7
;;;
;;; Boolean expressions can express some everyday problems. Suppose you want to decide whether
;;; today is an appropriate day to go to the mall. You go to the mall either if it is not sunny
;;; or if today is Friday (because that is when stores post new sales items). Here is how you
;;; could go about it using your new knowledge about Booleans. First add these two lines to the
;;; definitions area of DrRacket:
;;; (define sunny #true)
;;; (define friday #false)
;;; Now create an expression that computes whether sunny is false or friday is true. So in this
;;; particular case, the answer is #false. (Why?)
;;;

(define sunny #true)
(define friday #false)

(or (not sunny) friday) ;; Not sunny = false; friday = false.  So the disjunction is false.

;;;
;;; Exercise 8
;;;
;;; Add the following line to the definitions area:
;;; (define cat ...)
;;; Create a conditional expression that computes whether the image is tall or wide. An image
;;; should be labeled "tall" if its height is larger than or equal to its width; otherwise it
;;; is "wide". As you experiment, replace the cat with a rectangle of your choice to ensure that
;;; you know the expected answer.
;;;
;;; Now try the following modification. Create an expression that computes whether a picture is
;;; "tall", "wide", or "square". 
;;;

(if (< (image-width cat) (image-height cat))
      "tall" "wide")

(define rect-width 30)
(define rect-height 30)
(define rect (rectangle rect-width rect-height "solid" "grey"))

(if (< (image-width rect) (image-height rect)) "tall"
  (if (> (image-width rect) (image-height rect)) "wide"
    "square"))

;;;
;;; Exercise 9
;;;
;;; Add the following line to the definitions area of DrRacket:
;;; (define in ...)
;;; Then create an expression that converts the value of in to a non-negative number.
;;; For a String, it determines how long the String is; for an Image, it uses the
;;; area; for a Number, it uses the absolute value; for #true it uses 10 and for
;;; #false 20. Hint Check out cond from the Prologue: How to Program (again).
;;;

(define in "cat")

(cond
  [(string? in) (string-length in)]
  [(image? in) (* (image-width in) (image-height in))]
  [(number? in) (abs in)]
  [(boolean? in) (if in 10 20)])

;;;
;;; Exercise 10
;;;
;;; Now relax, eat, sleep, and then tackle the next chapter.
;;;

