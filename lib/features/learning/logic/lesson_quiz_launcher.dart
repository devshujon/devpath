import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_version.dart';
import '../../../core/debug/quiz_diagnostics.dart';
import '../../../core/platform/platform_view_gate.dart';
import '../../../core/routing/app_routes.dart';
import '../providers/learning_progress_provider.dart';
import '../screens/lesson_quiz_screen.dart';

/// Opens [LessonQuizScreen]. Android uses a full-height modal sheet (Honor-safe).
Future<void> openLessonQuiz(
  BuildContext context, {
  required LessonDetailArguments args,
}) async {
  PlatformViewGate.instance.forceOpen();

  QuizDiagnostics.log('Take Quiz lessonId=${args.lessonId}');

  if (!context.mounted) return;

  final learning = context.read<LearningProgressProvider>();

  if (!kIsWeb && Platform.isAndroid) {
    if (kDebugMode) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('Opening quiz · v$kAppFullVersionLabel'),
        ),
      );
    }

    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      barrierColor: Colors.black54,
      builder: (sheetContext) {
        final height = MediaQuery.sizeOf(sheetContext).height;
        return Theme(
          data: ThemeData.light(),
          child: SizedBox(
            width: double.infinity,
            height: height,
            child: ChangeNotifierProvider<LearningProgressProvider>.value(
              value: learning,
              child: LessonQuizScreen(
                initialArgs: args,
                onRequestClose: () {
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
                },
              ),
            ),
          ),
        );
      },
    );

    QuizDiagnostics.log('Quiz sheet closed lessonId=${args.lessonId}');
    return;
  }

  final rootNav = Navigator.of(context, rootNavigator: true);
  await rootNav.push<void>(
    MaterialPageRoute<void>(
      settings: RouteSettings(
        name: AppRoutes.lessonQuiz,
        arguments: args,
      ),
      builder: (routeContext) {
        return Theme(
          data: ThemeData.light(),
          child: ChangeNotifierProvider<LearningProgressProvider>.value(
            value: learning,
            child: LessonQuizScreen(
              initialArgs: args,
              onRequestClose: () {
                if (routeContext.mounted) {
                  Navigator.of(routeContext).pop();
                }
              },
            ),
          ),
        );
      },
    ),
  );
}
