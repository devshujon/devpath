import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_version.dart';
import '../../../core/debug/quiz_diagnostics.dart';
import '../../../core/platform/android_native_webview_cleanup.dart';
import '../../../core/platform/platform_view_gate.dart';
import '../../../core/routing/app_routes.dart';
import '../providers/learning_progress_provider.dart';
import '../screens/lesson_quiz_screen.dart';

/// Opens [LessonQuizScreen] on the root navigator (full-screen opaque route).
Future<void> openLessonQuiz(
  BuildContext context, {
  required LessonDetailArguments args,
}) async {
  PlatformViewGate.instance.forceOpen();

  QuizDiagnostics.log('Take Quiz lessonId=${args.lessonId}');

  if (!context.mounted) return;

  if (!kIsWeb && Platform.isAndroid) {
    await AndroidNativeWebViewCleanup.hideStaleWebViews();
    await PlatformViewGate.waitForNativeTeardown(frames: 2);
    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text('Opening quiz · v$kAppFullVersionLabel'),
      ),
    );
  }

  final learning = context.read<LearningProgressProvider>();
  final rootNav = Navigator.of(context, rootNavigator: true);

  await rootNav.push<void>(
    PageRouteBuilder<void>(
      opaque: true,
      barrierDismissible: false,
      settings: RouteSettings(
        name: AppRoutes.lessonQuiz,
        arguments: args,
      ),
      pageBuilder: (routeContext, _, __) {
        return ChangeNotifierProvider<LearningProgressProvider>.value(
          value: learning,
          child: LessonQuizScreen(
            initialArgs: args,
            onRequestClose: () {
              if (routeContext.mounted) {
                Navigator.of(routeContext).pop();
              }
            },
          ),
        );
      },
      transitionsBuilder: (_, __, ___, child) => child,
      transitionDuration: Duration.zero,
    ),
  );

  QuizDiagnostics.log('Quiz route closed lessonId=${args.lessonId}');
}
