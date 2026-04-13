import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blockblast_flutter/main.dart'; // Assuming main.dart contains MyApp

void main() {
  group('GameBoardGrid', () {
    testWidgets('should render an 8x8 grid', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp()); // Render the app

      // Expect to find a widget that represents the 8x8 grid
      // This test will fail until GameBoardGrid is implemented
      expect(find.byKey(const Key('game_board_grid')), findsOneWidget);
    });
  });
}
