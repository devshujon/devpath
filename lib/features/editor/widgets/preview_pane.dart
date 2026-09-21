import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Renders a string of HTML in a WebView. Reloads whenever [version]
/// changes — even if [htmlDocument] is byte-identical.
///
/// The caller is responsible for producing a complete HTML document.
/// PreviewPane only wraps it with a tiny error-catching shell so user
/// JavaScript exceptions surface in a red banner instead of vanishing.
///
/// Navigation is blocked except for `about:` and `data:` schemes. User
/// code that tries `window.location = 'https://...'` or clicks on
/// `<a href="https://...">` will silently fail — by design.
class PreviewPane extends StatefulWidget {
  /// Full HTML document the user wrote (or that the parent assembled
  /// from multiple sources like html + css + js).
  final String htmlDocument;

  /// Monotonically increasing counter. The WebView reloads whenever this
  /// changes. Use the parent provider's runVersion.
  final int version;

  const PreviewPane({
    super.key,
    required this.htmlDocument,
    required this.version,
  });

  @override
  State<PreviewPane> createState() => _PreviewPaneState();
}

class _PreviewPaneState extends State<PreviewPane> {
  late final WebViewController _controller;
  int _lastRenderedVersion = -1;
  bool _loading = false;
  Timer? _loadTimeout;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            _loadTimeout?.cancel();
            if (mounted) setState(() => _loading = false);
          },
          onNavigationRequest: _allowOnlyLocalSchemes,
        ),
      );

    _renderIfNeeded();
  }

  /// Block all http/https navigation. Allow only the data: and about:
  /// schemes used by loadHtmlString itself.
  NavigationDecision _allowOnlyLocalSchemes(NavigationRequest request) {
    final url = request.url.toLowerCase();
    if (url.startsWith('about:') || url.startsWith('data:')) {
      return NavigationDecision.navigate;
    }
    return NavigationDecision.prevent;
  }

  @override
  void didUpdateWidget(covariant PreviewPane old) {
    super.didUpdateWidget(old);
    _renderIfNeeded();
  }

  @override
  void dispose() {
    _loadTimeout?.cancel();
    super.dispose();
  }

  void _renderIfNeeded() {
    if (widget.version == _lastRenderedVersion) return;
    _lastRenderedVersion = widget.version;
    _controller.loadHtmlString(_wrapWithErrorTrap(widget.htmlDocument));
    // Safety net: if the platform WebView never fires onPageFinished
    // (some Android System WebView builds stall on loadHtmlString),
    // clear the loading indicator anyway so it can't spin forever.
    _loadTimeout?.cancel();
    _loadTimeout = Timer(const Duration(seconds: 6), () {
      if (mounted && _loading) setState(() => _loading = false);
    });
  }

  /// Wraps user HTML with a small error-trap script. Runtime JS errors
  /// become a red banner at the bottom of the preview instead of
  /// disappearing silently.
  String _wrapWithErrorTrap(String userHtml) {
    // If the user's document already has <head>, inject the trap into it.
    // Otherwise, wrap their content in a full document.
    final hasHead = RegExp(r'<head[\s>]', caseSensitive: false)
        .hasMatch(userHtml);

    const trapStyle = '''
<style>
  #__devpath_err__ {
    position: fixed; bottom: 0; left: 0; right: 0;
    background: #2d1b1b; color: #ff7b72;
    font-family: monospace; font-size: 12px;
    padding: 8px 12px;
    border-top: 1px solid #5e2e2e;
    white-space: pre-wrap;
    max-height: 30vh; overflow: auto;
    display: none;
    z-index: 999999;
  }
</style>''';

    const trapScript = '''
<script>
(function() {
  var box;
  function ensureBox() {
    if (box) return box;
    box = document.createElement('div');
    box.id = '__devpath_err__';
    document.body && document.body.appendChild(box);
    return box;
  }
  function showErr(msg) {
    var b = ensureBox();
    if (!b) return;
    b.style.display = 'block';
    b.textContent = String(msg);
  }
  window.addEventListener('error', function(e) {
    showErr(e.message + ' (line ' + (e.lineno || '?') + ')');
  });
  window.addEventListener('unhandledrejection', function(e) {
    showErr('Unhandled promise: ' + (e.reason && e.reason.message || e.reason));
  });
})();
</script>''';

    if (hasHead) {
      // Inject right after <head ...>
      return userHtml.replaceFirstMapped(
        RegExp(r'(<head[^>]*>)', caseSensitive: false),
        (m) => '${m[1]}$trapStyle$trapScript',
      );
    }

    return '''<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
$trapStyle
$trapScript
</head>
<body>
$userHtml
</body>
</html>''';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF0A0C10) : const Color(0xFFFAFBFD),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: Colors.white,
                child: WebViewWidget(controller: _controller),
              ),
            ),
          ),
          if (_loading)
            const Positioned(
              top: 12,
              right: 16,
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }
}
