import 'package:flutter/material.dart';

import '../../../core/debug/quiz_diagnostics.dart';
import '../../../core/platform/platform_view_gate.dart';
import '../../../core/routing/app_routes.dart';
import '../screens/lesson_quiz_screen.dart';

/// Opens [LessonQuizScreen] on the root navigator.
Future<void> openLessonQuiz(
  BuildContext context, {
  required LessonDetailArguments args,
}) async {
  PlatformViewGate.instance.forceOpen();

  final rootNav = Navigator.of(context, rootNavigator: true);

  QuizDiagnostics.log('Take Quiz lessonId=${args.lessonId}');

  if (!context.mounted) return;

  await rootNav.push<void>(
    PageRouteBuilder<void>(
      opaque: true,
      settings: RouteSettings(
        name: AppRoutes.lessonQuiz,
        arguments: args,
      ),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const ColoredBox(
          color: Color(0xFFFFFFFF),
          child: SizedBox.expand(
            child: LessonQuizScreen(),
          ),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
  );

  QuizDiagnostics.log('Quiz closed lessonId=${args.lessonId}');
}
