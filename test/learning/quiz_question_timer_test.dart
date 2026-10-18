import 'package:devpath/features/learning/logic/quiz_question_timer.dart';
import 'package:devpath/features/learning/logic/quiz_question_timer_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('remaining never goes negative and expiry fires once', () {
    var expiredCount = 0;
    final timer = QuizQuestionTimer(
      duration: const Duration(milliseconds: 500),
      tickInterval: const Duration(milliseconds: 100),
      onExpired: () => expiredCount++,
    );
    timer.start();
    expect(timer.remaining().inMilliseconds, 500);
    timer.debugFireExpiryForTests();
    expect(timer.remaining(), Duration.zero);
    expect(expiredCount, 1);
    timer.dispose();
  });

  test('stop prevents expiry callback', () {
    var expired = false;
    final timer = QuizQuestionTimer(
      duration: const Duration(milliseconds: 500),
      onExpired: () => expired = true,
    );
    timer.start();
    timer.stop();
    expect(timer.isRunning, isFalse);
    expect(expired, isFalse);
  });

  test('pause stops countdown until resume', () async {
    final timer = QuizQuestionTimer(
      duration: const Duration(milliseconds: 1000),
      tickInterval: const Duration(milliseconds: 200),
    );
    timer.start();
    await Future<void>.delayed(const Duration(milliseconds: 450));
    timer.pause();
    final leftAtPause = timer.remaining().inMilliseconds;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    expect(timer.remaining().inMilliseconds, leftAtPause);
    timer.resume();
    expect(timer.isRunning, isTrue);
    timer.dispose();
  });

  test('config default is 30 seconds', () {
    expect(
      QuizQuestionTimerConfig.perQuestionDuration,
      const Duration(seconds: 30),
    );
  });
}
