# Flutter Blast

Flutter Blast is a Flutter implementation of a Block Blast-style puzzle game.
You drag pieces from a shelf onto an 8x8 board, fill rows/columns to clear
them, and survive as long as at least one shelf piece can still be placed.

## What this project includes

- 8x8 game board with drag-and-drop placement
- Randomly generated piece shelf (3 pieces at a time)
- Placement validation (bounds + overlap checks)
- Row/column clearing logic
- Score tracking with combo bonus behavior
- Game-over detection with restart dialog
- Widget and model tests under `test/`

## Tech stack

- Flutter (Material 3)
- Dart 3
- No external gameplay packages; game logic is implemented in `lib/models/`

## Project structure

```text
lib/
	main.dart                 # app bootstrap, game state, score/combo lifecycle
	models/
		block.dart              # block model
		piece.dart              # piece shapes, rotations, random generation
		game_logic.dart         # placement, line clear, scoring, game-over checks
	widgets/
		game_board_grid.dart    # board rendering + drag target + ghost/line preview
		piece_shelf.dart        # draggable pieces UI
		block_widget.dart       # single block renderer

test/
	models/                   # unit tests for game rules
	widgets/                  # widget tests for board/shelf/interaction

conductor/
	...                       # product and workflow docs used for planning
```

## Prerequisites

- Flutter SDK installed and on `PATH`
- A configured device/emulator/simulator (or desktop target)

Quick check:

```bash
flutter --version
flutter doctor
```

## Getting started

1. Install dependencies:

	 ```bash
	 flutter pub get
	 ```

2. Run the app:

	 ```bash
	 flutter run
	 ```

### Run on a specific platform

Examples:

```bash
flutter run -d linux
flutter run -d chrome
flutter run -d android
flutter run -d ios
```

List available devices:

```bash
flutter devices
```

## How to play

1. Drag one of the 3 pieces from the bottom shelf.
2. Drop it onto a valid board position.
3. Complete full rows/columns to clear them.
4. Use clears to keep space open and avoid game over.

The game ends when none of the current shelf pieces can be legally placed.

## Scoring

Current score behavior in code:

- Base points per move = number of blocks in the placed piece
- Line clear bonus = `22 × linesCleared` for that move
- Combo bonus = `24 × comboCount`

Where `comboCount` is tracked across moves and updated when line clears happen.

## Development commands

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Run a specific test file:

```bash
flutter test test/widgets/game_board_grid_test.dart
```

## Notes

- The board starts with a lightly seeded random fill for variation.
- Piece rotations are generated automatically from base shapes.
- Desktop/mobile/web folders are present from Flutter multi-platform project
	scaffolding.

## Roadmap ideas

- High score persistence
- Sound and haptics
- Difficulty profiles
- Animated clear effects and richer theming

