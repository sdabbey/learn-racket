## Functions
While many programming languages obscure the relationship between programs and functions, BSL brings it to the fore. Every BSL program consists of several definitions, usually followed by an expression that involves those definitions. There are two kinds of *definitions*:
- **constant definitions**, with syntax *(define Variable Expression)*
- **function definitions**, which come in many flavors. Like expressions, function definitions in BSL come in a uniform shape:
*(define (FunctionName Variable ... Variable)*
        *Expression)*

To define a function, we write down
- *(define (*
- the name of the function,
- followed by several variables, separated by space and ending in *")"*,
- and an expression followed by *")"*

Examples:
```
(define (f x) 1)
(define (g x y) (+ 1 1))
(define (h x y z) (+ (* 2 2) 3))

_> Remember that x y and z are placeholders.
```

