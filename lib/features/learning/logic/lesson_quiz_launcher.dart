import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/debug/quiz_diagnostics.dart';
import '../../../core/platform/active_webview_tracker.dart';
import '../../../core/platform/android_native_webview_cleanup.dart';
import '../../../core/platform/platform_view_gate.dart';
import '../../../core/routing/app_routes.dart';
import '../screens/lesson_quiz_screen.dart';

/// Opens [LessonQuizScreen] without leaving stale platform-view routes
/// (Playground, Code Editor, etc.) under the quiz on the root navigator.
Future<void> openLessonQuiz(
  BuildContext context, {
  required LessonDetailArguments args,
}) async {
  final rootNav = Navigator.of(context, rootNavigator: true);
  final navContext = rootNav.context;

  QuizDiagnostics.log(
    'Take Quiz pressed lessonId=${args.lessonId} '
    'gateSuspended=${PlatformViewGate.instance.isSuspended}',
  );

  await PlatformViewGate.instance.runSuspended(() async {
    if (!navContext.mounted) {
      QuizDiagnostics.log('Abort: root navigator context unmounted');
      return;
    }

    await ActiveWebViewTracker.instance.detachAll();
    await AndroidNativeWebViewCleanup.removeStaleWebViews();
    await AndroidNativeWebViewCleanup.bringFlutterSurfaceToFront();
    await PlatformViewGate.waitForNativeTeardown(frames: 4);

    QuizDiagnostics.log('popUntil shell to drop stale platform-view routes');
    rootNav.popUntil((route) {
      final name = route.settings.name;
      final keep = route.isFirst || name == AppRoutes.shell;
      if (!keep && kDebugMode) {
        QuizDiagnostics.log('popUntil removing route name=$name');
      }
      return keep;
    });

    await AndroidNativeWebViewCleanup.removeStaleWebViews();
    await AndroidNativeWebViewCleanup.bringFlutterSurfaceToFront();
    await PlatformViewGate.waitForNativeTeardown(frames: 8);

    if (!navContext.mounted) {
      QuizDiagnostics.log('Abort: navigator unmounted after popUntil');
      return;
    }

    QuizDiagnostics.log('Pushing full-screen lesson quiz');

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

    QuizDiagnostics.log('Quiz closed; restoring lesson detail');

    if (rootNav.mounted) {
      await rootNav.pushNamed<void>(
        AppRoutes.lessonDetail,
        arguments: args,
      );
    }
  });

  QuizDiagnostics.log('Quiz session finished lessonId=${args.lessonId}');
}
