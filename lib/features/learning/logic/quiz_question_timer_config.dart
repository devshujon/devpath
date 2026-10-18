/// Single place to configure per-question countdown duration.
class QuizQuestionTimerConfig {
  QuizQuestionTimerConfig._();

  /// Default: 30 seconds per question. Tests may override temporarily.
  static Duration perQuestionDuration = const Duration(seconds: 30);
}
