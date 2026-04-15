import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blockblast_flutter/main.dart'; // Assuming MyApp is here
import 'package:blockblast_flutter/models/piece.dart';
import 'package:blockblast_flutter/widgets/block_widget.dart' as model_block;

void main() {
  group('Drag-and-Drop Interaction', () {
    testWidgets('should make each piece on the shelf draggable', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Expect to find 3 Draggable widgets, one for each piece on the shelf
      expect(find.byType(Draggable<Piece>), findsNWidgets(3));
    });

    testWidgets('GameBoardGrid should contain a DragTarget for pieces', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Find the GameBoardGrid
      final gameBoardGridFinder = find.byKey(const Key('game_board_grid'));
      expect(gameBoardGridFinder, findsOneWidget);

      // Expect to find a DragTarget<Piece> widget
      // We look for it globally as it wraps the grid
      expect(find.byType(DragTarget<Piece>), findsOneWidget);

      // Verify that the game_board_grid is a descendant of the DragTarget
      expect(find.descendant(
        of: find.byType(DragTarget<Piece>),
        matching: gameBoardGridFinder,
      ), findsOneWidget);
    });

    testWidgets('Dragging a piece over the grid should show a ghost piece', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final pieceFinder = find.byType(Draggable<Piece>);
      final gameBoardGridFinder = find.byKey(const Key('game_board_grid'));
      final firstPieceCenter = tester.getCenter(pieceFinder.first);
      final gridCenter = tester.getCenter(gameBoardGridFinder);

      final gesture = await tester.startGesture(firstPieceCenter);
      await gesture.moveTo(gridCenter);
      await tester.pump(const Duration(milliseconds: 100)); // Ensure onMove is processed

      // The ghost piece blocks are drawn with Opacity(0.5)
      // We expect to find BlockWidgets within Opacity
      expect(find.descendant(
        of: find.byType(Opacity),
        matching: find.byType(model_block.BlockWidget),
      ), findsAtLeastNWidgets(1));

      // Now move outside the grid
      await gesture.moveTo(gridCenter + const Offset(400, 400));
      await tester.pump(const Duration(milliseconds: 100));

      // Ghost should be gone
      expect(find.descendant(
        of: find.byType(Opacity),
        matching: find.byType(model_block.BlockWidget),
      ), findsNothing);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('Dragging a piece from the shelf to the grid should update the grid', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Find all pieces on the shelf (initially 3)
      final pieceFinder = find.byType(Draggable<Piece>);
      expect(pieceFinder, findsNWidgets(3));
      final Draggable<Piece> draggable = tester.widget(pieceFinder.first);
      final Piece piece = draggable.data!;

      // Find the grid to drop onto
      final gameBoardGridFinder = find.byKey(const Key('game_board_grid'));
      final Offset gridTopLeft = tester.getTopLeft(gameBoardGridFinder);

      // Perform the drag and drop
      final firstPiece = pieceFinder.first;
      final firstPieceCenter = tester.getCenter(firstPiece);
      // Finger at row 4 + piece.height, col 4
      final Offset dragPoint = gridTopLeft + Offset(160.0, 160.0 + piece.height * 40.0);

      final gesture = await tester.startGesture(firstPieceCenter);
      await gesture.moveTo(dragPoint);
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.up();
      await tester.pumpAndSettle();

      // We expect 2 pieces left on shelf after drag and drop
      expect(find.byType(Draggable<Piece>), findsNWidgets(2));
    });

    testWidgets('Dragging a piece onto an occupied spot should NOT update the grid', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final pieceFinder = find.byType(Draggable<Piece>);
      final gameBoardGridFinder = find.byKey(const Key('game_board_grid'));
      final Offset gridTopLeft = tester.getTopLeft(gameBoardGridFinder);

      // First drop
      final Draggable<Piece> draggable1 = tester.widget(pieceFinder.first);
      final Piece piece1 = draggable1.data!;
      final Offset dragPoint1 = gridTopLeft + Offset(160.0, 160.0 + piece1.height * 40.0);
      
      final gesture1 = await tester.startGesture(tester.getCenter(pieceFinder.first));
      await gesture1.moveTo(dragPoint1);
      await tester.pump(const Duration(milliseconds: 100));
      await gesture1.up();
      await tester.pumpAndSettle();
      expect(find.byType(Draggable<Piece>), findsNWidgets(2));

      // Second drop at the same location
      final Draggable<Piece> draggable2 = tester.widget(pieceFinder.first);
      final Piece piece2 = draggable2.data!;
      final Offset dragPoint2 = gridTopLeft + Offset(160.0, 160.0 + piece2.height * 40.0);

      final gesture2 = await tester.startGesture(tester.getCenter(pieceFinder.first));
      await gesture2.moveTo(dragPoint2);
      await tester.pump(const Duration(milliseconds: 100));
      await gesture2.up();
      await tester.pumpAndSettle();

      // Should still have 2 pieces (second drop was rejected)
      expect(find.byType(Draggable<Piece>), findsNWidgets(2));
    });

    testWidgets('Placing all three pieces should refill the shelf', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final gameBoardGridFinder = find.byKey(const Key('game_board_grid'));
      final Offset gridTopLeft = tester.getTopLeft(gameBoardGridFinder);
      
      // Drop 1 at safe spot 1 (col 1, row 1)
      final pieceFinder1 = find.byType(Draggable<Piece>);
      final Draggable<Piece> draggable1 = tester.widget(pieceFinder1.at(0));
      final piece1 = draggable1.data!;
      final gesture1 = await tester.startGesture(tester.getCenter(pieceFinder1.at(0)));
      await gesture1.moveTo(gridTopLeft + Offset(40.0 + piece1.width * 20.0, 40.0 + piece1.height * 40.0));
      await tester.pump(const Duration(milliseconds: 100));
      await gesture1.up();
      await tester.pumpAndSettle();
      expect(find.byType(Draggable<Piece>), findsNWidgets(2));

      // Drop 2 at safe spot 2 (col 5, row 1)
      final pieceFinder2 = find.byType(Draggable<Piece>);
      final Draggable<Piece> draggable2 = tester.widget(pieceFinder2.at(0));
      final piece2 = draggable2.data!;
      final gesture2 = await tester.startGesture(tester.getCenter(pieceFinder2.at(0)));
      await gesture2.moveTo(gridTopLeft + Offset(200.0 + piece2.width * 20.0, 40.0 + piece2.height * 40.0));
      await tester.pump(const Duration(milliseconds: 100));
      await gesture2.up();
      await tester.pumpAndSettle();
      expect(find.byType(Draggable<Piece>), findsNWidgets(1));

      // Drop 3 at safe spot 3 (col 1, row 5)
      final pieceFinder3 = find.byType(Draggable<Piece>);
      final Draggable<Piece> draggable3 = tester.widget(pieceFinder3.at(0));
      final piece3 = draggable3.data!;
      final gesture3 = await tester.startGesture(tester.getCenter(pieceFinder3.at(0)));
      await gesture3.moveTo(gridTopLeft + Offset(40.0 + piece3.width * 20.0, 200.0 + piece3.height * 40.0));
      await tester.pump(const Duration(milliseconds: 100));
      await gesture3.up();
      await tester.pumpAndSettle();
      
      // Should be refilled to 3
      expect(find.byType(Draggable<Piece>), findsNWidgets(3));
    });
  });
}
