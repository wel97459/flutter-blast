import 'package:flutter/material.dart';

import '../models/game_state.dart';
import 'piece_display.dart';

/// Bottom panel that shows the three current pieces and makes them draggable.
class PiecesPanel extends StatelessWidget {
  const PiecesPanel({
    super.key,
    required this.gameState,
  });

  final GameState gameState;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          gameState.currentPieces.length,
          (i) => _PieceTile(
            key: ValueKey('piece_$i'),
            pieceIndex: i,
            gameState: gameState,
          ),
        ),
      ),
    );
  }
}

class _PieceTile extends StatelessWidget {
  const _PieceTile({
    super.key,
    required this.pieceIndex,
    required this.gameState,
  });

  final int pieceIndex;
  final GameState gameState;

  @override
  Widget build(BuildContext context) {
    final piece = gameState.currentPieces[pieceIndex];

    // Piece already placed → show empty slot.
    if (piece == null) {
      return const SizedBox(width: 80, height: 80);
    }

    // Scale so the piece fits in a 80×80 tile.
    const maxSlotSize = 80.0;
    final cellSize = (maxSlotSize / (piece.rows > piece.cols ? piece.rows : piece.cols))
        .clamp(8.0, 22.0);

    return Draggable<int>(
      data: pieceIndex,
      feedback: Material(
        color: Colors.transparent,
        child: PieceDisplay(piece: piece, cellSize: cellSize * 1.5),
      ),
      childWhenDragging: PieceDisplay(
        piece: piece,
        cellSize: cellSize,
        opacity: 0.3,
      ),
      child: SizedBox(
        width: 90,
        height: 90,
        child: Center(
          child: PieceDisplay(piece: piece, cellSize: cellSize),
        ),
      ),
    );
  }
}
