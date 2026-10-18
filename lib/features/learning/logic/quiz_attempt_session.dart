/// Ephemeral quiz attempt state — never persisted; separate from lesson XP.
class QuizAttemptSession {
  QuizAttemptSession({
    this.questionIndex = 0,
    Map<int, int>? answers,
    Set<int>? revealedQuestionIndexes,
    this.attemptNumber = 1,
    this.rewardedRetriesUsed = 0,
    this.rewardedRevealsUsed = 0,
  })  : answers = answers ?? {},
        revealedQuestionIndexes = revealedQuestionIndexes ?? {};

  int questionIndex;
  final Map<int, int> answers;
  final Set<int> revealedQuestionIndexes;
  int attemptNumber;
  int rewardedRetriesUsed;
  int rewardedRevealsUsed;

  bool isRevealed(int questionIndex) =>
      revealedQuestionIndexes.contains(questionIndex);

  void markRevealed(int questionIndex) {
    revealedQuestionIndexes.add(questionIndex);
  }

  /// Free or ad-granted restart from question 1.
  QuizAttemptSession restartFromBeginning({required bool countRewardedRetry}) {
    return QuizAttemptSession(
      questionIndex: 0,
      answers: {},
      revealedQuestionIndexes: {},
      attemptNumber: attemptNumber + 1,
      rewardedRetriesUsed:
          rewardedRetriesUsed + (countRewardedRetry ? 1 : 0),
      rewardedRevealsUsed: rewardedRevealsUsed,
    );
  }

  int scoreCorrect(List<int> correctIndexes) {
    var c = 0;
    for (var i = 0; i < correctIndexes.length; i++) {
      if (answers[i] == correctIndexes[i]) c++;
    }
    return c;
  }
}
