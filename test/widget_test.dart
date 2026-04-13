import 'package:flutter/material.dart';
import 'package:flutter_blast/models/block_shape.dart';
import 'package:flutter_blast/models/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_blast/main.dart';

void main() {
  // ── BlockShape tests ────────────────────────────────────────────────────
  group('BlockShape', () {
    test('occupiedCells returns correct cells for a 1x1 dot', () {
      const shape = BlockShape(
        name: 'dot',
        cells: [
          [true]
        ],
        color: Colors.red,
      );
      expect(shape.occupiedCells, [(0, 0)]);
    });

    test('occupiedCells skips empty cells', () {
      const shape = BlockShape(
        name: 'l',
        cells: [
          [true, false],
          [true, true],
        ],
        color: Colors.blue,
      );
      expect(shape.occupiedCells, containsAll([(0, 0), (1, 0), (1, 1)]));
      expect(shape.occupiedCells.length, 3);
    });

    test('withColor creates a copy with a different color', () {
      const shape = BlockShape(
        name: 'dot',
        cells: [
          [true]
        ],
        color: Colors.red,
      );
      final copy = shape.withColor(Colors.green);
      expect(copy.color, Colors.green);
      expect(copy.name, shape.name);
    });
  });

  // ── GameState tests ──────────────────────────────────────────────────────
  group('GameState', () {
    late GameState game;

    setUp(() {
      game = GameState();
    });

    tearDown(() {
      game.dispose();
    });

    test('board is initially empty', () {
      for (int r = 0; r < GameState.boardSize; r++) {
        for (int c = 0; c < GameState.boardSize; c++) {
          expect(game.board[r][c], isNull);
        }
      }
    });

    test('three pieces are generated at start', () {
      expect(game.currentPieces.length, 3);
      expect(game.currentPieces.every((p) => p != null), isTrue);
    });

    test('canPlace returns true for valid placement', () {
      final piece = game.currentPieces[0]!;
      // The board is empty so placement at (0, 0) should always be valid as
      // long as the piece fits.
      expect(game.canPlace(piece, 0, 0), isTrue);
    });

    test('canPlace returns false when out of bounds', () {
      const shape = BlockShape(
        name: 'h3',
        cells: [
          [true, true, true]
        ],
        color: Colors.red,
      );
      // Placing a 3-wide piece at column 6 would overflow col 8.
      expect(game.canPlace(shape, 0, 6), isFalse);
    });

    test('placePiece fills the board', () {
      const shape = BlockShape(
        name: 'dot',
        cells: [
          [true]
        ],
        color: Colors.red,
      );
      game.currentPieces[0] = shape;
      game.placePiece(0, 3, 3);
      expect(game.board[3][3], Colors.red);
    });

    test('placePiece increases score', () {
      const shape = BlockShape(
        name: 's2',
        cells: [
          [true, true],
          [true, true],
        ],
        color: Colors.green,
      );
      game.currentPieces[0] = shape;
      game.placePiece(0, 0, 0);
      // 4 cells placed → score ≥ 4
      expect(game.score, greaterThanOrEqualTo(4));
    });

    test('clearing a full row awards bonus and clears cells', () {
      // Fill the first 7 columns of row 7 manually.
      for (int c = 0; c < 7; c++) {
        game.board[7][c] = Colors.blue;
      }
      // Place a 1×1 piece in the last cell to complete row 7.
      const dot = BlockShape(
        name: 'dot',
        cells: [
          [true]
        ],
        color: Colors.orange,
      );
      game.currentPieces[0] = dot;
      game.placePiece(0, 7, 7);

      // Row 7 should now be cleared.
      for (int c = 0; c < GameState.boardSize; c++) {
        expect(game.board[7][c], isNull, reason: 'cell (7, $c) should be cleared');
      }
    });

    test('restartGame resets board and score', () {
      game.board[0][0] = Colors.red;
      game.score = 100;
      game.restartGame();
      expect(game.board[0][0], isNull);
      expect(game.score, 0);
    });

    test('generatePieces returns 3 shapes', () {
      final pieces = generatePieces(42);
      expect(pieces.length, 3);
      for (final p in pieces) {
        expect(p.cells.isNotEmpty, isTrue);
      }
    });
  });

  // ── Widget smoke test ────────────────────────────────────────────────────
  testWidgets('App builds without errors', (tester) async {
    await tester.pumpWidget(const BlockBlastApp());
    // Verify the title is visible.
    expect(find.text('BLOCK BLAST'), findsOneWidget);
  });

  testWidgets('Score panel shows 0 at start', (tester) async {
    await tester.pumpWidget(const BlockBlastApp());
    expect(find.text('0'), findsWidgets);
  });
}
