import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/platform/android_native_webview_cleanup.dart';
import '../../../core/platform/platform_view_gate.dart';
import 'lesson_detail_screen.dart';
import 'lesson_quiz_screen.dart';

/// Shows the lesson quiz above the entire app (Honor: above ghost platform views).
class LessonQuizOverlay {
  LessonQuizOverlay._();

  static Future<void> show(
    BuildContext context, {
    required LessonDetailArguments args,
  }) async {
    PlatformViewGate.instance.forceOpen();
    await AndroidNativeWebViewCleanup.hideStaleWebViews();
    await PlatformViewGate.waitForNativeTeardown(frames: 4);

    if (!context.mounted) return;

    final overlay = Overlay.of(context, rootOverlay: true);
    final done = Completer<void>();
    late OverlayEntry entry;

    entry = OverlayEntry(
      opaque: true,
      maintainState: true,
      builder: (overlayContext) {
        return Positioned.fill(
          child: Material(
            color: Colors.white,
            elevation: 32,
            child: SafeArea(
              child: LessonQuizScreen(
                initialArgs: args,
                onRequestClose: () {
                  entry.remove();
                  if (!done.isCompleted) done.complete();
                },
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    await done.future;
  }
}
