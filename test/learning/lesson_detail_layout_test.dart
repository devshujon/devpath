import 'package:devpath/features/learn/widgets/lesson_path_node.dart';
import 'package:devpath/features/learning/data/lessons_catalog.dart';
import 'package:devpath/features/learning/providers/learning_progress_provider.dart';
import 'package:devpath/features/learning/screens/lesson_detail_screen.dart';
import 'package:devpath/features/learning/services/learning_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('completed lesson node is not drawn as locked', (tester) async {
    final lesson = LessonsCatalog.byId('b01_html')!.copyWith(
      isLocked: true,
      isCompleted: true,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LessonPathNode(lesson: lesson, isCurrent: true),
        ),
      ),
    );
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsNothing);
  });

  testWidgets('h1 lesson detail loads at 360x640 without overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final learning = LearningProgressProvider.test(LearningProgressData.empty);

    await tester.pumpWidget(
      ChangeNotifierProvider<LearningProgressProvider>.value(
        value: learning,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Navigator(
                onGenerateRoute: (_) => MaterialPageRoute(
                  settings: const RouteSettings(
                    arguments: LessonDetailArguments(lessonId: 'h1_heading'),
                  ),
                  builder: (_) => const LessonDetailScreen(),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(tester.takeException(), isNull);
    expect(find.textContaining('H1'), findsWidgets);
  });

  testWidgets('completed lesson continue CTA does not overflow at 360dp', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final learning = LearningProgressProvider.test(
      const LearningProgressData(completedLessons: {'h1_heading'}, currentXP: 50),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<LearningProgressProvider>.value(
        value: learning,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Navigator(
                onGenerateRoute: (_) => MaterialPageRoute(
                  settings: const RouteSettings(
                    arguments: LessonDetailArguments(lessonId: 'h1_heading'),
                  ),
                  builder: (_) => const LessonDetailScreen(),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(tester.takeException(), isNull);
    expect(find.text('Completed'), findsOneWidget);

    final scrollable = find.descendant(
      of: find.byType(CustomScrollView),
      matching: find.byType(Scrollable),
    );
    for (var i = 0; i < 24; i++) {
      final position = tester.state<ScrollableState>(scrollable).position;
      position.jumpTo(position.maxScrollExtent);
      await tester.pump();
      if (find.text('Lesson complete').evaluate().isNotEmpty) break;
    }

    expect(tester.takeException(), isNull);
    expect(find.text('Lesson complete'), findsOneWidget);
    expect(find.textContaining('Continue to'), findsOneWidget);
  });
}
