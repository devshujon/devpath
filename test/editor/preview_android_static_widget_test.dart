import 'package:devpath/core/platform/android_webview_policy.dart';
import 'package:devpath/features/editor/logic/playground_preview_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android uses static embedded preview policy', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    expect(useHtmlPreviewWebViewOnAndroid, isFalse);
    expect(PlaygroundPreviewLauncher.embeddedPreviewIsStaticOnly, isTrue);
  });

  test('non-Android may use embedded WebView preview', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    expect(useHtmlPreviewWebViewOnAndroid, isTrue);
    expect(PlaygroundPreviewLauncher.embeddedPreviewIsStaticOnly, isFalse);
  });
}
