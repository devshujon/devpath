/// Distinct rewarded placements — rewards must not cross-grant.
enum RewardedAdPurpose {
  /// After quiz result close (navigation gate; no quiz retry/reveal).
  postQuizContinue,

  /// Extra full quiz attempt after an incorrect answer.
  quizExtraAttempt,

  /// Unlock correct option + explanation for one question.
  answerReveal,
}
