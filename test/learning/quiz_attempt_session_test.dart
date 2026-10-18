import 'package:devpath/features/learning/logic/quiz_attempt_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('restart clears answers and increments attempt', () {
    final s = QuizAttemptSession(
      questionIndex: 3,
      answers: {0: 1, 1: 2},
      revealedQuestionIndexes: {2},
      attemptNumber: 2,
    );
    final next = s.restartFromBeginning(countRewardedRetry: false);
    expect(next.questionIndex, 0);
    expect(next.answers, isEmpty);
    expect(next.revealedQuestionIndexes, isEmpty);
    expect(next.attemptNumber, 3);
    expect(next.rewardedRetriesUsed, 0);
  });

  test('rewarded retry increments counter only when granted path sets flag', () {
    final s = QuizAttemptSession(rewardedRetriesUsed: 1);
    final next = s.restartFromBeginning(countRewardedRetry: true);
    expect(next.rewardedRetriesUsed, 2);
  });

  test('score uses stored answers only', () {
    final s = QuizAttemptSession(answers: {0: 0, 1: 3});
    expect(s.scoreCorrect([0, 1]), 1);
  });
}
