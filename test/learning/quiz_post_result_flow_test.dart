import 'package:devpath/features/learning/logic/quiz_post_result_flow.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuizPostResultFlowLogic', () {
    test('XP claim allowed only when passed and not yet claimed', () {
      expect(
        QuizPostResultFlowLogic.canClaimXp(
          phase: QuizPostResultPhase.resultVisible,
          passed: true,
          xpAlreadyClaimedThisSession: false,
        ),
        isTrue,
      );
      expect(
        QuizPostResultFlowLogic.canClaimXp(
          phase: QuizPostResultPhase.resultVisible,
          passed: false,
          xpAlreadyClaimedThisSession: false,
        ),
        isFalse,
      );
      expect(
        QuizPostResultFlowLogic.canClaimXp(
          phase: QuizPostResultPhase.resultVisible,
          passed: true,
          xpAlreadyClaimedThisSession: true,
        ),
        isFalse,
      );
    });

    test('close after pass with XP handled enters ad loading', () {
      final phase = QuizPostResultFlowLogic.beginCloseAfterPass(
        passed: true,
        xpHandled: true,
        phase: QuizPostResultPhase.xpClaimed,
      );
      expect(phase, QuizPostResultPhase.closingResult);
      expect(
        QuizPostResultFlowLogic.afterResultClosed(),
        QuizPostResultPhase.loadingRewardedAd,
      );
    });

    test('failed close does not advance phase', () {
      final phase = QuizPostResultFlowLogic.beginCloseAfterPass(
        passed: false,
        xpHandled: true,
        phase: QuizPostResultPhase.resultVisible,
      );
      expect(phase, QuizPostResultPhase.resultVisible);
    });

    test('next button after ad shown or unavailable', () {
      expect(
        QuizPostResultFlowLogic.shouldShowNextButton(
          QuizPostResultPhase.readyToContinue,
        ),
        isTrue,
      );
      expect(
        QuizPostResultFlowLogic.shouldShowNextButton(
          QuizPostResultPhase.adUnavailable,
        ),
        isTrue,
      );
      expect(
        QuizPostResultFlowLogic.shouldShowNextButton(
          QuizPostResultPhase.loadingRewardedAd,
        ),
        isFalse,
      );
    });

    test('next button labels', () {
      expect(
        QuizPostResultFlowLogic.nextButtonLabel(nextLesson: null),
        'Back to Roadmap',
      );
    });
  });
}
