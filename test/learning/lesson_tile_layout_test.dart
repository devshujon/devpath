import 'package:devpath/features/learning/data/lessons_catalog.dart';
import 'package:devpath/features/learning/widgets/lesson_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('lesson tile meta wraps at 360dp without overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final lesson = LessonsCatalog.byId('h1_heading')!.copyWith(
      isCompleted: true,
      isLocked: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LessonTile(lesson: lesson, index: 0, onTap: () {}),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.textContaining('min'), findsOneWidget);
    expect(find.textContaining('XP'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
