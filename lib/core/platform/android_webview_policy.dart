import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// CodeMirror [WebViewWidget] on Android leaves ghost native surfaces on
/// Honor/Huawei that cover later routes (lesson quiz). Use [CodeEditorPane].
bool get useCodemirrorWebViewOnAndroid {
  if (kIsWeb) return true;
  return defaultTargetPlatform != TargetPlatform.android;
}

/// HTML live preview WebView in split/embedded playground — ghost layers on Honor.
bool get useHtmlPreviewWebViewOnAndroid {
  if (kIsWeb) return true;
  return defaultTargetPlatform != TargetPlatform.android;
}

/// Full-screen playground preview route may opt in to a live WebView on Android
/// (route is disposed on pop; no embedded platform view on editor screen).
bool get useAndroidDedicatedPlaygroundPreviewWebView {
  if (kIsWeb) return true;
  return defaultTargetPlatform == TargetPlatform.android;
}
