import 'package:flutter/material.dart';

class Block {
  final int color; // Use int to represent ARGB color
  final bool isFilled;

  const Block({
    required this.color,
    this.isFilled = true,
  });

  // Factory constructor for an empty block
  factory Block.empty() {
    return const Block(color: 0x00000000, isFilled: false); // Transparent
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Block &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          isFilled == other.isFilled;

  @override
  int get hashCode => color.hashCode ^ isFilled.hashCode;
}
