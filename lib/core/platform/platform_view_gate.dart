import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Globally suspends Flutter [WebViewWidget] / platform views on Android
/// while full-screen routes (e.g. lesson quiz) are open.
class PlatformViewGate extends ChangeNotifier {
  PlatformViewGate._();
  static final PlatformViewGate instance = PlatformViewGate._();

  int _depth = 0;

  bool get isSuspended => _depth > 0;

  void suspend() {
    _depth++;
    notifyListeners();
  }

  void resume() {
    if (_depth <= 0) return;
    _depth--;
    notifyListeners();
  }

  /// Runs [action] while platform views are suspended.
  Future<T> runSuspended<T>(Future<T> Function() action) async {
    suspend();
    try {
      return await action();
    } finally {
      resume();
    }
  }

  /// Gives Android time to tear down native WebView surfaces after routes
  /// pop or platform views detach.
  static Future<void> waitForNativeTeardown() async {
    await SchedulerBinding.instance.endOfFrame;
    await SchedulerBinding.instance.endOfFrame;
    if (kIsWeb) return;
    if (Platform.isAndroid || defaultTargetPlatform == TargetPlatform.android) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
  }
}
