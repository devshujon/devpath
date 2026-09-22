import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../code_editor/models/editor_file_type.dart';
import '../utils/codemirror_modes.dart';

/// CodeMirror-backed editor loaded from bundled [assets/editor/editor.html].
/// Used by the mobile Code Editor feature; Playground keeps [CodeEditorPane].
class CodemirrorEditorPane extends StatefulWidget {
  final String documentKey;
  final EditorFileKind fileKind;
  final String initialText;
  final ValueChanged<String> onChanged;

  final double fontSize;
  final bool wordWrap;
  final bool showLineNumbers;
  final bool preferDarkSurface;

  const CodemirrorEditorPane({
    super.key,
    required this.documentKey,
    required this.fileKind,
    required this.initialText,
    required this.onChanged,
    this.fontSize = 13,
    this.wordWrap = false,
    this.showLineNumbers = true,
    this.preferDarkSurface = true,
  });

  @override
  State<CodemirrorEditorPane> createState() => CodemirrorEditorPaneState();
}

class CodemirrorEditorPaneState extends State<CodemirrorEditorPane> {
  WebViewController? _controller;
  bool _ready = false;
  String? _loadedDocumentKey;
  String _lastAppliedSettings = '';

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(
        widget.preferDarkSurface
            ? const Color(0xFF212121)
            : const Color(0xFFF7F8FA),
      )
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: _onBridgeMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (req) {
            final url = req.url.toLowerCase();
            if (url.startsWith('file://') ||
                url.startsWith('about:') ||
                url.startsWith('data:')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      );

    _controller = controller;
    controller.loadFlutterAsset('assets/editor/editor.html');
  }

  void _onBridgeMessage(JavaScriptMessage message) {
    try {
      final map = jsonDecode(message.message) as Map<String, dynamic>;
      final type = map['type'] as String?;
      if (type == 'ready') {
        if (!mounted) return;
        setState(() => _ready = true);
        _pushDocument(force: true);
        _applySettings(force: true);
      } else if (type == 'change') {
        final fileId = map['fileId'] as String?;
        if (fileId != widget.documentKey) return;
        final content = map['content'] as String? ?? '';
        widget.onChanged(content);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('CodemirrorEditorPane bridge: $e');
    }
  }

  @override
  void didUpdateWidget(covariant CodemirrorEditorPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.documentKey != widget.documentKey) {
      _loadedDocumentKey = null;
      _pushDocument(force: true);
    }
    if (oldWidget.fontSize != widget.fontSize ||
        oldWidget.wordWrap != widget.wordWrap ||
        oldWidget.showLineNumbers != widget.showLineNumbers ||
        oldWidget.preferDarkSurface != widget.preferDarkSurface) {
      _applySettings(force: true);
    }
    if (oldWidget.fileKind != widget.fileKind && _ready) {
      _pushDocument(force: true);
    }
  }

  Future<void> _pushDocument({bool force = false}) async {
    final c = _controller;
    if (c == null || !_ready) return;
    if (!force && _loadedDocumentKey == widget.documentKey) return;
    _loadedDocumentKey = widget.documentKey;
    final mode = CodemirrorModes.forKind(widget.fileKind);
    final code = jsonEncode(widget.initialText);
    final id = jsonEncode(widget.documentKey);
    final modeJson = jsonEncode(mode);
    await c.runJavaScript('setCode($id, $code, $modeJson);');
    await _applySettings(force: true);
  }

  Future<void> _applySettings({bool force = false}) async {
    final c = _controller;
    if (c == null || !_ready) return;
    final signature =
        '${widget.fontSize}|${widget.wordWrap}|${widget.showLineNumbers}|${widget.preferDarkSurface}';
    if (!force && signature == _lastAppliedSettings) return;
    _lastAppliedSettings = signature;
    final opts = jsonEncode({
      'fontSize': widget.fontSize,
      'wordWrap': widget.wordWrap,
      'lineNumbers': widget.showLineNumbers,
      'darkTheme': widget.preferDarkSurface,
    });
    await c.runJavaScript('configureEditor($opts);');
  }

  /// Flush pending JS debounce and return the latest editor text.
  Future<String> flushAndGetCode() async {
    final c = _controller;
    if (c == null) return widget.initialText;
    if (!_ready) return widget.initialText;
    await c.runJavaScript('flushPending();');
    final raw = await c.runJavaScriptReturningResult('getCode();');
    return _jsStringResult(raw) ?? widget.initialText;
  }

  static String? _jsStringResult(Object? raw) {
    if (raw == null) return null;
    final s = raw.toString();
    if (s.startsWith('"') && s.endsWith('"') && s.length >= 2) {
      try {
        return jsonDecode(s) as String;
      } catch (_) {}
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        WebViewWidget(controller: controller),
        if (!_ready)
          const ColoredBox(
            color: Color(0xFF212121),
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    );
  }
}
