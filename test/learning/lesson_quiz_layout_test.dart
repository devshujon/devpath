import 'package:devpath/features/learning/providers/learning_progress_provider.dart';
import 'package:devpath/features/learning/screens/lesson_detail_screen.dart';
import 'package:devpath/features/learning/screens/lesson_quiz_screen.dart';
import 'package:devpath/features/learning/services/learning_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('quiz question view does not overflow at 360x640', (tester) async {
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
                  builder: (_) => const LessonQuizScreen(),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Question 1'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });
}
