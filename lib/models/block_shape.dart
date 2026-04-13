import 'package:flutter/material.dart';

/// Colors available for block shapes in the game.
const List<Color> kBlockColors = [
  Color(0xFFE53935), // Red
  Color(0xFFFB8C00), // Orange
  Color(0xFFFDD835), // Yellow
  Color(0xFF43A047), // Green
  Color(0xFF00ACC1), // Cyan
  Color(0xFF1E88E5), // Blue
  Color(0xFF8E24AA), // Purple
  Color(0xFFD81B60), // Pink
  Color(0xFF00897B), // Teal
];

/// Defines the shape of a game piece as a 2D grid of booleans.
///
/// Each entry in [cells] is a row; each boolean in that row indicates whether
/// that cell is occupied.
class BlockShape {
  const BlockShape({
    required this.name,
    required this.cells,
    required this.color,
  });

  final String name;

  /// A 2D list where [cells][row][col] == true means that cell is occupied.
  final List<List<bool>> cells;

  final Color color;

  int get rows => cells.length;
  int get cols => cells[0].length;

  /// Returns a list of (row, col) pairs for every occupied cell.
  List<(int, int)> get occupiedCells {
    final result = <(int, int)>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (cells[r][c]) result.add((r, c));
      }
    }
    return result;
  }

  /// Creates a copy with a different color.
  BlockShape withColor(Color c) =>
      BlockShape(name: name, cells: cells, color: c);
}

/// All possible block shapes, without colors (colors are assigned randomly).
const List<BlockShape> _allShapeTemplates = [
  // ── Singles ──────────────────────────────────────
  BlockShape(
      name: 'dot',
      cells: [
        [true]
      ],
      color: Colors.white),

  // ── Horizontal lines ─────────────────────────────
  BlockShape(
      name: 'h2',
      cells: [
        [true, true]
      ],
      color: Colors.white),
  BlockShape(
      name: 'h3',
      cells: [
        [true, true, true]
      ],
      color: Colors.white),
  BlockShape(
      name: 'h4',
      cells: [
        [true, true, true, true]
      ],
      color: Colors.white),
  BlockShape(
      name: 'h5',
      cells: [
        [true, true, true, true, true]
      ],
      color: Colors.white),

  // ── Vertical lines ───────────────────────────────
  BlockShape(
      name: 'v2',
      cells: [
        [true],
        [true]
      ],
      color: Colors.white),
  BlockShape(
      name: 'v3',
      cells: [
        [true],
        [true],
        [true]
      ],
      color: Colors.white),
  BlockShape(
      name: 'v4',
      cells: [
        [true],
        [true],
        [true],
        [true]
      ],
      color: Colors.white),
  BlockShape(
      name: 'v5',
      cells: [
        [true],
        [true],
        [true],
        [true],
        [true]
      ],
      color: Colors.white),

  // ── Squares ──────────────────────────────────────
  BlockShape(
      name: 's2',
      cells: [
        [true, true],
        [true, true]
      ],
      color: Colors.white),
  BlockShape(
      name: 's3',
      cells: [
        [true, true, true],
        [true, true, true],
        [true, true, true]
      ],
      color: Colors.white),

  // ── Small L-shapes (2×2 minus one corner) ────────
  BlockShape(
      name: 'l_br',
      cells: [
        [true, false],
        [true, true]
      ],
      color: Colors.white),
  BlockShape(
      name: 'l_bl',
      cells: [
        [false, true],
        [true, true]
      ],
      color: Colors.white),
  BlockShape(
      name: 'l_tr',
      cells: [
        [true, true],
        [true, false]
      ],
      color: Colors.white),
  BlockShape(
      name: 'l_tl',
      cells: [
        [true, true],
        [false, true]
      ],
      color: Colors.white),

  // ── Big L-shapes (3 tall, corner) ────────────────
  BlockShape(
      name: 'L_br',
      cells: [
        [true, false],
        [true, false],
        [true, true]
      ],
      color: Colors.white),
  BlockShape(
      name: 'L_bl',
      cells: [
        [false, true],
        [false, true],
        [true, true]
      ],
      color: Colors.white),
  BlockShape(
      name: 'L_tr',
      cells: [
        [true, true],
        [true, false],
        [true, false]
      ],
      color: Colors.white),
  BlockShape(
      name: 'L_tl',
      cells: [
        [true, true],
        [false, true],
        [false, true]
      ],
      color: Colors.white),

  // ── Big L-shapes (3 wide, corner) ────────────────
  BlockShape(
      name: 'Lh_br',
      cells: [
        [false, false, true],
        [true, true, true]
      ],
      color: Colors.white),
  BlockShape(
      name: 'Lh_bl',
      cells: [
        [true, false, false],
        [true, true, true]
      ],
      color: Colors.white),
  BlockShape(
      name: 'Lh_tr',
      cells: [
        [true, true, true],
        [false, false, true]
      ],
      color: Colors.white),
  BlockShape(
      name: 'Lh_tl',
      cells: [
        [true, true, true],
        [true, false, false]
      ],
      color: Colors.white),

  // ── T-shapes ─────────────────────────────────────
  BlockShape(
      name: 't_down',
      cells: [
        [true, true, true],
        [false, true, false]
      ],
      color: Colors.white),
  BlockShape(
      name: 't_up',
      cells: [
        [false, true, false],
        [true, true, true]
      ],
      color: Colors.white),
  BlockShape(
      name: 't_right',
      cells: [
        [true, false],
        [true, true],
        [true, false]
      ],
      color: Colors.white),
  BlockShape(
      name: 't_left',
      cells: [
        [false, true],
        [true, true],
        [false, true]
      ],
      color: Colors.white),

  // ── Z / S shapes ─────────────────────────────────
  BlockShape(
      name: 'z',
      cells: [
        [true, true, false],
        [false, true, true]
      ],
      color: Colors.white),
  BlockShape(
      name: 's',
      cells: [
        [false, true, true],
        [true, true, false]
      ],
      color: Colors.white),
  BlockShape(
      name: 'zv',
      cells: [
        [false, true],
        [true, true],
        [true, false]
      ],
      color: Colors.white),
  BlockShape(
      name: 'sv',
      cells: [
        [true, false],
        [true, true],
        [false, true]
      ],
      color: Colors.white),
];

/// Returns a random sample of 3 [BlockShape]s (with random colors).
List<BlockShape> generatePieces(int seed) {
  final rng = _Random(seed);
  final indices = List.generate(_allShapeTemplates.length, (i) => i);
  // Shuffle via Fisher–Yates
  for (int i = indices.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final tmp = indices[i];
    indices[i] = indices[j];
    indices[j] = tmp;
  }
  return indices.take(3).map((i) {
    final colorIndex = rng.nextInt(kBlockColors.length);
    return _allShapeTemplates[i].withColor(kBlockColors[colorIndex]);
  }).toList();
}

/// Minimal LCG random number generator (avoids dart:math for testability).
class _Random {
  _Random(int seed) : _state = seed & 0x7FFFFFFF;

  int _state;

  int nextInt(int max) {
    _state = (_state * 1103515245 + 12345) & 0x7FFFFFFF;
    return _state % max;
  }
}
