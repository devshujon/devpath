import 'package:devpath/core/routing/app_route_observer.dart';
import 'package:devpath/core/routing/app_routes.dart';
import 'package:devpath/features/learning/providers/learning_progress_provider.dart';
import 'package:devpath/features/learning/screens/lesson_detail_screen.dart';
import 'package:devpath/features/learning/screens/lesson_quiz_screen.dart';
import 'package:devpath/features/learning/services/learning_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Regression: stale platform-view routes (Code Editor, Playground) on the
/// root navigator must be cleared when opening the lesson quiz.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpRootNavigatorApp(WidgetTester tester) async {
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
            AppRoutes.codeEditor: (_) => const Scaffold(
                  body: Center(child: Text('Code Editor route')),
                ),
            AppRoutes.lessonDetail: (_) => const LessonDetailScreen(),
            AppRoutes.lessonQuiz: (_) => const SizedBox.expand(
                  child: LessonQuizScreen(),
                ),
          },
        ),
      ),
    );
  }

  testWidgets('H1 quiz shows question after stale code-editor route cleared',
      (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpRootNavigatorApp(tester);
    final nav = tester.state<NavigatorState>(find.byType(Navigator));

    nav.pushNamed(AppRoutes.codeEditor);
    await tester.pumpAndSettle();
    nav.pushNamed(
      AppRoutes.lessonDetail,
      arguments: const LessonDetailArguments(lessonId: 'h1_heading'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Take Quiz'), findsOneWidget);
    await tester.tap(find.text('Take Quiz'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Question 1'), findsOneWidget);
    expect(
      find.text('Which tag marks the most important heading on a page?'),
      findsOneWidget,
    );
    expect(find.text('<h1>'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Code Editor route'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Take Quiz'), findsOneWidget);
  });

  testWidgets('reopening H1 quiz twice still shows options', (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpRootNavigatorApp(tester);
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.pushNamed(
      AppRoutes.lessonDetail,
      arguments: const LessonDetailArguments(lessonId: 'h1_heading'),
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Take Quiz'));
      await tester.pumpAndSettle();
      expect(find.text('<h1>'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('quiz shows retry UI when arguments missing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [appRouteObserver],
        home: const SizedBox.expand(child: LessonQuizScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Quiz could not start'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });
}
