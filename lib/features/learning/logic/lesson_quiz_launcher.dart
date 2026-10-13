import 'package:flutter/material.dart';

import '../../../core/debug/quiz_diagnostics.dart';
import '../../../core/platform/active_webview_tracker.dart';
import '../../../core/platform/android_native_webview_cleanup.dart';
import '../../../core/platform/platform_view_gate.dart';
import '../../../core/routing/app_routes.dart';
import '../screens/lesson_quiz_screen.dart';

/// Opens [LessonQuizScreen] on the root navigator after hiding stale WebViews.
Future<void> openLessonQuiz(
  BuildContext context, {
  required LessonDetailArguments args,
}) async {
  final rootNav = Navigator.of(context, rootNavigator: true);

  QuizDiagnostics.log(
    'Take Quiz pressed lessonId=${args.lessonId} '
    'gateSuspended=${PlatformViewGate.instance.isSuspended}',
  );

  // Detach platform views while the shell is suspended — then resume before
  // showing the quiz. Keeping the gate suspended during the quiz left Honor
  // devices on a full black screen (shell shrink + no painted quiz).
  PlatformViewGate.instance.suspend();
  try {
    await ActiveWebViewTracker.instance.detachAll();
    await AndroidNativeWebViewCleanup.hideStaleWebViews();
    await PlatformViewGate.waitForNativeTeardown(frames: 6);
  } finally {
    PlatformViewGate.instance.resume();
  }

  if (!context.mounted) {
    QuizDiagnostics.log('Abort: context unmounted after WebView cleanup');
    return;
  }

  QuizDiagnostics.log('Pushing lesson quiz (lesson route stays under quiz)');

  await rootNav.push<void>(
    MaterialPageRoute<void>(
      settings: RouteSettings(
        name: AppRoutes.lessonQuiz,
        arguments: args,
      ),
      builder: (_) => const SizedBox.expand(
        child: LessonQuizScreen(),
      ),
    ),
  );

  QuizDiagnostics.log('Quiz session finished lessonId=${args.lessonId}');
}
