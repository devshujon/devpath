import 'package:devpath/features/curriculum/models/lesson_block.dart';
import 'package:devpath/features/curriculum/widgets/lesson_blocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('syntax breakdown does not overflow at 360dp', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const block = SyntaxBreakdownBlock(
      lang: 'html',
      code: '<img src="data:image/svg+xml,placeholder" alt="wide-fragment">',
      parts: [
        SyntaxPart(
          'src="data:image/svg+xml,placeholder-that-is-very-long"',
          'Offline image source',
        ),
        SyntaxPart('alt="wide-fragment"', 'Accessible name'),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: SyntaxBreakdownBlockView(block, Color(0xFFE17055)),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Offline image source'), findsOneWidget);
  });
}
