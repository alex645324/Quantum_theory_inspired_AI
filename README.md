# Quantum Tic-Tac-Toe Bot

A playful, experimental Tic-Tac-Toe opponent built in Dart/Flutter that uses **quantum-inspired superposition reasoning** to pick its next move — feels less predictable and more exploratory than a fixed minimax bot.

## Problem

Standard Tic-Tac-Toe is solved and predictable. Simple AIs either win, draw, or lose in obvious ways, so playing against them gets stale. There’s no sense of “thinking over multiple possibilities at once” in a way that feels dynamic.

## What It Does

- Represents possible next-board states in a loose “superposition” of candidate moves.
- Evaluates those possibilities simultaneously with weighted heuristics (win potential, block urgency, fork creation).
- Collapses the superposition into a concrete next move based on those weights — giving the impression of a bot that considers many futures before choosing.
- Plays against a human through a Flutter UI, showing a standard Tic-Tac-Toe board.
- Built entirely in Dart/Flutter; there’s no real quantum hardware involved — it’s **quantum-inspired**, not quantum-computing.

## How to Use

### Requirements
- Flutter SDK installed
- Dart runtime (comes with Flutter)
- Device or emulator (iOS, Android, or web target)

### Run
```bash
flutter pub get
flutter run
