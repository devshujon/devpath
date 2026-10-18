import 'package:devpath/core/ads/rewarded_ad_coordinator.dart';
import 'package:devpath/core/ads/rewarded_ad_purpose.dart';
import 'package:devpath/core/routing/app_routes.dart';
import 'package:devpath/features/learning/providers/learning_progress_provider.dart';
import 'package:devpath/features/learning/screens/lesson_detail_screen.dart';
import 'package:devpath/features/learning/screens/lesson_quiz_screen.dart';
import 'package:devpath/features/learning/services/learning_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _MockRewardedGateway implements RewardedAdGateway {
  _MockRewardedGateway(this.result);

  final RewardedAdFlowResult result;
  var showCount = 0;

  @override
  Future<RewardedAdFlowResult> showRewardedAd({
    required RewardedAdPurpose purpose,
    VoidCallback? onAdShowing,
  }) async {
    showCount++;
    onAdShowing?.call();
    return result;
  }
}

Future<void> providerCompleteAgain(
  LearningProgressProvider learning,
  String lessonId,
) async {
  final xpBefore = learning.currentXP;
  await learning.completeLesson(lessonId);
  expect(learning.currentXP, xpBefore);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    RewardedAdCoordinator.debugGatewayOverride = null;
  });

  Future<void> pumpQuiz(WidgetTester tester, LearningProgressProvider learning) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<LearningProgressProvider>.value(
        value: learning,
        child: MaterialApp(
          initialRoute: AppRoutes.lessonQuiz,
          routes: {
            AppRoutes.lessonQuiz: (_) => const SizedBox.expand(
                  child: LessonQuizScreen(
                    initialArgs: LessonDetailArguments(lessonId: 'h1_heading'),
                  ),
                ),
            AppRoutes.lessonDetail: (_) => const LessonDetailScreen(),
            AppRoutes.roadmap: (_) =>
                const Scaffold(body: Center(child: Text('Roadmap'))),
            AppRoutes.shell: (_) =>
                const Scaffold(body: Center(child: Text('Shell'))),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> dismissXpOverlay(WidgetTester tester) async {
    for (var i = 0; i < 30; i++) {
      if (find.text('Done').evaluate().isNotEmpty) {
        await tester.tap(find.text('Done'));
        await tester.pump();
        return;
      }
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    int maxPumps = 40,
  }) async {
    for (var i = 0; i < maxPumps; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (finder.evaluate().isNotEmpty) return;
    }
  }

  Future<void> continueIfIncorrect(WidgetTester tester) async {
    if (find.text('Continue quiz').evaluate().isNotEmpty) {
      await tester.tap(find.text('Continue quiz'));
      await tester.pump();
    }
  }

  Future<void> passH1Quiz(WidgetTester tester) async {
    const answers = [
      '<h1>',
      'To give the page machine-readable structure',
      'One',
      'It breaks the document outline for assistive tech',
      'Naming the main topic of that specific page',
    ];
    for (var q = 0; q < 5; q++) {
      await tester.tap(find.text(answers[q]));
      await tester.pump();
      await tester.tap(find.text(q == 4 ? 'Finish' : 'Check answer'));
      await tester.pump();
      await continueIfIncorrect(tester);
    }
    await pumpUntilFound(
      tester,
      find.byWidgetPredicate(
        (w) =>
            w is Text &&
            (w.data == 'Excellent Work!' ||
                w.data == 'Quiz Completed!' ||
                w.data == 'Keep Practicing!'),
      ),
    );
  }

  testWidgets('perfect score shows redesigned pass copy and score card', (tester) async {
    RewardedAdCoordinator.debugGatewayOverride =
        _MockRewardedGateway(RewardedAdFlowResult.unavailable);
    final learning = LearningProgressProvider.test(LearningProgressData.empty);
    await pumpQuiz(tester, learning);
    await passH1Quiz(tester);

    expect(find.text('Excellent Work!'), findsOneWidget);
    expect(find.text('5 / 5 correct'), findsOneWidget);
    expect(find.text('100% accuracy'), findsOneWidget);
  });

  testWidgets('XP claimed exactly once on repeated taps', (tester) async {
    RewardedAdCoordinator.debugGatewayOverride =
        _MockRewardedGateway(RewardedAdFlowResult.unavailable);
    final learning = LearningProgressProvider.test(LearningProgressData.empty);
    await pumpQuiz(tester, learning);
    await passH1Quiz(tester);
    expect(find.text('Claim 50 XP'), findsOneWidget);

    await tester.tap(find.text('Claim 50 XP'));
    await dismissXpOverlay(tester);
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (learning.currentXP == 50) break;
    }

    expect(learning.completedLessons, contains('h1_heading'));
    expect(learning.currentXP, 50);
    // Idempotent — provider ignores a second completion.
    await providerCompleteAgain(learning, 'h1_heading');
    expect(learning.currentXP, 50);
  });

  testWidgets('close after claim runs ad once then shows Next Lesson', (tester) async {
    final mock = _MockRewardedGateway(RewardedAdFlowResult.dismissedWithoutReward);
    RewardedAdCoordinator.debugGatewayOverride = mock;
    final learning = LearningProgressProvider.test(LearningProgressData.empty);
    await pumpQuiz(tester, learning);
    await passH1Quiz(tester);

    await tester.tap(find.text('Claim 50 XP'));
    await tester.pump();
    await dismissXpOverlay(tester);

    await tester.tap(find.text('Close'));
    await pumpUntilFound(tester, find.text('Next Lesson →'));

    expect(mock.showCount, 1);
    expect(find.text('Next Lesson →'), findsOneWidget);
    expect(find.text('Excellent Work!'), findsNothing);
  });

  testWidgets('ad unavailable shows fallback and Next without trapping', (tester) async {
    RewardedAdCoordinator.debugGatewayOverride =
        _MockRewardedGateway(RewardedAdFlowResult.unavailable);
    final learning = LearningProgressProvider.test(LearningProgressData.empty);
    await pumpQuiz(tester, learning);
    await passH1Quiz(tester);

    await tester.tap(find.text('Claim 50 XP'));
    await tester.pump();
    await dismissXpOverlay(tester);
    await tester.tap(find.text('Close'));
    await pumpUntilFound(tester, find.text('Next Lesson →'));

    expect(
      find.text('No ad available right now. You can continue learning.'),
      findsOneWidget,
    );
    expect(find.text('Next Lesson →'), findsOneWidget);
  });

  testWidgets('failed quiz shows keep practicing without pass celebration', (tester) async {
    RewardedAdCoordinator.debugGatewayOverride =
        _MockRewardedGateway(RewardedAdFlowResult.unavailable);
    final learning = LearningProgressProvider.test(LearningProgressData.empty);
    await pumpQuiz(tester, learning);

    const wrongAnswers = [
      '<h6>',
      'Only to make text look bigger',
      'As many as look like titles',
      'It makes CSS stop working',
      'Repeating the site logo text on every page',
    ];
    for (var q = 0; q < 5; q++) {
      await tester.tap(find.text(wrongAnswers[q]));
      await tester.pump();
      await tester.tap(find.text(q == 4 ? 'Finish' : 'Check answer'));
      await tester.pump();
      await continueIfIncorrect(tester);
    }

    expect(find.text('Keep Practicing!'), findsOneWidget);
    expect(find.text('Excellent Work!'), findsNothing);
    expect(find.text('Not passed'), findsOneWidget);
    expect(learning.completedLessons, isEmpty);
  });

  testWidgets('partial passing score shows quiz completed', (tester) async {
    RewardedAdCoordinator.debugGatewayOverride =
        _MockRewardedGateway(RewardedAdFlowResult.unavailable);
    final learning = LearningProgressProvider.test(LearningProgressData.empty);
    await pumpQuiz(tester, learning);

    const answers = [
      '<h1>',
      'To give the page machine-readable structure',
      'One',
      'It makes CSS stop working',
      'Naming the main topic of that specific page',
    ];
    for (var q = 0; q < 5; q++) {
      await tester.tap(find.text(answers[q]));
      await tester.pump();
      await tester.tap(find.text(q == 4 ? 'Finish' : 'Check answer'));
      await tester.pump();
      await continueIfIncorrect(tester);
    }

    expect(find.text('Quiz Completed!'), findsOneWidget);
    expect(find.text('4 / 5 correct'), findsOneWidget);
  });

  testWidgets('repeated close does not trigger duplicate ads', (tester) async {
    final mock = _MockRewardedGateway(RewardedAdFlowResult.unavailable);
    RewardedAdCoordinator.debugGatewayOverride = mock;
    final learning = LearningProgressProvider.test(LearningProgressData.empty);
    await pumpQuiz(tester, learning);
    await passH1Quiz(tester);
    await tester.tap(find.text('Claim 50 XP'));
    await tester.pump();
    await dismissXpOverlay(tester);
    await tester.tap(find.text('Close'));
    await pumpUntilFound(tester, find.text('Next Lesson →'));
    expect(mock.showCount, 1);
  });
}
