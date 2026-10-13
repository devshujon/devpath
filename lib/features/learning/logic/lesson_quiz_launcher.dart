import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/debug/quiz_diagnostics.dart';
import '../../../core/platform/platform_view_gate.dart';
import '../../../core/routing/app_routes.dart';
import '../screens/lesson_quiz_overlay.dart';
import '../screens/lesson_quiz_screen.dart';

/// Opens [LessonQuizScreen] on Android via root [Overlay] (Honor ghost WebView fix).
Future<void> openLessonQuiz(
  BuildContext context, {
  required LessonDetailArguments args,
}) async {
  PlatformViewGate.instance.forceOpen();

  QuizDiagnostics.log('Take Quiz lessonId=${args.lessonId}');

  if (!context.mounted) return;

  if (!kIsWeb && Platform.isAndroid) {
    await LessonQuizOverlay.show(context, args: args);
    QuizDiagnostics.log('Quiz overlay closed lessonId=${args.lessonId}');
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
