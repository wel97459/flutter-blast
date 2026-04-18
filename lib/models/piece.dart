import 'dart:math';
import 'package:flutter/material.dart'; // For Color

// Base piece definitions (list of (row, col) tuples relative to the
// bounding-box top-left). All unique rotations are generated automatically so
// every piece can appear in any missing orientation without duplicates.
final List<List<(int, int)>> _basePieceShapes = [
  [
    (0, 0),(0, 1),(0, 2),
    (1, 0),(1, 1),(1, 2),
    (2, 0),(2, 1),(2, 2)
  ], // 3x3 square
  [
    (0, 0),(1, 0),(2, 0),
    (0, 1),(1, 1),(2, 1)
   ], //2x3
  [(0, 0), (0, 1), (1, 0), (1, 1)], // 2x2 square
  [(0, 0)], // 1x1
  [(0, 0), (0, 1)], // 2-block line
  [(0, 0), (0, 1), (0, 2)], // 3-block line
  [(0, 0), (0, 1), (0, 2), (0, 3)], // 4-block line
  [(0, 0), (0, 1), (0, 2), (0, 3), (0, 4)], // 5-block line
  [(0, 0), (1, 0), (2, 0), (2, 1), (2, 2)], // 5-block L
  [(0, 0), (0, 1), (1, 1), (2, 1)], // 4-block L
  [(0, 0), (0, 1), (0, 2), (1, 1)], // T shape
  [(0, 0), (1, 0), (1, 1)], // 3-block L
  [(0,0),(1,1)],
  [(0,0),(1,1),(2,2)],
];

final List<List<(int, int)>> _pieceShapes = _buildPieceShapes();

List<List<(int, int)>> _buildPieceShapes() {
  final shapes = <List<(int, int)>>[];
  final seen = <String>{};

  for (final baseShape in _basePieceShapes) {
    for (final rotatedShape in _generateUniqueRotations(baseShape)) {
      final key = _shapeKey(rotatedShape);
      if (seen.add(key)) {
        shapes.add(rotatedShape);
      }
    }
  }

  return shapes;
}

List<List<(int, int)>> _generateUniqueRotations(List<(int, int)> shape) {
  final rotations = <List<(int, int)>>[];
  final seen = <String>{};
  var current = _normalizeShape(shape);

  for (int i = 0; i < 4; i++) {
    final key = _shapeKey(current);
    if (seen.add(key)) {
      rotations.add(current);
    }
    current = _rotateClockwise(current);
  }

  return rotations;
}

List<(int, int)> _rotateClockwise(List<(int, int)> shape) {
  if (shape.isEmpty) return [];

  final maxRow = shape.map((cell) => cell.$1).reduce(max);
  final rotated = shape
      .map<(int, int)>((cell) => (cell.$2, maxRow - cell.$1))
      .toList();

  return _normalizeShape(rotated);
}

List<(int, int)> _normalizeShape(List<(int, int)> shape) {
  if (shape.isEmpty) return [];

  final minRow = shape.map((cell) => cell.$1).reduce(min);
  final minCol = shape.map((cell) => cell.$2).reduce(min);
  final normalized = shape
      .map<(int, int)>((cell) => (cell.$1 - minRow, cell.$2 - minCol))
      .toList();

  normalized.sort((a, b) {
    final rowCompare = a.$1.compareTo(b.$1);
    return rowCompare != 0 ? rowCompare : a.$2.compareTo(b.$2);
  });

  return normalized;
}

String _shapeKey(List<(int, int)> shape) =>
    _normalizeShape(shape)
        .map((cell) => '${cell.$1},${cell.$2}')
        .join(';');

// Predefined colors for pieces
final List<int> _pieceColors = [
  Colors.blue.value,
  Colors.green.value,
  Colors.red.value,
  Colors.purple.value,
  Colors.orange.value,
  Colors.teal.value,
];

class Piece {
  final List<(int, int)> shape;
  final int color; // ARGB color value

  final int width;
  final int height;

  Piece({required this.shape, required this.color})
      : width = _calculateWidth(shape),
        height = _calculateHeight(shape);

  static int _calculateWidth(List<(int, int)> shape) {
    if (shape.isEmpty) return 0;
    return shape.map((e) => e.$2).reduce(max) + 1;
  }

  static int _calculateHeight(List<(int, int)> shape) {
    if (shape.isEmpty) return 0;
    return shape.map((e) => e.$1).reduce(max) + 1;
  }

  factory Piece.generateRandomPiece() {
    final random = Random();
    final randomShape = _pieceShapes[random.nextInt(_pieceShapes.length)];
    final randomColor = _pieceColors[random.nextInt(_pieceColors.length)];
    return Piece(shape: randomShape, color: randomColor);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Piece &&
          runtimeType == other.runtimeType &&
          shape == other.shape &&
          color == other.color;

  @override
  int get hashCode => shape.hashCode ^ color.hashCode;
}
