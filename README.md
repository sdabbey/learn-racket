# Learn Racket

This repository archives my structured study of the Racket programming language
as used in **CS 2139: Introduction to Computer Science 1 — Programming and
Computer Science** (Fall 2025).

The goal of this course is not just to learn syntax, but to **think like a
computer scientist**, using Racket to explore program design, abstraction, data
representation, and the foundations of computational problem solving. :contentReference[oaicite:2]{index=2}

## Course Focus

This repository corresponds to the major themes of the class:

- **Program Design:** Using a structured design recipe to solve problems
- **Basic Expressions:** Arithmetic, intervals, and evaluation
- **Functions:** Definitions, composition, and abstraction
- **Data Structures:** Lists, pairs, and simple compound data
- **Abstraction & Scope:** How functions and environments interact

## Organization

- `01-program-design/`: Notes, design recipes, and early examples  
- `02-basic-expressions/`: Racket code for expressions and intervals  
- `03-functions/`: Functions and composition practice  
- `04-data-structures/`: Introduction to lists and data manipulation  
- `05-abstraction-and-scope/`: Abstraction principles and scoping  
- `exercises/`: Practice problems and homework-style files
- `capstone-project/`: An implementation of **Spacewar**
- `references/`: Resource bookmarks and summaries (e.g., HtDP)

## Tools

- This work uses **DrRacket** as the development environment  
- All Racket files use `#lang racket` and follow course style guidelines

## Capstone Project

The culmination of this course is a full interactive program built using the
design methodology from *How to Design Programs*.

- **Capstone:** [`capstone-project/`](./capstone-project)
  - A complete implementation of **Spacewar!** in Racket
  - Built using `#lang htdp/bsl` and `big-bang`
  - Demonstrates world state modeling, event-driven design,
    functional updates, and incremental program development

## Status

Ended for Fall 2025 CS 2139

