# Design Recipe
The Design recipe represents a **6-part** recipe for designing programs especially one involving functions. It was made by drawing inspiration from **Michael Jackson’s** method for creating **COBOL** programs plus conversations with Daniel **Friedman** on recursion, Robert Harper on type theory, and Daniel Jackson on software design.

## 1. From Problem Analysis to Data Definitions

- For this part, we identify the information that must be represented and how it is represented in the chosen programming language. We then formulate data definitions and illustrate them with examples.

## 2. Signature, Purpose Statement, Header

- For this 3-part section, we state what kind of data the desired function consumes and produces. Formulate a concise answer to the question what the function computes. Define a stub that lives up to the signature.

## 3. Functional Examples

- We provide examples with expected results to illustrate the function’s purpose.

## 4. Function Template

- We translate the data definitions into an outline of the function.

## 5. Function Definition

- Fill in the gaps in the function template. Exploit the purpose statement and the examples.

## 6. Testing

- Articulate the examples as tests and ensure that the function passes all. Doing so discovers mistakes. Tests also supplement examples in that they help others read and understand the definition when the need arises—and it will arise for any serious program.