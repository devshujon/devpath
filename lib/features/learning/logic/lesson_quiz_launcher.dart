import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/debug/quiz_diagnostics.dart';
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
    await PlatformViewGate.waitForNativeTeardown();

    if (!navContext.mounted) {
      QuizDiagnostics.log('Abort: root navigator context unmounted');
      return;
    }

    QuizDiagnostics.log(
      'Pushing quiz with pushAndRemoveUntil (keep shell only)',
    );

    await rootNav.pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(
        settings: RouteSettings(
          name: AppRoutes.lessonQuiz,
          arguments: args,
        ),
        builder: (_) => const SizedBox.expand(
          child: LessonQuizScreen(),
        ),
      ),
      (route) {
        final name = route.settings.name;
        final keep = route.isFirst || name == AppRoutes.shell;
        if (!keep && kDebugMode) {
          QuizDiagnostics.log('Removing route name=$name');
        }
        return keep;
      },
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
