## The Arithmetic of Strings
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

- **Substring** extracts the text using range-like format with a starting point and end for a given string. It has the syntax:
*(substring s i j) -> string*
    *s : string*
    *i : natural?*
    *j : natural?*
    Example:
```
    > (substring "hello world" 1 5)
    "ello
```

- **string-ith** consumes a string s together with a number i and extracts the 1String located at the ith position(counting from 0)
Syntax:
    *(string-ith s i)*
    *s : string*
    *i : natural?*
Example:
```
    > (string-ith "hello" 1)
    "e"
```


## The Arithmetic of Numbers
- Here are some of the operations on numbers that racket provides:  **+**, **-**, *, **/**, **abs**, **add1**, **ceiling**, **denominator**, **exact->inexact**, **expt**, **floor**, **gcd**, **log**, **max**, **numerator**, **quotient**, **random**, **remainder**, **sqr**, and **tan**

- BSL also recognises the names of some widely used numbers. For example, **pi** and **e**


## The Arithmetic of Images
- Programs in DrRacket can manipulate images with primitive operations. The basic operations for creating images include *circle*, *ellipse*, *line*, *rectangle*, *text*, *triangle*.

- These images now come with properties like;
*image-width* which determines the width of an image in term of pixels
*image-height* which determines the height of an image.
Example:
```
> (image-width (circle 10 "solid" "red"))
  20

> (image-height (rectangle 10 20 "solid" "blue"))
  20

> (+ (image-width (circle 10 "solid" "red"))
     (image-height (rectangle 10 20 "solid" "blue")))
  40
```

- We also got primitive functions like *overlay* - which places all the images to whit it is applied on top of each other, using the center as anchor point. 

- *overlay/xy* is like *overlay* but accepts two numbers x and y between two image arguments. It shifts the second image by x pixels to the right and y pixels down - all with respect to the first image's top-left corner.

- *overlay/align* is like *overlay* but accepts two strings that shift the anchor point(s) to other parts of the rectangels.


## The Arithmetic of Booleans
There are two kinds of Boolean values: *#true* and *#false*.
BSL programs have three operations: **or**, **and**, and **not**
```
For "or":
> (or #true #true)
  #true

> (or #true #false)
  #true

> (or #false #false)
  #false

For "and":
> (and #true #true)
  #true

> (and #true #false)
  #false

> (and #false #false)
  #false
  
For "not":
> (not #true)
  #false

> (not #false)
  #true
```

## Predicates: Know Thy Data
A *predicate* is a function that consumes a value and determines whether or not it belongs to some class of data. For example, the predicate *number?* determines the given value is a number or not:
```
> (number? 4)
 #true

> (number? pi)
 #true

> (number? #true)
 #false

> (number? "fortytwo")
 #false
```

In addition to the predicates above, there are some that distinguish different kinds of numbers. BSL classifies numbers in two ways: *by construction* and *by exactness*.
**Construction** refers to the familiar sets of numbers: *integer?*, *rational?*, *real?* and *complex?*, but many programming languages, including BSL also choose to use finite approximations to well-known constants, which leads to somewhat surprising results with the *rational?* predicate:
```
> (rational? pi)
  #true
```