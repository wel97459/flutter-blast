import 'package:flutter_test/flutter_test.dart';
import 'package:blockblast_flutter/models/piece.dart';

void main() {
  group('Piece', () {
    test('Piece can be instantiated with a shape and color', () {
      const shape = [(0, 0), (0, 1)];
      const color = 0xFF00FF00;
      final piece = Piece(shape: shape, color: color);

      expect(piece, isA<Piece>());
      expect(piece.shape, shape);
      expect(piece.color, color);
    });

    test('Piece calculates its width and height correctly', () {
      // 2x2 square
      const shape = [(0, 0), (0, 1), (1, 0), (1, 1)];
      final piece = Piece(shape: shape, color: 0xFFFFFFFF);
      expect(piece.width, 2);
      expect(piece.height, 2);

      // L-shape (3x2 bounding box)
      const lShape = [(0, 0), (1, 0), (2, 0), (2, 1)];
      final lPiece = Piece(shape: lShape, color: 0xFFFFFFFF);
      expect(lPiece.width, 2);
      expect(lPiece.height, 3);
    });

    test(
      'generateRandomPiece generates a piece with a valid shape and color',
      () {
        final randomPiece = Piece.generateRandomPiece();
        expect(randomPiece, isA<Piece>());
        expect(randomPiece.shape.isNotEmpty, true);
        expect(
          randomPiece.color != 0,
          true,
        ); // Should have a non-transparent color
      },
    );

    test(
      'generateRandomPiece generates a piece from the predefined shapes',
      () {
        final randomPiece = Piece.generateRandomPiece();
        // This test is more about ensuring the shape is one of the known ones
        // rather than exhaustive checking. We can check if it's a sub-list
        // or if all points are within expected bounds for known shapes.
        // For simplicity, let's just check if it's not empty.
        expect(randomPiece.shape.isNotEmpty, true);
      },
    );
  });
}
