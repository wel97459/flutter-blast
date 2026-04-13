import 'package:flutter/material.dart';
import 'package:blockblast_flutter/models/block.dart';

class BlockWidget extends StatelessWidget {
  final Block block;
  final double size;

  const BlockWidget({
    Key? key,
    required this.block,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!block.isFilled) {
      return SizedBox(
        width: size,
        height: size,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color(block.color),
        border: Border.all(color: Colors.black54, width: 1.0),
        borderRadius: BorderRadius.circular(2.0),
      ),
    );
  }
}
