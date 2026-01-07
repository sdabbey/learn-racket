# Arithmetic
When DrRacket evaluates a string, it just echoes it back in the interactions area, like a number.
- DrRacket knows about an arithmetic of strings.
- Just like **+**, **string-append** is an operation; it makes a string by adding the second to the end of the first.
Example:
```bash
> (string-append "hello" "world")
    "helloworld
```

- **string-length** is primitive that consume strings and produce numbers representing the number of the characters in the string
Example: 
```bash
> (string-length "hello world")
    11
```

- We got **string->number**, another primitive operation for converting strings into numbers.
Example:
```bash
> (string->number "223")
    223
```

- Here are some of the operations on numbers that racket provides:  **+**, **-**, *, **/**, **abs**, **add1**, **ceiling**, **denominator**, **exact->inexact**, **expt**, **floor**, **gcd**, **log**, **max**, **numerator**, **quotient**, **random**, **remainder**, **sqr**, and **tan**

- BSL also recognises the names of some widely used numbers. For example, **pi** and **e**