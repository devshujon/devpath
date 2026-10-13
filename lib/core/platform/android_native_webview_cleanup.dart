import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../debug/quiz_diagnostics.dart';

/// Removes orphaned Android [WebView] surfaces that Flutter no longer owns
/// (Honor/Huawei ghost layer over quiz).
class AndroidNativeWebViewCleanup {
  AndroidNativeWebViewCleanup._();

  static const MethodChannel _channel =
      MethodChannel('com.devpath.app/platformviews');

  static Future<int> removeStaleWebViews() async {
    if (kIsWeb || !Platform.isAndroid) return 0;
    try {
      final removed =
          await _channel.invokeMethod<int>('removeStaleWebViews');
      final count = removed ?? 0;
      QuizDiagnostics.log('Android native removed WebViews=$count');
      return count;
    } catch (e, st) {
      QuizDiagnostics.log('removeStaleWebViews failed: $e\n$st');
      return 0;
    }
  }

  static Future<void> bringFlutterSurfaceToFront() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('bringFlutterSurfaceToFront');
      QuizDiagnostics.log('Android bringFlutterSurfaceToFront ok');
    } catch (e) {
      QuizDiagnostics.log('bringFlutterSurfaceToFront failed: $e');
    }
  }
}
