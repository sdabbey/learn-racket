# Capstone Project — Spacewar!

This folder contains the final capstone project for
**Introduction to Computer Science 1 (Fall 2025)**.

The project is an implementation of **Spacewar!** written in Racket,
using the **Beginning Student Language (BSL)** and the
**design methodology from *How to Design Programs (2e)***.

The goal of this project was not game polish, but to demonstrate
systematic program design, state modeling, and interactive systems
development.

---

## Overview

Spacewar! is a two-player game in which each player controls a ship
with rotation, thrust, wraparound movement, collision detection,
and laser firing.

The system is implemented as a **world program** using `big-bang`,
with clearly separated concerns for:

- world state
- rendering
- event handling
- state updates

---

## Technical Highlights

This project demonstrates:

- **Data Definitions**
  - `Ship` structures modeling position, rotation, velocity, and cooldown
  - `SW` (Spacewar World) containing two ships

- **Pure Functional Updates**
  - Movement with screen wraparound
  - Rotation and thrust via vector math
  - Cooldown-based laser firing

- **Event-Driven Design**
  - Keyboard input (`on-key`, `on-release`)
  - Time-based updates (`on-tick`)
  - Termination conditions (`stop-when`)

- **Incremental Development**
  - Multiple versions (`v3` → `v9`) showing staged feature growth:
    - movement
    - rotation
    - thrust
    - collision detection
    - lasers
    - laser hits and win conditions

---

## Files

- `spacewar.rkt` — Final integrated implementation
- `worksheets/` — Intermediate worksheet versions used during development

---

## Tools & Language

- Racket / DrRacket
- `#lang htdp/bsl`
- `2htdp/universe`, `2htdp/image`

---

## Status

Completed as part of coursework. Archived for study and reference.
