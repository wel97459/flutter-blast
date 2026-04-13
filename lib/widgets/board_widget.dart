import 'package:flutter/material.dart';

import '../models/block_shape.dart';
import '../models/game_state.dart';

/// Visual appearance constants.
const _kBorderRadius = 4.0;
const _kCellGap = 2.0;
const _kBoardBackground = Color(0xFF1A1A2E);
const _kEmptyCell = Color(0xFF16213E);
const _kGridLine = Color(0xFF0F3460);

/// Renders the 8×8 game board and handles drag-to-place interactions.
///
/// The widget is a [StatefulWidget] so it can track the hovered cell while a
/// piece is being dragged over the board.
class BoardWidget extends StatefulWidget {
  const BoardWidget({
    super.key,
    required this.gameState,
  });

  final GameState gameState;

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {
  /// Cell (row, col) that a dragged piece is currently hovering over, or `null`.
  (int, int)? _hoverAnchor;

  /// Index into [GameState.currentPieces] for the piece being dragged.
  int? _draggedPieceIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final cellSize =
            (size - _kCellGap * (GameState.boardSize + 1)) / GameState.boardSize;
        return DragTarget<int>(
          onWillAcceptWithDetails: (details) {
            final anchor = _cellFromOffset(details.offset, cellSize, context);
            if (anchor == null) return false;
            final piece = widget.gameState.currentPieces[details.data];
            if (piece == null) return false;
            return widget.gameState.canPlace(piece, anchor.$1, anchor.$2);
          },
          onAcceptWithDetails: (details) {
            final anchor = _cellFromOffset(details.offset, cellSize, context);
            if (anchor == null) return;
            widget.gameState.placePiece(details.data, anchor.$1, anchor.$2);
            setState(() {
              _hoverAnchor = null;
              _draggedPieceIndex = null;
            });
          },
          onMove: (details) {
            setState(() {
              _draggedPieceIndex = details.data;
              _hoverAnchor = _cellFromOffset(details.offset, cellSize, context);
            });
          },
          onLeave: (_) {
            setState(() {
              _hoverAnchor = null;
              _draggedPieceIndex = null;
            });
          },
          builder: (context, candidateData, rejectedData) {
            return _buildGrid(cellSize, candidateData.isNotEmpty);
          },
        );
      },
    );
  }

  Widget _buildGrid(double cellSize, bool hasCandidates) {
    final gameState = widget.gameState;

    // Compute preview cells.
    Set<(int, int)> previewCells = {};
    bool previewValid = false;
    if (_hoverAnchor != null && _draggedPieceIndex != null) {
      final piece = gameState.currentPieces[_draggedPieceIndex!];
      if (piece != null) {
        final cells =
            gameState.placementCells(piece, _hoverAnchor!.$1, _hoverAnchor!.$2);
        previewValid = gameState.canPlace(piece, _hoverAnchor!.$1, _hoverAnchor!.$2);
        previewCells = cells.toSet();
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: _kBoardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(_kCellGap),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(GameState.boardSize, (row) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(GameState.boardSize, (col) {
              return Padding(
                padding: const EdgeInsets.all(_kCellGap / 2),
                child: _buildCell(
                  row,
                  col,
                  cellSize,
                  gameState.board[row][col],
                  previewCells.contains((row, col)),
                  previewValid,
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildCell(
    int row,
    int col,
    double cellSize,
    Color? filled,
    bool isPreview,
    bool previewValid,
  ) {
    Color color;
    if (filled != null) {
      color = filled;
    } else if (isPreview) {
      color = previewValid
          ? Colors.greenAccent.withAlpha(160)
          : Colors.redAccent.withAlpha(160);
    } else {
      color = _kEmptyCell;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 80),
      width: cellSize,
      height: cellSize,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_kBorderRadius),
        border: Border.all(color: _kGridLine, width: 1),
        boxShadow: filled != null
            ? [
                BoxShadow(
                  color: filled.withAlpha(100),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
    );
  }

  /// Converts an absolute screen [offset] to a board cell (row, col), or
  /// `null` if the offset is outside the board.
  (int, int)? _cellFromOffset(
      Offset offset, double cellSize, BuildContext ctx) {
    final renderBox = ctx.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    final local = renderBox.globalToLocal(offset);

    // Account for the container padding.
    const pad = _kCellGap;
    final col = ((local.dx - pad) / (cellSize + _kCellGap)).floor();
    final row = ((local.dy - pad) / (cellSize + _kCellGap)).floor();

    if (row < 0 || row >= GameState.boardSize) return null;
    if (col < 0 || col >= GameState.boardSize) return null;
    return (row, col);
  }
}
