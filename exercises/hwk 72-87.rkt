
#lang htdp/bsl
(require 2htdp/universe)
(require 2htdp/image)

;;;
;;; Exercise 72. Formulate a data definition for the above phone structure type definition (e.g.: 
;;; (define-struct phone [area number]) that accommodates the given examples. Next formulate a data
;;; definition for phone numbers using this structure type definition:
;;;
;;;    (define-struct phone# [area switch num])
;;;
;;; Historically, the first three digits make up the area code, the next three the code for the phone
;;; switch (exchange) of your neighborhood, and the last four the phone with respect to the
;;; neighborhood. Describe the content of the three fields as precisely as possible with intervals. 
;;;

#|
Structure Definition: (define-struct phone [area number])
Data Definition: A Phone is a structure: (make-phone area number)
                 where: - area is a 3-digit natural number between 200 and 999
                        - number is a 8 character string consisting of 3 digits (corresponding
                          to a natural number between 200 and 999), followed by a hyphen (-),
                          followed by 4 digits (corresponding to a natural number between 0000
                          and 9999.

Structure Definition: (define-struct phone# [area switch num])
Data Definition: A Phone# is a structure: (make-phone# area switch num)
                 where: - area   is a 3-digit natural number between 200 and 999
                        - switch is a 3-digit natural number between 200 and 999
                        - num    is a 4-digit natural number between 0000 and 9999

Here are some examples: (define ph-1 (make-phone# 802 440 1234)) ; Vermont
                        (define ph-2 (make-phone# 617 555 8901)) ; Massachusetts
                        (define ph-3 (make-phone# 212 300 9999)) ; New York City
|#

;;;
;;; Exercise 73. Exercise 73. Design the function posn-up-x, which consumes a Posn p and a Number n.
;;; It produces a Posn like p with n in the x field.
;;;
;;; A neat observation is that we can define x+ using posn-up-x:
;;; 
;;;     (define (x+ p)
;;;       (posn-up-x p (+ (posn-x p) 3)))
;;; 
;;; Note: Functions such as posn-up-x are often called updaters or functional setters. They are
;;; extremely useful when you write large programs. 
;;;

;; Signature and Purpose:
;; posn-update-x : Posn Number -> Posn
;; Given a Posn p and a Number n, produce a new Posn like p but with its x-coordinate replaced by n.

;; Examples:
(check-expect (posn-update-x (make-posn 10 0) 13) (make-posn 13 0))
(check-expect (posn-update-x (make-posn 5 9) 0)   (make-posn 0 9))

;; Template:
#;
(define (posn-update-x p n)
  (... (posn-y p)
       n))

;; Code:
(define (posn-update-x p n)
  (make-posn n (posn-y p)))

;;;
;;; Exercise 74. Copy all relevant constant and function definitions to DrRacket’s definitions area.
;;; Add the tests and make sure they pass. Then run the program and use the mouse to place the red
;;; dot. 
;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copied from text:
(define MTS (empty-scene 100 100))
(define DOT (circle 3 "solid" "red"))

;; Posn -> Image
;; adds a red spot to MTS at p
(define (scene+dot p) MTS)

(define (x+ p)
  (make-posn (+ (posn-x p) 3) (posn-y p)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Signature and Purpose:
;; reset-dot: Posn Number Number MouseEvt -> Posn
;; on button-down, move dot to (Number, Number); else keep original Posn
(check-expect (reset-dot (make-posn 10 20) 29 31 "button-down") (make-posn 29 31))
(check-expect (reset-dot (make-posn 10 20) 29 31 "button-up")   (make-posn 10 20))

;; Template:
#;
(define (reset-dot p x y me)
  (... (make-posn x y) ...))

;; Code:
(define (reset-dot p x y me)
  (cond
    [(equal? me "button-down") (make-posn x y)]
    [else p]))

;; To run, call main:
(define (main p0)
  (big-bang p0
    [on-tick x+]
    [on-mouse reset-dot]
    [to-draw scene+dot]))


;;;
;;; Exercise 75. Enter these definitions and their test cases into the definitions area of DrRacket
;;; and make sure they work. This is the first time that you have dealt with a “wish,” and you need to
;;; make sure you understand how the two functions work together. 
;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copied from text:
(define-struct vel [deltax deltay])
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-struct ufo [loc vel])
;; A UFO is (make-ufo Posn Vel)

; examples
(define v1 (make-vel 8 -3))
(define v2 (make-vel -5 -3))
(define p1 (make-posn 22 80))
(define p2 (make-posn 30 77))
(define u1 (make-ufo p1 v1))
(define u2 (make-ufo p1 v2))
(define u3 (make-ufo p2 v1))
(define u4 (make-ufo p2 v2))

#|
Original code, pre-wish:

;; Now suppose we want to calculate one move of the ufo; we could do
;; it with `ufo-move-1`, and given the above, we'd expect u1 (location p1
;; plus velocity v1) to give us u3 (change of location, but not of velo).
(check-expect (ufo-move-1 u1) u3)

;; Ufo -> Ufo
(define (ufo-move-1 u)
  (make-ufo                                 ; updated ufo
    (make-posn (+ (posn-x (ufo-loc u))      ; updated position x
                  (vel-deltax (ufo-vel u)))
               (+ (posn-y (ufo-loc u))      ; updated position y
                  (vel-deltay (ufo-vel u))))
    (ufo-vel u)))
|#

;; Wish: Find a new Posn based on current Posn and Vel
;; Posn Vel -> Posn
#;
(define (posn+ p v) p)

;; Fulfil the wish: posn+ knows *how* to update, but not *why*
;; posn+: Posn Vel -> Posn
;; Calculate the new Posn of a Ufo, given the original position and a velocity
(define (posn+ p v)
  (make-posn (+ (posn-x p) (vel-deltax v))   ; updated position x
             (+ (posn-y p) (vel-deltay v)))) ; updated position y

(check-expect (posn+ p1 v1) p2)
(check-expect (posn+ p1 v2) (make-posn 17 77))
(check-expect (posn+ p2 v1) (make-posn 38 74))
(check-expect (posn+ p2 v2) (make-posn 25 74))

;; Ufo -> Ufo
(define (ufo-move-1a u)
  (make-ufo (posn+ (ufo-loc u) (ufo-vel u)) ; updated ufo loctaion
            (ufo-vel u)))                   ; updated ufo velocity

(check-expect (ufo-move-1a u1) u3)
(check-expect (ufo-move-1a u2) (make-ufo (make-posn 17 77) v2))
(check-expect (ufo-move-1a u3) (make-ufo (make-posn 38 74) v1))
(check-expect (ufo-move-1a u4) (make-ufo (make-posn 25 74) v2))

;;;
;;; Exercise 76. Formulate data definitions for the following structure type definitions:
;;;
;;;    (define-struct movie [title producer year])
;;;    (define-struct person [name hair eyes phone])
;;;    (define-struct pet [name number])
;;;    (define-struct CD [artist title price])
;;;    (define-struct sweater [material size producer])
;;;
;;; Make sensible assumptions as to what kind of values go into each field. 
;;;

(define-struct movie [title producer year])
;; A Movie is (make-movie title producer year)
;; where:
;;   title    : String    — title of the movie
;;   producer : String    — producer’s name
;;   year     : Natural   — release year (e.g., 1888–present)
;; Interpretation: represents one movie and its production year.

;; Examples
(define m1 (make-movie "Metropolis" "Erich Pommer" 1927))
(define m2 (make-movie "Arrival"    "Shawn Levy"   2016))

(define-struct person [name hair eyes phone])
;; A Person is (make-person name hair eyes phone)
;; where:
;;   name  : String  — person's name
;;   hair  : String  — hair color ("blonde", "black", etc.)
;;   eyes  : String  — eye color ("green", "brown", etc.)
;;   phone : String  — phone number as a string "(802) 555-0912"
;; Interpretation: describes one human being and their basic features.

;; Examples
(define alice (make-person "Alice" "brown" "green" "(802) 440-2211"))
(define bob   (make-person "Bob"   "blonde" "blue" "(212) 555-8765"))

(define-struct pet [name number])
;; A Pet is (make-pet name number)
;; where:
;;   name   : String  — pet’s name
;;   number : Number  — identification tag or license number (positive integer)
;; Interpretation: represents one registered pet.

;; Examples
(define pet1 (make-pet "Rex"     1023))
(define pet2 (make-pet "Mittens" 874))

(define-struct CD [artist title price])
;; A CD is (make-CD artist title price)
;; where:
;;   artist : String  — recording artist
;;   title  : String  — album title
;;   price  : Number  — price in dollars (>= 0)
;; Interpretation: represents a compact disc for sale.

;; Examples
(define cd1 (make-CD "The Beatles" "Abbey Road" 14.99))
(define cd2 (make-CD "Björk"       "Homogenic"  12.50))

(define-struct sweater [material size producer])
;; A Sweater is (make-sweater material size producer)
;; where:
;;   material : String  — material ("wool", "cotton", "synthetic", ...)
;;   size     : String  — size ("S", "M", "L", "XL")
;;   producer : String  — producer or brand
;; Interpretation: represents one article of clothing.

;; Examples
(define sw1 (make-sweater "wool"   "M" "Arcteryx"))
(define sw2 (make-sweater "cotton" "L" "Roots"))

;;;
;;; Exercise 77. Provide a structure type definition and a data definition for representing points in
;;; time since midnight. A point in time consists of three numbers: hours, minutes, and seconds. 
;;;

(define-struct time [hours minutes seconds])
;; A Time is (make-time hours minutes seconds)
;; where
;;   hours   : Integer  — number of hours since midnight, [0, 23]
;;   minutes : Integer  — number of minutes after the hour, [0, 59]
;;   seconds : Integer  — number of seconds after the minute, [0, 59]
;;
;; Interpretation:
;;   Represents a specific point in the day since midnight.
;;   For example, (make-time 13 45 30) means 1:45:30 PM.

;; Examples:
(define t0 (make-time 0 0 0))    ; midnight
(define t1 (make-time 7 30 0))   ; 7:30:00 AM
(define t2 (make-time 12 0 15))  ; 12:00:15 PM
(define t3 (make-time 23 59 59)) ; one second before midnight

;;;
;;; Exercise 78. Provide a structure type and a data definition for representing three-letter words.
;;; A word consists of lowercase letters, represented with the 1Strings "a" through "z" plus #false.
;;; Note This exercise is a part of the design of a hangman game; see exercise 396. 
;;;

(define-struct word3 [letter-1 letter-2 letter-3])
;; A Letter is one of:
;; – "a" through "z" ; lowercase 1String
;; – #false          ; if the letter is hidden or not yet guessed

;; A Word3 is a structure: (make-word3 letter-1 letter-2 letter-3)
;; where
;;   letter-1 : 1String — first letter of the word3
;;   letter-2 : 1String — second letter of the word3
;;   letter-3 : 1String — third letter of the word3
;;
;; Interpretation:
;;   Represents a three-letter word for a Hangman game.
;;   A letter may be known (a 1String) or unknown (#false).

;;;
;;; Exercise 79. Create examples for the following data definitions:
;;;
;;;        A Color is one of: 
;;;        — "white"
;;;        — "yellow"
;;;        — "orange"
;;;        — "green"
;;;        — "red"
;;;        — "blue"
;;;        — "black"
;;;
;;;        ; H is a Number between 0 and 100.
;;;        ; interpretation represents a happiness value
;;;
;;;        (define-struct person [fstname lstname male?])
;;;        ; A Person is a structure:
;;;        ;   (make-person String String Boolean)
;;;
;;;    Is it a good idea to use a field name that looks like the name of a predicate?
;;;
;;;        (define-struct dog [owner name age happiness])
;;;        ; A Dog is a structure:
;;;        ;   (make-dog Person String PositiveInteger H)
;;;
;;;    Add an interpretation to this data definition, too.
;;;
;;;        ; A Weapon is one of: 
;;;        ; — #false
;;;        ; — Posn
;;;        ; interpretation #false means the missile hasn't 
;;;        ; been fired yet; a Posn means it is in flight
;;;
;;; The last definition is an unusual itemization, combining built-in data with a structure type.
;;;

;; A Color is one of:
;; – "white"
;; – "yellow"
;; – "orange"
;; – "green"
;; – "red"
;; – "blue"
;; – "black"
;; Interpretation: represents one of the basic named colors.

;;Examples:
(define C1 "red")
(define C2 "blue")
(define C3 "green")

;; H is a Number between 0 and 100.
;; Interpretation: represents a happiness value as a percentage.
;;   0   = completely unhappy
;;   100 = perfectly happy

(define H1 0)
(define H2 65)
(define H3 100)

(define-struct person1 [fstname lstname male?])
;; A Person is (make-person String String Boolean)
;;
;; Interpretation:
;;   represents a person’s first and last name, and whether the person is male.
;;
;; Note: Using a field name ending with "?" (like `male?`) is *not ideal* for a structure field, since
;; "?" usually signals a predicate function (returns a Boolean).  A clearer name would be `is-male`.

;; Examples:
(define p-a (make-person1 "Alice" "Nguyen" #false))
(define p-b (make-person1 "Bob"   "Patel"  #false))
(define p-c (make-person1 "Chuck" "Kim"    #true))

(define-struct dog [owner name age happiness])
;; A Dog is (make-dog Person String PositiveInteger H)
;;
;; Interpretation:
;;   represents a dog with
;;     – an owner (a Person)
;;     – a name
;;     – an age in years (a positive integer)
;;     – a happiness value between 0 and 100

;; Examples (dogs are normally completely happy):
(define d1 (make-dog p-a "Rex"    5 100))
(define d2 (make-dog p-b "Mochi"  2 100))
(define d3 (make-dog p-c "Shadow" 8 100))

;; A Weapon is one of:
;; – #false
;; – Posn
;;
;; Interpretation:
;;   #false means the missile has not yet been fired.
;;   A Posn represents the missile’s position while in flight.

;; Examples:
(define w1 #false)              ; not fired yet
(define w2 (make-posn 30 50))   ; currently flying
(define w3 (make-posn 200 100)) ; farther along in flight

;;;
;;; Exercise 80. Create templates for functions that consume instances of the following structure
;;; types:
;;;
;;;    (define-struct movie [title director year])
;;;    (define-struct pet [name number])
;;;    (define-struct CD [artist title price])
;;;    (define-struct sweater [material size color])
;;;
;;; No, you do not need data definitions for this task. 
;;;

;; (define-struct movie [title director year])
;; movie-template : Movie -> ??
(define (movie-watch m)
  (... (movie-title m)
       (movie-director m)
       (movie-year m) ...))

;; (define-struct pet [name number])
;; pet-template : Pet -> ??
(define (pet-feed p)
  (... (pet-name p)
       (pet-number p) ...))


;; (define-struct CD [artist title price])
;; CD-template : CD -> ??
(define (CD-play cd)
  (... (CD-artist cd)
       (CD-title cd)
       (CD-price cd) ...))

;; (define-struct sweater [material size color])
;; sweater-template : Sweater -> ??
(define (sweater-wear s)
  (... (sweater-material s)
       (sweater-size s)
       (sweater-color s) ...))

;;;
;;; Exercise 81. Design the function time->seconds, which consumes instances of time structures (see
;;; exercise 77) and produces the number of seconds that have passed since midnight. For example, if
;;; you are representing 12 hours, 30 minutes, and 2 seconds with one of these structures and if you
;;; then apply time->seconds to this instance, the correct result is 45002. 
;;;

;;(define-struct time [hours minutes seconds])
;; A Time is (make-time hours minutes seconds)
;; where:
;;   hours   : Integer in [0, 23]
;;   minutes : Integer in [0, 59]
;;   seconds : Integer in [0, 59]
;; Interpretation: the point in the day since midnight.

;; ------------------------------------------------------------
;; time->seconds : Time -> Number
;; Produce the total number of seconds that have passed since midnight.

;; Examples
(check-expect (time->seconds (make-time 0 0 0)) 0)
(check-expect (time->seconds (make-time 0 1 0)) 60)
(check-expect (time->seconds (make-time 1 0 0)) 3600)
(check-expect (time->seconds (make-time 1 1 1)) 3661)
(check-expect (time->seconds (make-time 12 30 2)) 45002)

;; Template
#;
(define (time->seconds t)
  (... (time-hours t)
       (time-minutes t)
       (time-seconds t) ...))

;; Definition
(define (time->seconds t)
  (+ (* (time-hours t) 3600)
     (* (time-minutes t) 60)
     (time-seconds t)))

;;;
;;; Exercise 82. Design the function compare-word. The function consumes two three-letter words (see
;;; exercise 78). It produces a word that indicates where the given ones agree and disagree. The
;;; function retains the content of the structure fields if the two agree; otherwise it places #false
;;; in the field of the resulting word. Hint The exercises mentions two tasks: the comparison of words
;;; and the comparison of “letters.” 
;;;

;; compare-word : Word3 Word3 -> Word3
;; Produce a new word that keeps the same letter in each position where both words match, and #false
;; where they differ.
;;
;; Note: We need to compare corresponding letters before combining results into a word3.
;;
;; Helper: compare-letter
;; compare-letter : Letter Letter -> Letter
;; Produce the letter if both are equal; otherwise #false.

(define (compare-letter a b)
  (if (equal? a b)
      a
      #false))

;; Examples
(define wd1 (make-word3 "c" "a" "t"))
(define wd2 (make-word3 "c" "o" "t"))
(define wd3 (make-word3 "d" "o" "g"))
(define wd4 (make-word3 #false "a" "t"))

(check-expect (compare-letter "a" "a") "a")
(check-expect (compare-letter "a" "b") #false)

(check-expect (compare-word wd1 wd2)
              (make-word3 "c" #false "t"))

(check-expect (compare-word wd1 wd3)
              (make-word3 #false #false #false))

(check-expect (compare-word wd1 wd4)
              (make-word3 #false "a" "t"))

;; Definition
(define (compare-word w1 w2)
  (make-word3 (compare-letter (word3-letter-1 w1) (word3-letter-1 w2))
              (compare-letter (word3-letter-2 w1) (word3-letter-2 w2))
              (compare-letter (word3-letter-3 w1) (word3-letter-3 w2))))

;;;
;;; Exercise 83. Design the function render, which consumes an Editor and produces an image.
;;;
;;; The purpose of the function is to render the text within an empty scene of image pixels. For the
;;; cursor, use a image red rectangle and for the strings, black text of size 16.
;;;
;;; Develop the image for a sample string in DrRacket’s interactions area. We started with this
;;; expression:
;;;
;;;    (overlay/align "left" "center"
;;;                   (text "hello world" 11 "black")
;;;                   (empty-scene 200 20))
;;;
;;; You may wish to read up on beside, above, and such functions. When you are happy with the looks
;;; of the image, use the expression as a test and as a guide to the design of render. 
;;;

;; Data (simple editor):
(define-struct editor [pre post])
;; An Editor is (make-editor String String)
;; Interpretation: cursor sits between pre and post.

;; -------------------- Rendering constants -------------------
(define SCENE-WIDTH   200)
(define SCENE-HEIGHT  20)
(define FONT-SIZE     16)
(define FONT-COLOR    "black")
(define CURSOR-WIDTH  1)
(define CURSOR-HEIGHT 20)
(define CURSOR-COLOR  "red")

(define CURSOR (rectangle CURSOR-WIDTH CURSOR-HEIGHT "solid" CURSOR-COLOR))

;; -------------------- Helpers -------------------------------
;; editor->line : Editor -> Image
;; Build a single-line image: [pre-text] [cursor] [post-text]
(define (editor->line e)
  (beside (text (editor-pre e) FONT-SIZE FONT-COLOR)
          CURSOR
          (text (editor-post e) FONT-SIZE FONT-COLOR)))

;; render : Editor -> Image
;; Place the line image left-centred onto an empty scene.
(define (render e)
  (overlay/align "left" "center"
                 (editor->line e)
                 (empty-scene SCENE-WIDTH SCENE-HEIGHT)))

;; -------------------- Examples & Tests ----------------------
(define E-hello (make-editor "hello " "world"))
(define E-begin (make-editor "" "start"))
(define E-end   (make-editor "done" ""))
(define E-mid   (make-editor "abc" "def"))

;; The problem statement's starting point (adapted to our settings)
(define SAMPLE
  (overlay/align "left" "center"
                 (text "hello world" FONT-SIZE FONT-COLOR)
                 (empty-scene SCENE-WIDTH SCENE-HEIGHT)))

;; Our expected image when the cursor is between "hello " and "world"
(define EXPECT-hello
  (overlay/align "left" "center"
                 (beside (text "hello " FONT-SIZE FONT-COLOR)
                         CURSOR
                         (text "world" FONT-SIZE FONT-COLOR))
                 (empty-scene SCENE-WIDTH SCENE-HEIGHT)))

(check-expect (render E-hello) EXPECT-hello)

;; Cursor at beginning
(check-expect (render E-begin)
              (overlay/align "left" "center"
                             (beside CURSOR
                                     (text "start" FONT-SIZE FONT-COLOR))
                             (empty-scene SCENE-WIDTH SCENE-HEIGHT)))

;; Cursor at end
(check-expect (render E-end)
              (overlay/align "left" "center"
                             (beside (text "done" FONT-SIZE FONT-COLOR)
                                     CURSOR)
                             (empty-scene SCENE-WIDTH SCENE-HEIGHT)))

;; Cursor in the middle
(check-expect (render E-mid)
              (overlay/align "left" "center"
                             (beside (text "abc" FONT-SIZE FONT-COLOR)
                                     CURSOR
                                     (text "def" FONT-SIZE FONT-COLOR))
                             (empty-scene SCENE-WIDTH SCENE-HEIGHT)))

;;;
;;; Exercise 84. Design edit. The function consumes two inputs, an editor ed and a KeyEvent ke, and it
;;; produces another editor. Its task is to add a single-character KeyEvent ke to the end of the pre
;;; field of ed, unless ke denotes the backspace ("\b") key. In that case, it deletes the character
;;; immediately to the left of the cursor (if there are any). The function ignores the tab key ("\t")
;;; and the return key ("\r").
;;;
;;; The function pays attention to only two KeyEvents longer than one letter: "left" and "right". The
;;; left arrow moves the cursor one character to the left (if any), and the right arrow moves it one
;;; character to the right (if any). All other such KeyEvents are ignored.
;;;
;;; Develop a goodly number of examples for edit, paying attention to special cases. When we solved
;;; this exercise, we created 20 examples and turned all of them into tests.
;;;
;;; Hint: Think of this function as consuming KeyEvents, a collection that is specified as an
;;; enumeration. It uses auxiliary functions to deal with the Editor structure. Keep a wish list
;;; handy; you will need to design additional functions for most of these auxiliary functions, such
;;; as string-first, string-rest, string-last, and string-remove-last. If you haven’t done so, solve
;;; the exercises in Functions. 
;;;

;;
;; String helpers (started as a wish list)
;;

;; string-first : non-empty String -> 1String
;; produces the first 1String of a String
(define (string-first s)
  (substring s 0 1))

;; string-rest : non-empty String -> String
;; produces a String that is follows the first 1String
(define (string-rest s)
  (substring s 1))

;; string-last : non-empty String -> 1String
;; produces the last 1String in a String
(define (string-last s)
  (substring s (- (string-length s) 1)))

;; string-remove-last : non-empty String -> String
;; produces a String without its last 1String
(define (string-remove-last s)
  (substring s 0 (- (string-length s) 1)))

;;
;; Other helpers
;;

;; printable-1string? : String -> Boolean
;; true for single-character keys that are not control chars we handle specially
(define (printable-1string? ke)
  (and (= (string-length ke) 1)
       (not (or (string=? ke "\b")     ; backspace handled separately
                (string=? ke "\t")     ; ignore
                (string=? ke "\r"))))) ; ignore

;; move-left : Editor -> Editor
;; move one char from end of pre to front of post (if any)
(define (move-left ed)
  (if (= (string-length (editor-pre ed)) 0)
      ed
      (make-editor (string-remove-last (editor-pre ed))
                   (string-append (string-last (editor-pre ed))
                                  (editor-post ed)))))

;; move-right : Editor -> Editor
;; move one char from front of post to end of pre (if any)
(define (move-right ed)
  (if (= (string-length (editor-post ed)) 0)
      ed
      (make-editor (string-append (editor-pre ed)
                                  (string-first (editor-post ed)))
                   (string-rest (editor-post ed)))))

;; backspace : Editor -> Editor
;; delete char to the left of cursor (if any)
(define (backspace ed)
  (if (= (string-length (editor-pre ed)) 0)
      ed
      (make-editor (string-remove-last (editor-pre ed))
                   (editor-post ed))))

;; insert-1 : Editor 1String -> Editor
;; append a single character to pre
(define (insert-1 ed ch)
  (make-editor (string-append (editor-pre ed) ch)
               (editor-post ed)))

;; edit : Editor String -> Editor
;; Consume an editor and a key event and produce the updated editor.
;;
;; Behaviour:
;; - 1-character printable key -> insert into pre
;; - "\b" backspace -> delete one char left of cursor
;; - "\t", "\r" -> ignore
;; - "left" / "right" -> move cursor left/right by one (if possible)
;; - anything else -> ignore
;;
(define (edit ed ke)
  (cond
    [(string=? ke "left")  (move-left ed)]
    [(string=? ke "right") (move-right ed)]
    [(string=? ke "\b")    (backspace ed)]
    [(or (string=? ke "\t") (string=? ke "\r")) ed]
    [(printable-1string? ke) (insert-1 ed ke)]
    [else ed]))

;;
;; Examples & Tests (many)
;;

(define E0 (make-editor "" ""))
(define E1 (make-editor "abc" "XYZ"))
(define E2 (make-editor "" "hello"))
(define E3 (make-editor "world" ""))
(define E4 (make-editor "foo" "bar"))
(define E5 (make-editor "a" ""))
(define E6 (make-editor "" "a"))
(define E7 (make-editor "cat" "nip"))

;; Insert printable characters
(check-expect (edit E0 "a") (make-editor "a" ""))
(check-expect (edit (make-editor "a" "") "b") (make-editor "ab" ""))

;; Insert into middle (pre grows)
(check-expect (edit E1 "!") (make-editor "abc!" "XYZ"))

;; Ignore tab and return
(check-expect (edit E1 "\t") E1)
(check-expect (edit E1 "\r") E1)

;; Backspace in middle
(check-expect (edit E1 "\b") (make-editor "ab" "XYZ"))

;; Backspace at beginning (no-op)
(check-expect (edit E2 "\b") E2)

;; Move left in middle
(check-expect (edit E1 "left") (make-editor "ab" "cXYZ"))

;; Move left again
(check-expect (edit (make-editor "ab" "cXYZ") "left")
              (make-editor "a" "bcXYZ"))

;; Move right from middle
(check-expect (edit (make-editor "a" "bcXYZ") "right")
              (make-editor "ab" "cXYZ"))

;; Move right at end (no-op)
(check-expect (edit E3 "right") E3)

;; Move left at beginning (no-op)
(check-expect (edit (make-editor "" "hello") "left")
              (make-editor "" "hello"))

;; Sequence: left then insert (fixed expectation)
;; E4 = "foo|bar" -> left => "fo|obar" -> insert "?" => "fo?|obar"
(check-expect (edit (edit E4 "left") "?")
              (make-editor "fo?" "obar"))

;; Sequence: insert then right (fixed expectation)
;; "foo|bar" -> insert "!" => "foo!|bar" -> right => "foo!b|ar"
(check-expect (edit (edit E4 "!") "right")
              (make-editor "foo!b" "ar"))

;; Backspace after two left moves from E4
;; "foo|bar" -> left => "fo|obar" -> left => "f|oobar" -> backspace => "|oobar"
(check-expect (edit (edit (edit E4 "left") "left") "\b")
              (make-editor "" "oobar"))

;; Insert at very beginning
(check-expect (edit E2 "H") (make-editor "H" "hello"))

;; Move all the way left by repeated "left" (no let in BSL)
;; "cat|nip" -> "ca|tnip" -> "c|atnip" -> "|catnip"
(check-expect (edit (edit (edit E7 "left") "left") "left")
              (make-editor "" "catnip"))

;; Then move right twice from start
;; "|catnip" -> "c|atnip" -> "ca|tnip"
(check-expect (edit (edit (make-editor "" "catnip") "right") "right")
              (make-editor "ca" "tnip"))

;; Backspace after moving right twice -> "c|tnip"
(check-expect (edit (make-editor "ca" "tnip") "\b")
              (make-editor "c" "tnip"))

;; Unknown multi-letter key -> ignored
(check-expect (edit E1 "up") E1)
(check-expect (edit E1 "down") E1)

;; Unicode single-character insert (if environment supports it)
(check-expect (edit (make-editor "" "") "✓")
              (make-editor "✓" ""))

;; Cursor dance: left and then right is identity
(check-expect (edit (edit E1 "left") "right") E1)

;;;
;;; Exercise 85. Define the function run. Given the pre field of an editor, it launches an interactive
;;; editor, using render and edit from the preceding two exercises for the to-draw and on-key clauses,
;;; respectively. 
;;;

;; Assumes already defined in this file:
;;   (define-struct editor [pre post])
;;   render : Editor -> Image
;;   edit   : Editor KeyEvent -> Editor

;; run : String -> Editor
;; Launch an interactive editor starting with given pre text.
(define (run pre)
  (big-bang (make-editor pre "")
    [to-draw render]
    [on-key  edit]))

;; Example (uncomment to start):
;; (run "hello ")

;;;
;;; Exercise 86. Notice that if you type a lot, your editor program does not display all of the text.
;;; Instead the text is cut off at the right margin. Modify your function edit from exercise 84 so
;;; that it ignores a keystroke if adding it to the end of the pre field would mean the rendered text
;;; is too wide for your canvas. 
;;;
;; insert-1 : Editor 1String -> Editor
;; Add one character only if it fits in the scene width
(define (insert-1-v2 ed ch)
  (if (<= (image-width (beside (text (string-append (editor-pre ed) ch) FONT-SIZE FONT-COLOR)
                               CURSOR
                               (text (editor-post ed) FONT-SIZE FONT-COLOR))) SCENE-WIDTH)
      (make-editor (string-append (editor-pre ed) ch)
                   (editor-post ed)) ed))

(define (edit-v2 ed ke)
  (cond
    [(string=? ke "left")  (move-left ed)]
    [(string=? ke "right") (move-right ed)]
    [(string=? ke "\b")    (backspace ed)]
    [(or (string=? ke "\t") (string=? ke "\r")) ed]
    [(printable-1string? ke) (insert-1-v2 ed ke)]
    [else ed]))

(define (run-v2 pre)
  (big-bang (make-editor pre "")
    [to-draw render]
    [on-key  edit-v2]))

;;;
;;; Exercise 87. Develop a data representation for an editor based on our first idea, using a string
;;; and an index. Then solve the preceding exercises again. Retrace the design recipe.
;;;

;;;
;;; Editor v3 — string + index representation
;;; Uses SCENE-WIDTH, SCENE-HEIGHT, FONT-SIZE, FONT-COLOR, CURSOR, printable-1string?
;;;

(define-struct editor-v3 [text idx])
;; An Editor-v3 is (make-editor-v3 text idx)
;;   text : String
;;   idx  : Natural ; 0 ≤ idx ≤ (string-length text)
;; Interpretation: cursor sits between characters 0..(string-length text)

;; Convenience constructor (for tests / parity with pre/post)
(define (mk-v3 pre post)
  (make-editor-v3 (string-append pre post)
                  (string-length pre)))

;;
;; Helpers
;;
(define (pre-v3 e)
  (substring (editor-v3-text e) 0 (editor-v3-idx e)))

(define (post-v3 e)
  (substring (editor-v3-text e) (editor-v3-idx e)))

(define (move-left-v3 e)
  (if (= (editor-v3-idx e) 0)
      e
      (make-editor-v3 (editor-v3-text e)
                      (sub1 (editor-v3-idx e)))))

(define (move-right-v3 e)
  (if (= (editor-v3-idx e)
         (string-length (editor-v3-text e)))
      e
      (make-editor-v3 (editor-v3-text e)
                      (add1 (editor-v3-idx e)))))

(define (backspace-v3 e)
  (if (= (editor-v3-idx e) 0)
      e
      (make-editor-v3
       (string-append
        (substring (editor-v3-text e) 0 (sub1 (editor-v3-idx e)))
        (substring (editor-v3-text e) (editor-v3-idx e)))
       (sub1 (editor-v3-idx e)))))

(define (insert-1-v3 e ch)
  (make-editor-v3
   (string-append
    (substring (editor-v3-text e) 0 (editor-v3-idx e))
    ch
    (substring (editor-v3-text e) (editor-v3-idx e)))
   (add1 (editor-v3-idx e))))

;;
;; Rendering
;;
(define (to-line-v3 e)
  (beside (text (pre-v3 e)  FONT-SIZE FONT-COLOR)
          CURSOR
          (text (post-v3 e) FONT-SIZE FONT-COLOR)))

(define (render-v3 e)
  (overlay/align "left" "center"
                 (to-line-v3 e)
                 (empty-scene SCENE-WIDTH SCENE-HEIGHT)))

;;
;; Editing
;;
(define (edit-v3 e ke)
  (cond
    [(string=? ke "left")  (move-left-v3 e)]
    [(string=? ke "right") (move-right-v3 e)]
    [(string=? ke "\b")    (backspace-v3 e)]
    [(or (string=? ke "\t") (string=? ke "\r")) e]
    [(printable-1string? ke) (insert-1-v3 e ke)]
    [else e]))

(define (run-v3 pre)
  (big-bang (make-editor-v3 pre (string-length pre))
    [to-draw render-v3]
    [on-key  edit-v3]))

;;
;; Width-limiting
;;
(define (insert-1-fit-v3 e ch)
  (if (<= (image-width (to-line-v3 (insert-1-v3 e ch))) SCENE-WIDTH)
      (insert-1-v3 e ch)
      e))

(define (edit-fit-v3 e ke)
  (cond
    [(string=? ke "left")  (move-left-v3 e)]
    [(string=? ke "right") (move-right-v3 e)]
    [(string=? ke "\b")    (backspace-v3 e)]
    [(or (string=? ke "\t") (string=? ke "\r")) e]
    [(printable-1string? ke) (insert-1-fit-v3 e ke)]
    [else e]))

(define (run-fit-v3 pre)
  (big-bang (make-editor-v3 pre (string-length pre))
    [to-draw render-v3]
    [on-key  edit-fit-v3]))

;;
;; Testing
;;
(define E0-v3 (mk-v3 "" ""))
(define E1-v3 (mk-v3 "abc" "XYZ"))
(define E2-v3 (mk-v3 "" "hello"))
(define E3-v3 (mk-v3 "world" ""))
(define E4-v3 (mk-v3 "foo" "bar"))

;; Insert printable characters
(check-expect (edit-v3 E0-v3 "a") (mk-v3 "a" ""))

;; Ignore tab and return
(check-expect (edit-v3 E1-v3 "\t") E1-v3)
(check-expect (edit-v3 E1-v3 "\r") E1-v3)

;; Backspace in middle
(check-expect (edit-v3 E1-v3 "\b") (mk-v3 "ab" "XYZ"))

;; Backspace at beginning (no-op)
(check-expect (edit-v3 E2-v3 "\b") E2-v3)

;; Move left in middle
(check-expect (edit-v3 E1-v3 "left") (mk-v3 "ab" "cXYZ"))

;; Move right at end (no-op)
(check-expect (edit-v3 E3-v3 "right") E3-v3)

;; Sequence: left then insert => "fo?|obar"
(check-expect (edit-v3 (edit-v3 E4-v3 "left") "?")
              (mk-v3 "fo?" "obar"))

;; Make sure width-limited insert never exceeds SCENE-WIDTH
(define near-full-v3 (make-string 24 #\x))
(define Ewide-v3 (mk-v3 near-full-v3 ""))
(check-expect
  (<= (image-width (to-line-v3 (edit-fit-v3 Ewide-v3 "y"))) SCENE-WIDTH)
  #true)


