import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blockblast_flutter/widgets/block_widget.dart'; // Assuming BlockWidget is here
import 'package:blockblast_flutter/models/block.dart'; // Assuming Block model is here

void main() {
  group('BlockWidget', () {
    testWidgets('should render a colored square for a block', (WidgetTester tester) async {
      const blockColor = 0xFF00FF00; // Green
      const block = Block(color: blockColor);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BlockWidget(block: block, size: 40.0),
            ),
          ),
        ),
      );

      // Expect to find a Container with the specified color
      expect(find.byType(Container), findsOneWidget);
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Color(blockColor));
      expect(container.constraints?.maxWidth, 40.0);
      expect(container.constraints?.maxHeight, 40.0);
    });
  });
}
