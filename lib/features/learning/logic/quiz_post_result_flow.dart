import '../models/lesson.dart';

/// State machine for quiz result → close → rewarded ad → continue.
enum QuizPostResultPhase {
  resultVisible,
  claimingXp,
  xpClaimed,
  closingResult,
  loadingRewardedAd,
  showingRewardedAd,
  adUnavailable,
  readyToContinue,
  navigatingNext,
}

/// Pure transition rules (testable without Flutter widgets).
class QuizPostResultFlowLogic {
  QuizPostResultFlowLogic._();

  static bool canClaimXp({
    required QuizPostResultPhase phase,
    required bool passed,
    required bool xpAlreadyClaimedThisSession,
  }) {
    if (!passed) return false;
    if (xpAlreadyClaimedThisSession) return false;
    return phase == QuizPostResultPhase.resultVisible ||
        phase == QuizPostResultPhase.xpClaimed;
  }

  static QuizPostResultPhase beginClaimXp(QuizPostResultPhase phase) {
    return QuizPostResultPhase.claimingXp;
  }

  static QuizPostResultPhase afterXpClaimed() =>
      QuizPostResultPhase.xpClaimed;

  /// Close after a passed quiz with XP handled starts the ad gate.
  static QuizPostResultPhase beginCloseAfterPass({
    required bool passed,
    required bool xpHandled,
    required QuizPostResultPhase phase,
  }) {
    if (!passed) return phase;
    if (!xpHandled) return phase;
    if (phase == QuizPostResultPhase.closingResult ||
        phase.index >= QuizPostResultPhase.loadingRewardedAd.index) {
      return phase;
    }
    return QuizPostResultPhase.closingResult;
  }

  static QuizPostResultPhase afterResultClosed() =>
      QuizPostResultPhase.loadingRewardedAd;

  static QuizPostResultPhase afterAdLoadStarted() =>
      QuizPostResultPhase.loadingRewardedAd;

  static QuizPostResultPhase adNowShowing() =>
      QuizPostResultPhase.showingRewardedAd;

  static QuizPostResultPhase afterAdFlowResolved({
    required bool adWasShown,
  }) {
    if (adWasShown) return QuizPostResultPhase.readyToContinue;
    return QuizPostResultPhase.adUnavailable;
  }

  static QuizPostResultPhase readyForContinue() =>
      QuizPostResultPhase.readyToContinue;

  static QuizPostResultPhase beginNavigate() =>
      QuizPostResultPhase.navigatingNext;

  static bool shouldShowNextButton(QuizPostResultPhase phase) {
    return phase == QuizPostResultPhase.readyToContinue ||
        phase == QuizPostResultPhase.adUnavailable;
  }

  static bool shouldRunRewardedAd(QuizPostResultPhase phase) {
    return phase == QuizPostResultPhase.loadingRewardedAd ||
        phase == QuizPostResultPhase.showingRewardedAd;
  }

  static String nextButtonLabel({required Lesson? nextLesson}) {
    if (nextLesson == null) return 'Back to Roadmap';
    return 'Next Lesson →';
  }
}
