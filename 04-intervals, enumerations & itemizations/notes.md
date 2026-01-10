# Intervals, Enumerations and Itemizations
Good programmers must learn to design programs with restrictions on these 4 built-in collections for representing information as data: *numbers*, *strings*, *images* and *boolean values*.

### Programming With Conditionals
A **cond** is the most complicated conditional expression form in BSL.
Syntax:
```
(cond
    [ConditionExpression1 ResultExpression1]
    [ConditionExpression2 ResultExpression2]
    ...
    [ConditionExpressionN ResultExpressionN])
```
A *cond* line is also known as a *cond clause*. A programmer can write as many *cond* lines as needed.
Example of full function definition utilising conditional expression:
```
(define (next traffic-light-state)
    (cond
        [(string=? "red" traffic-light-state) "green"]
        [(string=? "green" traffic-light-state) "yellow"]
        [(string=? "yellow" traffic-light-state) "red"]))
```
When the conditions get too complex in a *cond* expression, we occasionally wish to say something like "in all other cases". For these kind of problem, *cond* expressions permit the use of the *else* keyword for the very last *cond* line:
```
(cond
    [ConditionExpression1 ResultExpression1]
    [ConditionExpression2 ResultExpression2]
    ...
    [else DefaultResultExpression])
```
If *else* is used mistakenly in some other *cond* line, BSL signals an error:
```
> (cond
    [(> x 0) 10]
    [else 20]
    [(< x 10) 30])
cond: found an else clause that isn't the last clause in its cond expression
```

## Enumerations
**Enumeration** is a data representation in which every possibility is listed. A simple example is a TrafficLight sequence.
```
; A TrafficLight is one of the following Strings:
    - "red"
    - "green"
    - "yellow"
; interpretation: The three strings represent the three possible states that a traffic light may assume.
```
Programming with enumerations is mostly straightforward. The main idea of an *enumeration* is that it defines a collection of data as a **finite** number of pieces of data.

## Intervals
An **interval** is a description of a class of numbers via boundaries. The simplest interval has two boundaries: left and right.
- *closed* interval -> The left and right boundary is to be included in the interval. [3, 5]
- *left-open* interval -> The left boundary is not to be included in the interval. (3, 5]
- *right-open* interval -> The right boundary is not to be included in the interval. [3, 5)
- *open* interval -> The boundaries are not to be included. (3, 5)
Example:
```
(define (f y)
    (cond
    [(<= 0 y CLOSE) ...]
    [(<= CLOSE y HEIGHT) ...]
    [(>= y HEIGHT) ...]))
```

