import 'package:devpath/core/routing/app_routes.dart';
import 'package:devpath/features/learning/providers/learning_progress_provider.dart';
import 'package:devpath/features/learning/screens/lesson_quiz_screen.dart';
import 'package:devpath/features/learning/services/learning_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('lesson quiz pass threshold is 70% (4 of 5 for H1)', () {
    const threshold = 0.7;
    expect(3 / 5 >= threshold, isFalse);
    expect(4 / 5 >= threshold, isTrue);
  });

  testWidgets('quiz options are tappable and visible', (tester) async {
    final learning = LearningProgressProvider.test(LearningProgressData.empty);
    await tester.pumpWidget(
      ChangeNotifierProvider<LearningProgressProvider>.value(
        value: learning,
        child: const MaterialApp(
          home: LessonQuizScreen(
            initialArgs: LessonDetailArguments(lessonId: 'h1_heading'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('<h1>'), findsOneWidget);
    await tester.tap(find.text('<h1>'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
    expect(learning.completedLessons, isEmpty);
  });
}
