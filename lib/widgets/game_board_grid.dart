import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
  final bool isDraggingPiece;

  const GameBoardGrid({
    super.key,
    required this.blocks,
    this.cellSize = 42.0,
    required this.didAcceptData,
    this.isDraggingPiece = false,
  });

  @override
  State<GameBoardGrid> createState() => _GameBoardGridState();
}

class _GameBoardGridState extends State<GameBoardGrid>
    with SingleTickerProviderStateMixin {
  int? _hoverRow;
  int? _hoverCol;
  Piece? _hoverPiece;
  Set<int> _previewRows = <int>{};
  Set<int> _previewCols = <int>{};
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  double get _hoverPreviewMargin => widget.cellSize * 1.75;

  bool _isOutsideVisibleBoard(Offset localOffset) {
    final boardExtent = widget.gridSize * widget.cellSize;
    return localOffset.dx < _hoverPreviewMargin ||
        localOffset.dx > _hoverPreviewMargin + boardExtent ||
        localOffset.dy < _hoverPreviewMargin ||
        localOffset.dy > _hoverPreviewMargin + boardExtent;
  }

  void _updatePulseAnimation({required bool active}) {
    if (active) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
      return;
    }

    _pulseController.stop();
    _pulseController.value = 0;
  }

  void _resetHoverState() {
    if (_hoverRow == null &&
        _hoverCol == null &&
        _hoverPiece == null &&
        _previewRows.isEmpty &&
        _previewCols.isEmpty) {
      return;
    }

    _updatePulseAnimation(active: false);

    setState(() {
      _hoverRow = null;
      _hoverCol = null;
      _hoverPiece = null;
      _previewRows = <int>{};
      _previewCols = <int>{};
    });
  }

  @override
  void didUpdateWidget(covariant GameBoardGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDraggingPiece && !widget.isDraggingPiece) {
      _resetHoverState();
    }
  }

  (int, int) _getDropCell(Offset localOffset, Piece piece) {
    final double boardX = localOffset.dx - _hoverPreviewMargin;
    final double boardY = localOffset.dy - _hoverPreviewMargin;
    final double topLeftX = boardX - (piece.width * widget.cellSize) / 2;
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
            final linesToClear = getLinesToClearForPlacement(
              widget.blocks,
              piece,
              row,
              col,
            );
            final previewRows = linesToClear.rows.toSet();
            final previewCols = linesToClear.cols.toSet();
            _updatePulseAnimation(
              active: previewRows.isNotEmpty || previewCols.isNotEmpty,
            );

            if (_hoverRow != row || _hoverCol != col || _hoverPiece != piece) {
              setState(() {
                _hoverRow = row;
                _hoverCol = col;
                _hoverPiece = piece;
                _previewRows = previewRows;
                _previewCols = previewCols;
              });
            } else if (!setEquals(_previewRows, previewRows) ||
                !setEquals(_previewCols, previewCols)) {
              setState(() {
                _previewRows = previewRows;
                _previewCols = previewCols;
              });
            }
          } else {
            if (!_isOutsideVisibleBoard(localOffset) &&
                _hoverRow != null &&
                _hoverCol != null &&
                ((row - _hoverRow!).abs() > 1 ||
                    (col - _hoverCol!).abs() > 1)) {
              _resetHoverState();
            }
          }
        }
      },
      onLeave: (Piece? piece) {
        if (!widget.isDraggingPiece) {
          _resetHoverState();
        }
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

        _resetHoverState();
      },
      builder:
          (
            BuildContext context,
            List<Piece?> candidateData,
            List rejectedData,
          ) {
            return Padding(
              padding: EdgeInsets.all(_hoverPreviewMargin),
              child: Container(
                //padding: EdgeInsets.only(bottom: widget.padding.toDouble()),
                key: const Key('game_board_grid'),
                width: widget.gridSize * widget.cellSize,
                height: widget.gridSize * widget.cellSize,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2.0),
                ),
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Stack(
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
                        if (_previewRows.isNotEmpty || _previewCols.isNotEmpty)
                          ..._buildClearLinePreview(),
                        if (_hoverRow != null &&
                            _hoverCol != null &&
                            _hoverPiece != null)
                          ..._buildPreviewGhost(),
                      ],
                    );
                  },
                ),
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

    for (final pos in piece.shape) {
      final int row = baseRow + pos.$1;
      final int col = baseCol + pos.$2;

      if (row >= 0 &&
          row < widget.gridSize &&
          col >= 0 &&
          col < widget.gridSize) {
        ghostBlocks.add(
          Positioned(
            top: row * (widget.cellSize - 0.5),
            left: col * (widget.cellSize - 0.5),
            width: widget.cellSize,
            height: widget.cellSize,
            child: Opacity(
              opacity: 0.5,
              child: BlockWidget(
                block: Block(color: piece.color),
                size: widget.cellSize,
              ),
            ),
          ),
        );
      }
    }
    return ghostBlocks;
  }

  List<Widget> _buildClearLinePreview() {
    final List<Widget> highlights = [];
    final pulse = _pulseAnimation.value;
    final fillAlpha = 0.55 + (0.35 * pulse);
    final strokeAlpha = 0.55 + (0.35 * pulse);
    final strokeWidth = 1.0 + (0.8 * pulse);

    for (final row in _previewRows) {
      highlights.add(
        Positioned(
          top: row * widget.cellSize,
          left: 0,
          width: widget.gridSize * widget.cellSize,
          height: widget.cellSize,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: fillAlpha),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: strokeAlpha),
                  width: strokeWidth,
                ),
              ),
            ),
          ),
        ),
      );
    }

    for (final col in _previewCols) {
      highlights.add(
        Positioned(
          top: 0,
          left: col * widget.cellSize,
          width: widget.cellSize,
          height: widget.gridSize * widget.cellSize,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: fillAlpha),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: strokeAlpha),
                  width: strokeWidth,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return highlights;
  }
}
