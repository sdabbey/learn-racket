
#lang htdp/bsl

#|
Worksheet 10 Answers (from class)
Input Errors
Check World States
Defining Equality Predicates
|#

;; Input Errors

(define (mirror-string s)
  (string-append s (list->string (reverse (string->list s)))))

(mirror-string "cat") ;; => "cattac"
(mirror-string 5)

(string? "cat") ; #t
(string? 5) ; #f

(define (checked-mirror-string s)
  (cond
    [(string? s) (string-append s (list->string (reverse (string->list s))))]
    [(number? s) (string-append (number->string s) (list->string (reverse (string->list (number->string s)))))]
    [else (error "Error: checked-mirror-string: String or Number expceted")]))

(checked-mirror-string "cat")
(checked-mirror-string 5)
(checked-mirror-string #t)

(define-struct robot [x dir happy])
(robot? (make-robot "hello" "hello" "hello"))

(define (is-robot r)
  (if
    (and (robot? r)
         (number? (robot-x r))
         (string? (robot-dir r))
         (or (string=? (robot-dir r) "left")
             (string=? (robot-dir r) "right"))
         (number? (robot-happy r))
         (<= 0 (robot-happy r) 100)) #t
    (error "Why are you doing this to me?  I worked long and hard on this and you gave me gargbage.")))

(is-robot (make-robot 1 2 3))
(is-robot (make-robot 1 "left" 3))

