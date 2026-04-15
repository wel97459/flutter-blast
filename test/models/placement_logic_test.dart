import 'package:flutter_test/flutter_test.dart';
import 'package:blockblast_flutter/models/block.dart';
import 'package:blockblast_flutter/models/piece.dart';
import 'package:blockblast_flutter/models/game_logic.dart';

void main() {
  group('Placement Logic', () {
    late List<List<Block>> emptyGrid;

    setUp(() {
      emptyGrid = List.generate(
        8,
        (_) => List.generate(8, (_) => Block.empty()),
      );
    });

    test('should return true for valid placement on empty grid', () {
      final piece = Piece(shape: [(0, 0), (0, 1)], color: 0xFF0000FF);
      expect(isValidPlacement(emptyGrid, piece, 0, 0), isTrue);
      expect(isValidPlacement(emptyGrid, piece, 7, 6), isTrue);
    });

    test('should return false for out of bounds placement', () {
      final piece = Piece(shape: [(0, 0), (0, 1)], color: 0xFF0000FF);
      expect(
        isValidPlacement(emptyGrid, piece, 0, 7),
        isFalse,
      ); // One block out of bounds (col 8)
      expect(
        isValidPlacement(emptyGrid, piece, 8, 0),
        isFalse,
      ); // Out of bounds row
      expect(isValidPlacement(emptyGrid, piece, -1, 0), isFalse);
    });

    test('should return false for overlapping blocks', () {
      final grid = List.generate(
        8,
        (_) => List.generate(8, (_) => Block.empty()),
      );
      grid[1][1] = const Block(color: 0xFF00FF00); // Already occupied

      final piece = Piece(shape: [(0, 0), (0, 1), (1, 1)], color: 0xFF0000FF);
      // piece at (0,0) covers (0,0), (0,1), (1,1). (1,1) is occupied.
      expect(isValidPlacement(grid, piece, 0, 0), isFalse);
      // piece at (1,1) covers (1,1), (1,2), (2,2). (1,1) is occupied.
      expect(isValidPlacement(grid, piece, 1, 1), isFalse);
      // piece at (0,1) covers (0,1), (0,2), (1,2). No overlap.
      expect(isValidPlacement(grid, piece, 0, 1), isTrue);
    });

    test('placePiece should update the grid with piece blocks', () {
      final grid = List.generate(
        8,
        (_) => List.generate(8, (_) => Block.empty()),
      );
      final piece = Piece(shape: [(0, 0), (0, 1)], color: 0xFF0000FF);

      placePiece(grid, piece, 2, 3);

      expect(grid[2][3].isFilled, isTrue);
      expect(grid[2][3].color, 0xFF0000FF);
      expect(grid[2][4].isFilled, isTrue);
      expect(grid[2][4].color, 0xFF0000FF);
      expect(grid[0][0].isFilled, isFalse);
    });

    group('Line Clearing', () {
      test('should clear a full row', () {
        final grid = List.generate(
          8,
          (_) => List.generate(8, (_) => Block.empty()),
        );
        for (int c = 0; c < 8; c++) {
          grid[3][c] = const Block(color: 0xFF00FF00);
        }

        final linesCleared = checkAndClearLines(grid);

        expect(linesCleared, 1);
        for (int c = 0; c < 8; c++) {
          expect(grid[3][c].isFilled, isFalse);
        }
      });

      test('should clear a full column', () {
        final grid = List.generate(
          8,
          (_) => List.generate(8, (_) => Block.empty()),
        );
        for (int r = 0; r < 8; r++) {
          grid[r][5] = const Block(color: 0xFF00FF00);
        }

        final linesCleared = checkAndClearLines(grid);

        expect(linesCleared, 1);
        for (int r = 0; r < 8; r++) {
          expect(grid[r][5].isFilled, isFalse);
        }
      });

      test('should clear both a row and a column simultaneously', () {
        final grid = List.generate(
          8,
          (_) => List.generate(8, (_) => Block.empty()),
        );
        for (int i = 0; i < 8; i++) {
          grid[2][i] = const Block(color: 0xFF00FF00); // Row 2
          grid[i][2] = const Block(color: 0xFF00FF00); // Column 2
        }

        final linesCleared = checkAndClearLines(grid);

        expect(linesCleared, 2);
        for (int i = 0; i < 8; i++) {
          expect(grid[2][i].isFilled, isFalse);
          expect(grid[i][2].isFilled, isFalse);
        }
      });
    });

    group('Score Calculation', () {
      test('should calculate score for piece placement', () {
        final piece = Piece(shape: [(0, 0), (0, 1), (1, 1)], color: 0xFF0000FF);
        expect(calculateScore(piece, 0, 0), 3); // 3 blocks * 10
      });

      test('should calculate score for piece placement and line clears', () {
        final piece = Piece(shape: [(0, 0), (0, 1)], color: 0xFF0000FF);
        expect(calculateScore(piece, 1, 0), 24); // 2 blocks * 1 + 1 line * 100
        expect(
          calculateScore(piece, 2, 0),
          202,
        ); // 2 blocks * 1 + 2 lines * 100
      });
    });

    group('Game Over Condition', () {
      test('should NOT be game over if at least one piece can be placed', () {
        final grid = List.generate(
          8,
          (_) => List.generate(8, (_) => Block.empty()),
        );
        // Occupy most of the grid
        for (int r = 0; r < 8; r++) {
          for (int c = 0; c < 7; c++) {
            grid[r][c] = const Block(color: 0xFF00FF00);
          }
        }
        // Column 7 is empty.

        final piece1 = Piece(
          shape: [(0, 0), (0, 1), (0, 2)],
          color: 0xFF0000FF,
        ); // 1x3 horizontal
        final piece2 = Piece(
          shape: [(0, 0), (1, 0)],
          color: 0xFF0000FF,
        ); // 2x1 vertical

        // piece1 cannot be placed (needs 3 columns)
        // piece2 CAN be placed in column 7

        expect(isGameOver(grid, [piece1, piece2]), isFalse);
      });

      test('should be game over if no pieces can be placed', () {
        final grid = List.generate(
          8,
          (_) => List.generate(8, (_) => const Block(color: 0xFF00FF00)),
        );
        // Grid is full

        final piece = Piece(shape: [(0, 0)], color: 0xFF0000FF);
        expect(isGameOver(grid, [piece]), isTrue);
      });

      test(
        'should be game over if pieces are too large for remaining gaps',
        () {
          final grid = List.generate(
            8,
            (_) => List.generate(8, (_) => const Block(color: 0xFF00FF00)),
          );
          grid[0][0] = Block.empty();
          grid[7][7] = Block.empty();
          // Only two isolated empty cells.

          final piece = Piece(
            shape: [(0, 0), (0, 1)],
            color: 0xFF0000FF,
          ); // 1x2 piece
          expect(isGameOver(grid, [piece]), isTrue);
        },
      );
    });
  });
}
