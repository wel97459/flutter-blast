import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blockblast_flutter/widgets/piece_shelf.dart'; // Assuming PieceShelf is here
import 'package:blockblast_flutter/models/piece.dart';
import 'package:blockblast_flutter/widgets/block_widget.dart';

void main() {
  group('PieceShelf', () {
    testWidgets('should display three pieces', (WidgetTester tester) async {
      // Create some dummy pieces
      final pieces = [
        Piece(shape: [(0,0)], color: Colors.red.value),
        Piece(shape: [(0,0), (0,1)], color: Colors.blue.value),
        Piece(shape: [(0,0), (1,0)], color: Colors.green.value),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PieceShelf(pieces: pieces),
            ),
          ),
        ),
      );

      // Expect to find five BlockWidgets (representing the total blocks in the pieces)
      expect(find.byType(BlockWidget), findsNWidgets(5));
      
      // Optionally, verify the arrangement or colors if the PieceShelf has specific layout logic
      // For now, just checking the count of BlockWidgets is sufficient.
    });
  });
}
