# flutter_blast

A Flutter clone of the popular **Block Blast** puzzle game.

## Gameplay

* Drag the three block shapes from the bottom tray onto the 8 × 8 grid.
* When an entire row **or** column is filled it is cleared and you earn bonus points.
* The game ends when none of the three current pieces can be placed anywhere on the board.
* Try to beat your high score!

## Running the app

```bash
# Get dependencies
flutter pub get

# Run on a connected device / emulator
flutter run

# Analyze
flutter analyze

# Test
flutter test
```

## Project structure

```
lib/
  main.dart                    App entry-point
  models/
    block_shape.dart           BlockShape data class + piece templates
    game_state.dart            Game logic (ChangeNotifier)
  screens/
    game_screen.dart           Main game screen
  widgets/
    board_widget.dart          8×8 board with drag-target support
    piece_display.dart         Renders a single piece
    pieces_panel.dart          Bottom panel with 3 draggable pieces
    score_panel.dart           Score & high-score display
test/
  widget_test.dart             Unit tests for models + widget smoke tests
```

## Requirements

* Flutter ≥ 3.27 (Dart ≥ 3.6)
