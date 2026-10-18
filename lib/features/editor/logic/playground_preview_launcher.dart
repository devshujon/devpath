import 'package:flutter/material.dart';

import '../../../core/platform/android_webview_policy.dart';
import '../providers/playground_provider.dart';
import '../screens/playground_live_preview_screen.dart';
import '../utils/playground_preview_document.dart';

/// Opens isolated full-screen live preview (Android execution path).
class PlaygroundPreviewLauncher {
  PlaygroundPreviewLauncher._();

  /// True when embedded preview cannot run JS (Android quiz-safe mode).
  static bool get embeddedPreviewIsStaticOnly => !useHtmlPreviewWebViewOnAndroid;

  static String documentFor(PlaygroundProvider provider) =>
      buildPlaygroundPreviewDocument(
        html: provider.htmlCommitted,
        css: provider.cssCommitted,
        js: provider.jsCommitted,
      );

  /// Commits drafts to [PlaygroundProvider] then pushes live preview route.
  static Future<void> commitAndOpenLive(
    BuildContext context,
    PlaygroundProvider provider, {
    bool runFirst = true,
  }) async {
    if (runFirst) provider.run();
    if (!context.mounted) return;
    final doc = documentFor(provider);
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: PlaygroundLivePreviewScreen.route),
        builder: (_) => PlaygroundLivePreviewScreen(
          htmlDocument: doc,
          version: provider.runVersion,
        ),
      ),
    );
  }
}
