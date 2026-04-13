import 'package:flutter/material.dart';

import 'block_shape.dart';

/// The complete state of one game session.
///
/// This class is a [ChangeNotifier]; call [notifyListeners] after mutations
/// and wrap consuming widgets in a [ListenableBuilder] (or use `provider` /
/// `context.watch`).
class GameState extends ChangeNotifier {
  static const int boardSize = 8;

  /// The board grid. `null` means empty; a [Color] means filled.
  late List<List<Color?>> board;

  /// The three pieces currently offered to the player.
  /// A `null` entry means that piece was already placed.
  late List<BlockShape?> currentPieces;

  int score = 0;
  int highScore = 0;
  bool isGameOver = false;

  /// Seed used for piece generation (incremented each round).
  int _seed = 1;

  // ── Initialization ──────────────────────────────────────────────────────

  GameState() {
    _reset();
  }

  void _reset() {
    board = List.generate(boardSize, (_) => List.filled(boardSize, null));
    score = 0;
    isGameOver = false;
    _seed = DateTime.now().millisecondsSinceEpoch;
    currentPieces = generatePieces(_seed);
  }

  void restartGame() {
    _reset();
    notifyListeners();
  }

  // ── Queries ─────────────────────────────────────────────────────────────

  /// Returns the (row, col) pairs of all cells the [piece] would occupy if its
  /// top-left corner is placed at ([anchorRow], [anchorCol]).
  List<(int, int)> placementCells(
      BlockShape piece, int anchorRow, int anchorCol) {
    return piece.occupiedCells
        .map((cell) => (cell.$1 + anchorRow, cell.$2 + anchorCol))
        .toList();
  }

  /// Returns `true` iff [piece] can be placed with its top-left at
  /// ([anchorRow], [anchorCol]).
  bool canPlace(BlockShape piece, int anchorRow, int anchorCol) {
    for (final cell in placementCells(piece, anchorRow, anchorCol)) {
      final r = cell.$1;
      final c = cell.$2;
      if (r < 0 || r >= boardSize || c < 0 || c >= boardSize) return false;
      if (board[r][c] != null) return false;
    }
    return true;
  }

  /// Returns `true` iff [piece] can be placed *anywhere* on the board.
  bool canPlaceAnywhere(BlockShape piece) {
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        if (canPlace(piece, r, c)) return true;
      }
    }
    return false;
  }

  // ── Mutations ───────────────────────────────────────────────────────────

  /// Places the piece at [pieceIndex] (from [currentPieces]) with its top-left
  /// corner at ([anchorRow], [anchorCol]).
  ///
  /// Throws [StateError] if the placement is invalid.
  void placePiece(int pieceIndex, int anchorRow, int anchorCol) {
    final piece = currentPieces[pieceIndex];
    if (piece == null) throw StateError('Piece $pieceIndex is already placed.');
    if (!canPlace(piece, anchorRow, anchorCol)) {
      throw StateError('Cannot place piece at ($anchorRow, $anchorCol).');
    }

    // Fill cells.
    for (final cell in placementCells(piece, anchorRow, anchorCol)) {
      board[cell.$1][cell.$2] = piece.color;
    }

    // Remove the placed piece.
    currentPieces[pieceIndex] = null;

    // Score: 1 point per cell placed.
    score += piece.occupiedCells.length;

    // Clear completed lines and award bonus.
    final cleared = _clearLines();
    score += cleared * 10 * cleared; // escalating bonus

    // Update high score.
    if (score > highScore) highScore = score;

    // Replenish if all three have been placed.
    if (currentPieces.every((p) => p == null)) {
      _seed += 7;
      currentPieces = generatePieces(_seed);
    }

    // Check game-over condition.
    isGameOver = _checkGameOver();

    notifyListeners();
  }

  // ── Private helpers ─────────────────────────────────────────────────────

  /// Clears all fully-occupied rows and columns, returns the total count.
  int _clearLines() {
    int cleared = 0;

    // Identify full rows.
    final fullRows = <int>[];
    for (int r = 0; r < boardSize; r++) {
      if (board[r].every((cell) => cell != null)) fullRows.add(r);
    }

    // Identify full columns.
    final fullCols = <int>[];
    for (int c = 0; c < boardSize; c++) {
      if (List.generate(boardSize, (r) => board[r][c]).every((v) => v != null)) {
        fullCols.add(c);
      }
    }

    // Clear.
    for (final r in fullRows) {
      for (int c = 0; c < boardSize; c++) {
        board[r][c] = null;
      }
    }
    for (final c in fullCols) {
      for (int r = 0; r < boardSize; r++) {
        board[r][c] = null;
      }
    }

    cleared = fullRows.length + fullCols.length;
    return cleared;
  }

  /// Returns `true` iff no remaining piece can be placed anywhere.
  bool _checkGameOver() {
    for (final piece in currentPieces) {
      if (piece == null) continue;
      if (canPlaceAnywhere(piece)) return false;
    }
    return true;
  }
}
