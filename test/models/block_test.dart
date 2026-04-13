import 'package:flutter_test/flutter_test.dart';
import 'package:blockblast_flutter/models/block.dart';

void main() {
  group('Block', () {
    test('Block can be instantiated with a color', () {
      const block = Block(color: 0xFF00FF00); // Green color
      expect(block, isA<Block>());
      expect(block.color, 0xFF00FF00);
    });
  });
}
