import 'package:flutter/foundation.dart';

/// Debug logging for the lesson-quiz blank-screen investigation on Android.
abstract final class QuizDiagnostics {
  static void log(String message) {
    if (kDebugMode) {
      debugPrint('[QuizDiagnostics] $message');
    }
  }
}
