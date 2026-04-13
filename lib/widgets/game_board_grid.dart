import 'package:flutter/material.dart';
import 'package:blockblast_flutter/models/block.dart';
import 'package:blockblast_flutter/widgets/block_widget.dart';
import 'package:blockblast_flutter/models/piece.dart';
import 'package:blockblast_flutter/models/game_logic.dart';

class GameBoardGrid extends StatefulWidget {
  final List<List<Block>> blocks;
  final int gridSize = 8;
  final double cellSize;
  final int padding = 20;
  final Function(Piece, int, int) didAcceptData;

  const GameBoardGrid({
    Key? key,
    required this.blocks,
    this.cellSize = 42.0,
    required this.didAcceptData,
  }) : super(key: key);

  @override
  State<GameBoardGrid> createState() => _GameBoardGridState();
}

class _GameBoardGridState extends State<GameBoardGrid> {
  int? _hoverRow;
  int? _hoverCol;
  Piece? _hoverPiece;

  (int, int) _getDropCell(Offset localOffset, Piece piece) {
    final double boardX = localOffset.dx - widget.padding.toDouble();
    final double boardY = localOffset.dy - widget.padding.toDouble();
    final double topLeftX = boardX - (piece.width * widget.cellSize)/2;
    final double topLeftY = boardY - (piece.height * widget.cellSize);

    return (
      (topLeftY / widget.cellSize).round(),
      (topLeftX / widget.cellSize).round(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<Piece>(
      onWillAcceptWithDetails: (DragTargetDetails<Piece> details) {
        // Always return true to allow onMove to handle the logic and show the ghost.
        // We will validate the actual placement in onAcceptWithDetails.
        return true;
      },
      onMove: (DragTargetDetails<Piece> details) {
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final Offset localOffset = renderBox.globalToLocal(details.offset);
          final Piece piece = details.data;
          final (int row, int col) = _getDropCell(localOffset, piece);

          if (isValidPlacement(widget.blocks, piece, row, col)) {
            if (_hoverRow != row || _hoverCol != col || _hoverPiece != piece) {
              setState(() {
                _hoverRow = row;
                _hoverCol = col;
                _hoverPiece = piece;
              });
            }
          } else {
            if (_hoverRow != null) {
              setState(() {
                _hoverRow = null;
                _hoverCol = null;
                _hoverPiece = null;
              });
            }
          }
        }
      },
      onLeave: (Piece? piece) {
        setState(() {
          _hoverRow = null;
          _hoverCol = null;
          _hoverPiece = null;
        });
      },
      onAcceptWithDetails: (DragTargetDetails<Piece> details) {
        // Use the current hover state if it's valid.
        if (_hoverRow != null && _hoverCol != null && _hoverPiece != null) {
          widget.didAcceptData(_hoverPiece!, _hoverRow!, _hoverCol!);
        } else {
          final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final Offset localOffset = renderBox.globalToLocal(details.offset);
            final Piece piece = details.data;
            final (int row, int col) = _getDropCell(localOffset, piece);

            if (isValidPlacement(widget.blocks, piece, row, col)) {
              widget.didAcceptData(piece, row, col);
            }
          }
        }

        setState(() {
          _hoverRow = null;
          _hoverCol = null;
          _hoverPiece = null;
        });
      },
      builder:
          (
            BuildContext context,
            List<Piece?> candidateData,
            List rejectedData,
          ) {
            return Container(
              padding: EdgeInsets.all(widget.padding.toDouble()),
              key: const Key('game_board_grid'),
              width:
                  widget.gridSize * widget.cellSize +
                  (widget.padding * 2).toDouble(),
              height:
                  widget.gridSize * widget.cellSize +
                  (widget.padding * 2).toDouble(),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.0),
              ),
              child: Stack(
                children: [
                  // The base grid
                  Column(
                    children: List.generate(widget.gridSize, (row) {
                      return Expanded(
                        child: Row(
                          children: List.generate(widget.gridSize, (col) {
                            return Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black26,
                                    width: 0.5,
                                  ),
                                ),
                                child: BlockWidget(
                                  block: widget.blocks[row][col],
                                  size: widget.cellSize,
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                  // The preview ghost
                  if (_hoverRow != null &&
                      _hoverCol != null &&
                      _hoverPiece != null)
                    ..._buildPreviewGhost(),
                ],
              ),
            );
          },
    );
  }

  List<Widget> _buildPreviewGhost() {
    final List<Widget> ghostBlocks = [];
    final Piece piece = _hoverPiece!;
    final int baseRow = _hoverRow!;
    final int baseCol = _hoverCol!;
    final double inset = (widget.cellSize - 40.0).clamp(0.0, 2.0) / 2;
    final double ghostSize = widget.cellSize - (inset * 2);

    for (final pos in piece.shape) {
      final int row = baseRow + pos.$1;
      final int col = baseCol + pos.$2;

      if (row >= 0 &&
          row < widget.gridSize &&
          col >= 0 &&
          col < widget.gridSize) {
        ghostBlocks.add(
          Positioned(
            top: row * widget.cellSize + inset,
            left: col * widget.cellSize + inset,
            width: ghostSize,
            height: ghostSize,
            child: Opacity(
              opacity: 0.5,
              child: BlockWidget(
                block: Block(color: piece.color),
                size: ghostSize,
              ),
            ),
          ),
        );
      }
    }
    return ghostBlocks;
  }
}
