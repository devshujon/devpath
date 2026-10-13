import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'platform_webview_registry.dart';

/// Globally suspends Flutter [WebViewWidget] / platform views on Android
/// while full-screen routes (e.g. lesson quiz) are open.
class PlatformViewGate extends ChangeNotifier {
  PlatformViewGate._();
  static final PlatformViewGate instance = PlatformViewGate._();

  int _depth = 0;

  bool get isSuspended => _depth > 0;

  void suspend() {
    _depth++;
    if (kDebugMode) {
      debugPrint('[PlatformViewGate] suspend depth=$_depth');
    }
    notifyListeners();
  }

  void resume() {
    if (_depth <= 0) return;
    _depth--;
    if (kDebugMode) {
      debugPrint('[PlatformViewGate] resume depth=$_depth');
    }
    notifyListeners();
  }

  /// Runs [action] while platform views are suspended.
  Future<T> runSuspended<T>(Future<T> Function() action) async {
    suspend();
    try {
      await PlatformWebViewRegistry.instance.releaseAll();
      await waitForNativeTeardown();
      return await action();
    } finally {
      resume();
    }
  }

  /// Gives Android time to tear down native WebView surfaces after routes
  /// pop or platform views detach.
  static Future<void> waitForNativeTeardown({int frames = 6}) async {
    final count = kIsWeb ? 2 : frames;
    for (var i = 0; i < count; i++) {
      await SchedulerBinding.instance.endOfFrame;
    }
  }
}
