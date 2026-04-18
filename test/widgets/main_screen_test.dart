import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blockblast_flutter/main.dart';
import 'package:blockblast_flutter/models/piece.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Best score should be loaded and displayed', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'high_score': 77,
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Best: 77'), findsOneWidget);
  });

  testWidgets('Score should be displayed and update', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // Initially score is 0
    expect(find.text('Score: 0'), findsOneWidget);

    // Find a piece and drop it to get some score
    final pieceFinder = find.byType(Draggable<Piece>);
    final Draggable<Piece> draggable = tester.widget(pieceFinder.first);
    final Piece piece = draggable.data!;

    final gameBoardGridFinder = find.byKey(const Key('game_board_grid'));

    final gesture = await tester.startGesture(
      tester.getCenter(pieceFinder.first),
    );
    // Finger at row 4 + piece.height, col 4
    await gesture.moveTo(
      tester.getTopLeft(gameBoardGridFinder) +
          Offset(160.0, 160.0 + piece.height * 40.0),
    );
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    // Score should be > 0 (at least 1 block * 10 = 10 points)
    expect(find.text('Score: 0'), findsNothing);
    expect(find.textContaining('Score: '), findsOneWidget);
  });
}
