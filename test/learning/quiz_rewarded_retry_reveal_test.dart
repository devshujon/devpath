import 'package:devpath/core/ads/rewarded_ad_coordinator.dart';
import 'package:devpath/core/ads/rewarded_ad_purpose.dart';
import 'package:devpath/features/learning/providers/learning_progress_provider.dart';
import 'package:devpath/features/learning/screens/lesson_detail_screen.dart';
import 'package:devpath/features/learning/screens/lesson_quiz_screen.dart';
import 'package:devpath/features/learning/services/learning_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _PurposeMockGateway implements RewardedAdGateway {
  _PurposeMockGateway({
    this.retryOutcome = RewardedAdFlowResult.rewardGranted,
    RewardedAdFlowResult? revealOutcome,
  }) : revealOutcome = revealOutcome ?? RewardedAdFlowResult.rewardGranted;

  RewardedAdFlowResult retryOutcome;
  final RewardedAdFlowResult revealOutcome;
  final List<RewardedAdPurpose> calls = [];

  @override
  Future<RewardedAdFlowResult> showRewardedAd({
    required RewardedAdPurpose purpose,
    VoidCallback? onAdShowing,
  }) async {
    calls.add(purpose);
    onAdShowing?.call();
    return switch (purpose) {
      RewardedAdPurpose.quizExtraAttempt => retryOutcome,
      RewardedAdPurpose.answerReveal => revealOutcome,
      _ => RewardedAdFlowResult.unavailable,
    };
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    RewardedAdCoordinator.debugGatewayOverride = null;
  });

  Future<void> pumpH1(WidgetTester tester, LearningProgressProvider learning) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<LearningProgressProvider>.value(
        value: learning,
        child: const MaterialApp(
          home: SizedBox.expand(
            child: LessonQuizScreen(
              initialArgs: LessonDetailArguments(lessonId: 'h1_heading'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> submitWrongQ1(WidgetTester tester) async {
    await tester.tap(find.text('<h6>'));
    await tester.pump();
    await tester.tap(find.text('Check answer'));
    await tester.pump();
  }

  testWidgets('incorrect answer shows free restart and ad actions', (tester) async {
    RewardedAdCoordinator.debugGatewayOverride = _PurposeMockGateway();
    await pumpH1(tester, LearningProgressProvider.test(LearningProgressData.empty));
    await submitWrongQ1(tester);
    expect(find.text('Not quite — try a different approach'), findsOneWidget);
    expect(find.text('Try Again — free'), findsOneWidget);
    expect(find.text('Watch ad for another attempt'), findsOneWidget);
  });

  testWidgets('free restart returns to question 1', (tester) async {
    RewardedAdCoordinator.debugGatewayOverride = _PurposeMockGateway();
    await pumpH1(tester, LearningProgressProvider.test(LearningProgressData.empty));
    await submitWrongQ1(tester);
    await tester.tap(find.text('Try Again — free'));
    await tester.pump();
    expect(find.textContaining('Question 1 of'), findsOneWidget);
    expect(find.text('Not quite — try a different approach'), findsNothing);
  });

  testWidgets('rewarded retry grants only after reward callback', (tester) async {
    final mock = _PurposeMockGateway(
      retryOutcome: RewardedAdFlowResult.dismissedWithoutReward,
    );
    RewardedAdCoordinator.debugGatewayOverride = mock;
    await pumpH1(tester, LearningProgressProvider.test(LearningProgressData.empty));
    await submitWrongQ1(tester);
    await tester.tap(find.text('Watch ad for another attempt'));
    await tester.pump();
    expect(mock.calls, [RewardedAdPurpose.quizExtraAttempt]);
    expect(find.text('Not quite — try a different approach'), findsOneWidget);
    expect(find.textContaining('Question 1 of'), findsOneWidget);
  });

  testWidgets('rewarded retry resets quiz after reward', (tester) async {
    final mock = _PurposeMockGateway();
    RewardedAdCoordinator.debugGatewayOverride = mock;
    await pumpH1(tester, LearningProgressProvider.test(LearningProgressData.empty));
    await submitWrongQ1(tester);
    await tester.tap(find.text('Watch ad for another attempt'));
    await tester.pump();
    expect(find.text('Not quite — try a different approach'), findsNothing);
    expect(find.textContaining('Question 1 of'), findsOneWidget);
  });

  testWidgets('answer reveal before submit uses separate purpose', (tester) async {
    final mock = _PurposeMockGateway();
    RewardedAdCoordinator.debugGatewayOverride = mock;
    await pumpH1(tester, LearningProgressProvider.test(LearningProgressData.empty));
    await tester.tap(find.text('Reveal answer — watch ad').first);
    await tester.pump();
    expect(mock.calls, [RewardedAdPurpose.answerReveal]);
    expect(find.text('Answer revealed'), findsOneWidget);
    expect(find.textContaining('Correct answer:'), findsOneWidget);
  });

  testWidgets('reveal after incorrect does not grant retry purpose', (tester) async {
    final mock = _PurposeMockGateway();
    RewardedAdCoordinator.debugGatewayOverride = mock;
    await pumpH1(tester, LearningProgressProvider.test(LearningProgressData.empty));
    await submitWrongQ1(tester);
    await tester.tap(find.text('Reveal answer — watch ad'));
    await tester.pump();
    expect(mock.calls, [RewardedAdPurpose.answerReveal]);
    expect(mock.calls.contains(RewardedAdPurpose.quizExtraAttempt), isFalse);
  });

  testWidgets('XP unchanged after failed attempts', (tester) async {
    RewardedAdCoordinator.debugGatewayOverride = _PurposeMockGateway();
    final learning = LearningProgressProvider.test(LearningProgressData.empty);
    await pumpH1(tester, learning);
    await submitWrongQ1(tester);
    await tester.tap(find.text('Try Again — free'));
    await tester.pump();
    expect(learning.completedLessons, isEmpty);
    expect(learning.currentXP, 0);
  });
}
