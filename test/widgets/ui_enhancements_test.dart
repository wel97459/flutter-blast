import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blockblast_flutter/widgets/piece_shelf.dart';
import 'package:blockblast_flutter/models/piece.dart';
import 'package:blockblast_flutter/widgets/block_widget.dart';
import 'package:blockblast_flutter/widgets/game_board_grid.dart';
import 'package:blockblast_flutter/models/block.dart';
import 'package:blockblast_flutter/main.dart';

void main() {
  group('UI Enhancements - PieceShelf Height', () {
    testWidgets('PieceShelf should have a fixed height of 100px', (WidgetTester tester) async {
      final pieces = [
        Piece(shape: [(0,0)], color: Colors.red.value),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(child: Container()),
                PieceShelf(pieces: pieces),
              ],
            ),
          ),
        ),
      );

      final pieceShelfFinder = find.byKey(const Key('piece_shelf'));
      expect(pieceShelfFinder, findsOneWidget);

      final Size size = tester.getSize(pieceShelfFinder);
      expect(size.height, 100.0);
    });
  });

  group('UI Enhancements - Drag Placeholder', () {
    testWidgets('Piece should disappear from shelf when being dragged', (WidgetTester tester) async {
      final pieces = [
        Piece(shape: [(0,0)], color: Colors.red.value),
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

      // Verify the piece is initially there (one BlockWidget)
      expect(find.descendant(of: find.byKey(const Key('piece_shelf')), matching: find.byType(BlockWidget)), findsNWidgets(1));

      // Start dragging the piece
      final draggableFinder = find.byType(Draggable<Piece>);
      final gesture = await tester.startGesture(tester.getCenter(draggableFinder));
      await tester.pump(); // Start the drag

      // Verify that the piece on the shelf (childWhenDragging) is now empty/invisible
      expect(find.descendant(of: find.byKey(const Key('piece_shelf')), matching: find.byType(BlockWidget)), findsNothing);

      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  group('UI Enhancements - Feedback Offset', () {
    testWidgets('Feedback widget should be offset above the finger', (WidgetTester tester) async {
      final pieces = [
        Piece(shape: [(0,0), (1,0)], color: Colors.red.value), // 1x2 piece (height = 2 blocks = 80px in feedback)
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

      final Offset dragStart = tester.getCenter(find.byType(Draggable<Piece>));
      final gesture = await tester.startGesture(dragStart);
      await tester.pump();

      final feedbackFinder = find.byKey(const Key('drag_feedback'));
      expect(feedbackFinder, findsOneWidget);

      final Offset feedbackCenter = tester.getCenter(feedbackFinder);
      
      // Expected height of the piece in feedback is piece.height * 40.0
      // For 1x2 piece, height is 80.0.
      // If the bottom of the piece is at the finger, its center should be 40.0px ABOVE the finger.
      
      expect(feedbackCenter.dy, lessThan(dragStart.dy));
      
      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  group('UI Enhancements - Ghost Offset', () {
    testWidgets('Ghost preview should be offset above the finger', (WidgetTester tester) async {
      final pieces = [
        Piece(shape: [(0,0), (1,0)], color: Colors.red.value), // 1x2 piece (height = 80px)
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Center(
                  child: GameBoardGrid(
                    blocks: List.generate(8, (_) => List.generate(8, (_) => Block.empty())),
                    didAcceptData: (_, __, ___) {},
                  ),
                ),
                PieceShelf(pieces: pieces),
              ],
            ),
          ),
        ),
      );

      final gameBoardGridFinder = find.byKey(const Key('game_board_grid'));
      final Offset gridTopLeft = tester.getTopLeft(gameBoardGridFinder);
      
      // Pointer at row 4, col 4 (relative to grid)
      final Offset dragPoint = gridTopLeft + const Offset(160, 160);

      final gesture = await tester.startGesture(tester.getCenter(find.byType(Draggable<Piece>)));
      await gesture.moveTo(dragPoint);
      await tester.pump();

      // Find Opacity(0.5) widgets which are ghost blocks
      final ghostBlockFinder = find.descendant(
        of: gameBoardGridFinder,
        matching: find.byType(Opacity),
      );
      expect(ghostBlockFinder, findsNWidgets(2));

      final Offset firstGhostBlockPos = tester.getTopLeft(ghostBlockFinder.first);
      final double relativeY = firstGhostBlockPos.dy - gridTopLeft.dy;
      
      // We expect it to be row 2 or higher. (row 2 top = 80px + 2px border = 82px)
      expect(relativeY, lessThanOrEqualTo(82.0));
      
      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  group('UI Enhancements - Precise Drop', () {
    testWidgets('Piece should be dropped at the offset location', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final gameBoardGridFinder = find.byKey(const Key('game_board_grid'));
      final Offset gridTopLeft = tester.getTopLeft(gameBoardGridFinder);
      
      final pieceDraggableFinder = find.byType(Draggable<Piece>);
      final Draggable<Piece> draggable = tester.widget(pieceDraggableFinder.first);
      final Piece piece = draggable.data!;
      
      // Target row 2. (y = gridTopLeft.dy + 80)
      // Finger should be at y = gridTopLeft.dy + 80 + piece.height * 40.0
      final double fingerY = 80.0 + piece.height * 40.0;
      final Offset dragPoint = gridTopLeft + Offset(80.0, fingerY); // col 2

      final gesture = await tester.startGesture(tester.getCenter(pieceDraggableFinder.first));
      await gesture.moveTo(dragPoint);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      // Verify that pieces on shelf decreased.
      expect(find.byType(Draggable<Piece>), findsNWidgets(2));
    });
  });
}
