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

  /// Hides native WebViews without [WebView.destroy] (destroy broke Honor rendering).
  static Future<int> hideStaleWebViews() async {
    if (kIsWeb || !Platform.isAndroid) return 0;
    try {
      final hidden = await _channel.invokeMethod<int>('hideStaleWebViews');
      final count = hidden ?? 0;
      QuizDiagnostics.log('Android native hidden WebViews=$count');
      return count;
    } catch (e, st) {
      QuizDiagnostics.log('hideStaleWebViews failed: $e\n$st');
      return 0;
    }
  }
}
