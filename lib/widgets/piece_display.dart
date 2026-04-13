import 'package:flutter/material.dart';

import '../models/block_shape.dart';

/// Renders a single [BlockShape] at the given [cellSize].
///
/// Used both in the piece palette and as the drag feedback widget.
class PieceDisplay extends StatelessWidget {
  const PieceDisplay({
    super.key,
    required this.piece,
    required this.cellSize,
    this.opacity = 1.0,
  });

  final BlockShape piece;
  final double cellSize;

  /// Overall opacity (0.0–1.0). Useful for the "ghost" shown while dragging.
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(piece.rows, (r) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(piece.cols, (c) {
              return SizedBox(
                width: cellSize + 2,
                height: cellSize + 2,
                child: piece.cells[r][c]
                    ? Padding(
                        padding: const EdgeInsets.all(1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: piece.color,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: piece.color.withAlpha(180),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              );
            }),
          );
        }),
      ),
    );
  }
}
