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

/// Opens [LessonQuizScreen]. Android uses a root fullscreen dialog (Honor-safe).
Future<void> openLessonQuiz(
  BuildContext context, {
  required LessonDetailArguments args,
}) async {
  PlatformViewGate.instance.forceOpen();

  QuizDiagnostics.log('Take Quiz lessonId=${args.lessonId}');

  if (!context.mounted) return;

  final learning = context.read<LearningProgressProvider>();
  final messenger = ScaffoldMessenger.maybeOf(context);

  if (!kIsWeb && Platform.isAndroid) {
    await AndroidNativeWebViewCleanup.hideStaleWebViews();
    await PlatformViewGate.waitForNativeTeardown(frames: 2);

    if (!context.mounted) return;

    messenger?.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text('Opening quiz · v$kAppFullVersionLabel'),
      ),
    );

    await showGeneralDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierColor: Colors.white,
      barrierLabel: 'Lesson quiz',
      transitionDuration: Duration.zero,
      pageBuilder: (dialogContext, _, __) {
        final size = MediaQuery.sizeOf(dialogContext);
        return PopScope(
          canPop: true,
          child: Material(
            color: Colors.white,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: SafeArea(
                child: ChangeNotifierProvider<LearningProgressProvider>.value(
                  value: learning,
                  child: LessonQuizScreen(
                    initialArgs: args,
                    onRequestClose: () =>
                        Navigator.of(dialogContext, rootNavigator: true).pop(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    QuizDiagnostics.log('Quiz dialog closed lessonId=${args.lessonId}');
    return;
  }

  final rootNav = Navigator.of(context, rootNavigator: true);
  await rootNav.push<void>(
    MaterialPageRoute<void>(
      settings: RouteSettings(
        name: AppRoutes.lessonQuiz,
        arguments: args,
      ),
      builder: (_) => const ColoredBox(
        color: Color(0xFFFFFFFF),
        child: SizedBox.expand(
          child: LessonQuizScreen(),
        ),
      ),
    ),
  );
}
