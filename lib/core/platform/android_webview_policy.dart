import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// CodeMirror [WebViewWidget] on Android leaves ghost native surfaces on
/// Honor/Huawei that cover later routes (lesson quiz). Use [CodeEditorPane].
bool get useCodemirrorWebViewOnAndroid {
  if (kIsWeb) return true;
  return defaultTargetPlatform != TargetPlatform.android;
}

/// HTML live preview WebView — same ghost-layer issue on Honor/Huawei.
bool get useHtmlPreviewWebViewOnAndroid {
  if (kIsWeb) return true;
  return defaultTargetPlatform != TargetPlatform.android;
}
