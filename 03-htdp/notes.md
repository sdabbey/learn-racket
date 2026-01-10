# How to Design Programs
A good program comes with a short write-up that explains what it does, what inputs it expects, and what it produces. 
Ideally, it also comes with some assurance that it actually works. 
In the best circumstances, the program's connection to the problem statement is evident so that a small change to the problem statement is easy to translate into a small change to the program. This is called **"programming product"**

## Designing Functions
- We begin with a connection between *information* and *data* - This is more like choosing a representation and interpretation of data, which we call **data definitions**

- We then write down a *signature*, a *statement of purpose* and a *function header*. 
A *function signature* is a comment that tells the readers of your design how man inputs your function consumes, from which classes they drawn, and what kind of data it produces.
Example: *;String -> Number* -> Consume one String and produce a Number.

A *purpose statement* is a BSL comment that summarises the purpose of the function in a single line.

A *header* is a simplistic function definition, also called a *stub*.

A complete Signature, Purpose and Header.
```
; Number String Image -> Image
; adds s to img,
; y pixels from the top and 10 from the left
(define (add-image y s img)
    (empty-scene 100 100))
```

- Illustrate the signature and purpose statement with some functional examples. This include determining what you expect back
Example:
```
; given: 2, expect: 4
; given: 7, expect: 49
```

- We then take *inventory* to understand what are given and what we need to compute. We replace function body with a *template*.
Example:
```
(define (area-of-square len)
    (...len...))
```

- The general code is now determined here. We replace the body of the function from the template with expression that attempts to accomplish what the purpose statement promises.
Example:
```
(define (area-of-square len)
    (sqr len))
```

- The last step is to test the function on the examples listed previously.