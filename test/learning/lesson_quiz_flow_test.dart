import 'package:devpath/core/routing/app_route_observer.dart';
import 'package:devpath/core/routing/app_routes.dart';
import 'package:devpath/features/learning/providers/learning_progress_provider.dart';
import 'package:devpath/features/learning/screens/lesson_detail_screen.dart';
import 'package:devpath/features/learning/screens/lesson_quiz_screen.dart';
import 'package:devpath/features/learning/services/learning_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpQuizApp(WidgetTester tester) async {
    final learning = LearningProgressProvider.test(LearningProgressData.empty);
    await tester.pumpWidget(
      ChangeNotifierProvider<LearningProgressProvider>.value(
        value: learning,
        child: MaterialApp(
          navigatorObservers: [appRouteObserver],
          initialRoute: AppRoutes.shell,
          routes: {
            AppRoutes.shell: (_) =>
                const Scaffold(body: Center(child: Text('Shell'))),
            AppRoutes.lessonDetail: (_) => const LessonDetailScreen(),
            AppRoutes.lessonQuiz: (_) => const SizedBox.expand(
                  child: LessonQuizScreen(),
                ),
          },
        ),
      ),
    );
  }

  Future<void> openH1QuizFromLesson(WidgetTester tester) async {
    await pumpQuizApp(tester);
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.pushNamed(
      AppRoutes.lessonDetail,
      arguments: const LessonDetailArguments(lessonId: 'h1_heading'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take Quiz'));
    await tester.pumpAndSettle();
  }

  testWidgets('H1 quiz Next flow reaches pass result', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await openH1QuizFromLesson(tester);

    const answers = [
      '<h1>',
      'To give the page machine-readable structure',
      'One',
      'It breaks the document outline for assistive tech',
      'Naming the main topic of that specific page',
    ];

    for (var q = 0; q < 5; q++) {
      expect(find.textContaining('Question ${q + 1}'), findsOneWidget);
      await tester.tap(find.text(answers[q]));
      await tester.pumpAndSettle();
      await tester.tap(find.text(q == 4 ? 'Finish' : 'Next'));
      await tester.pumpAndSettle();
    }

    expect(find.text('You passed!'), findsOneWidget);
    expect(find.text('5 of 5 correct'), findsOneWidget);
  });

  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets('quiz readable at ${width.toInt()}dp width', (tester) async {
      tester.view.physicalSize = Size(width, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await openH1QuizFromLesson(tester);
      expect(tester.takeException(), isNull);
      expect(
        find.text('Which tag marks the most important heading on a page?'),
        findsOneWidget,
      );
      expect(find.text('Next'), findsOneWidget);
    });
  }
}
