import 'package:flutter/material.dart';
import 'package:blockblast_flutter/models/piece.dart';
import 'package:blockblast_flutter/widgets/block_widget.dart';
import 'package:blockblast_flutter/models/block.dart'
    as model_block; // Use as import

class PieceShelf extends StatelessWidget {
  final List<Piece> pieces;
  final VoidCallback? onPickUp;
  final VoidCallback? onDragFinished;

  const PieceShelf({
    Key? key,
    required this.pieces,
    this.onPickUp,
    this.onDragFinished,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('piece_shelf'),
      height: 100.0,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border.all(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: pieces.map((piece) {
          return Draggable<Piece>(
            data: piece,
            onDragStarted: onPickUp,
            onDragEnd: (_) => onDragFinished?.call(),
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedbackOffset: Offset(0, -(piece.height * 40.0)),
            feedback: Transform.translate(
              offset: Offset(-(piece.width * 40.0) / 2, -(piece.height * 40.0)),
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  key: const Key('drag_feedback'),
                  width: piece.width * 40.0,
                  height: piece.height * 40.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(piece.height, (row) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(piece.width, (col) {
                          final isBlock = piece.shape.contains((row, col));
                          return BlockWidget(
                            block: isBlock
                                ? model_block.Block(color: piece.color)
                                : model_block.Block.empty(),
                            size: 40.0,
                          );
                        }),
                      );
                    }),
                  ),
                ),
              ),
            ),
            childWhenDragging: SizedBox(
              // Invisible placeholder when dragging
              width: 5 * 18.0,
              height: 5 * 18.0,
            ),
            child: Container(
              // The actual piece on the shelf
              width: 5 * 18.0,
              height: 5 * 18.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(piece.height, (row) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(piece.width, (col) {
                      final isBlock = piece.shape.contains((row, col));
                      return BlockWidget(
                        block: isBlock
                            ? model_block.Block(color: piece.color)
                            : model_block.Block.empty(),
                        size: 16.0,
                      );
                    }),
                  );
                }),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
