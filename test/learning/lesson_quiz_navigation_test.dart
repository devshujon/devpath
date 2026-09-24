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

  Future<void> pumpLessonDetail(
    WidgetTester tester, {
    required String lessonId,
    LearningProgressData progress = LearningProgressData.empty,
  }) async {
    final learning = LearningProgressProvider.test(progress);
    await tester.pumpWidget(
      ChangeNotifierProvider<LearningProgressProvider>.value(
        value: learning,
        child: MaterialApp(
          navigatorObservers: [appRouteObserver],
          routes: {
            AppRoutes.lessonQuiz: (_) => const LessonQuizScreen(),
          },
          home: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              settings: RouteSettings(
                name: AppRoutes.lessonDetail,
                arguments: LessonDetailArguments(lessonId: lessonId),
              ),
              builder: (_) => const LessonDetailScreen(),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Take Quiz opens lesson quiz for h1_heading', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpLessonDetail(tester, lessonId: 'h1_heading');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('Take Quiz'), findsOneWidget);
    await tester.tap(find.text('Take Quiz'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Question 1'), findsOneWidget);
    expect(find.text('The H1 Heading'), findsWidgets);
    expect(
      find.text('Which tag marks the most important heading on a page?'),
      findsOneWidget,
    );
    expect(find.text('<h1>'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Take Quiz opens lesson quiz for b01_html when unlocked', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpLessonDetail(
      tester,
      lessonId: 'b01_html',
      progress: const LearningProgressData(completedLessons: {'h1_heading'}),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('Take Quiz'), findsOneWidget);
    await tester.tap(find.text('Take Quiz'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Question 1'), findsOneWidget);
    expect(find.text('HTML Basics'), findsWidgets);
  });
}
