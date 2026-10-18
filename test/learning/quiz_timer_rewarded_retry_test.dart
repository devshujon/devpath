import 'package:devpath/core/ads/rewarded_ad_coordinator.dart';
import 'package:devpath/core/ads/rewarded_ad_purpose.dart';
import 'package:devpath/features/learning/logic/quiz_question_timer_config.dart';
import 'package:devpath/features/learning/providers/learning_progress_provider.dart';
import 'package:devpath/features/learning/screens/lesson_detail_screen.dart';
import 'package:devpath/features/learning/screens/lesson_quiz_screen.dart';
import 'package:devpath/features/learning/services/learning_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _TimerMockGateway implements RewardedAdGateway {
  _TimerMockGateway(this.outcome);

  final RewardedAdFlowResult outcome;
  RewardedAdPurpose? lastPurpose;

  @override
  Future<RewardedAdFlowResult> showRewardedAd({
    required RewardedAdPurpose purpose,
    VoidCallback? onAdShowing,
  }) async {
    lastPurpose = purpose;
    return outcome;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    RewardedAdCoordinator.debugGatewayOverride = null;
    QuizQuestionTimerConfig.perQuestionDuration = const Duration(seconds: 30);
  });

  Future<void> pumpQuiz(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<LearningProgressProvider>.value(
        value: LearningProgressProvider.test(LearningProgressData.empty),
        child: const MaterialApp(
          home: SizedBox.expand(
            child: LessonQuizScreen(
              initialArgs: LessonDetailArguments(lessonId: 'h1_heading'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows countdown for active question', (tester) async {
    await pumpQuiz(tester);
    expect(find.textContaining('s left'), findsOneWidget);
  });

  testWidgets('timer expiry shows Time\'s Up without submitting answer', (tester) async {
    QuizQuestionTimerConfig.perQuestionDuration = const Duration(milliseconds: 400);
    await pumpQuiz(tester);
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text("Time's Up!"), findsOneWidget);
    expect(find.text('Watch ad to retry'), findsOneWidget);
  });

  testWidgets('correct answer stops timer and advances', (tester) async {
    QuizQuestionTimerConfig.perQuestionDuration = const Duration(seconds: 5);
    await pumpQuiz(tester);
    await tester.tap(find.text('<h1>'));
    await tester.pump();
    await tester.tap(find.text('Check answer'));
    await tester.pump();
    expect(find.textContaining('Question 2'), findsOneWidget);
    expect(find.text("Time's Up!"), findsNothing);
  });

  testWidgets('rewarded timer retry uses dedicated purpose', (tester) async {
    QuizQuestionTimerConfig.perQuestionDuration = const Duration(milliseconds: 300);
    final mock = _TimerMockGateway(RewardedAdFlowResult.rewardGranted);
    RewardedAdCoordinator.debugGatewayOverride = mock;
    await pumpQuiz(tester);
    await tester.tap(find.text('<h1>'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.tap(find.text('Watch ad to retry'));
    await tester.pump();
    expect(mock.lastPurpose, RewardedAdPurpose.questionTimerRetry);
    expect(find.text("Time's Up!"), findsNothing);
    expect(find.textContaining('s left'), findsOneWidget);
    expect(find.text('<h1>'), findsOneWidget);
  });

  testWidgets('dismissed ad does not restore timer', (tester) async {
    QuizQuestionTimerConfig.perQuestionDuration = const Duration(milliseconds: 300);
    RewardedAdCoordinator.debugGatewayOverride = _TimerMockGateway(
      RewardedAdFlowResult.dismissedWithoutReward,
    );
    await pumpQuiz(tester);
    await tester.pump(const Duration(milliseconds: 900));
    await tester.tap(find.text('Watch ad to retry'));
    await tester.pump();
    expect(find.text("Time's Up!"), findsOneWidget);
  });

  testWidgets('prior answers preserved after timer retry reward', (tester) async {
    QuizQuestionTimerConfig.perQuestionDuration =
        const Duration(milliseconds: 200);
    RewardedAdCoordinator.debugGatewayOverride =
        _TimerMockGateway(RewardedAdFlowResult.rewardGranted);
    await pumpQuiz(tester);
    await tester.tap(find.text('<h1>'));
    await tester.pump();
    await tester.tap(find.text('Check answer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.tap(find.text('Watch ad to retry'));
    await tester.pump();
    await tester.tap(find.text('Back'));
    await tester.pump();
    await tester.tap(find.text('<h1>'));
    await tester.pump();
    expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
  });
}
