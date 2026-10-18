import 'dart:convert';

import '../../editor/utils/playground_preview_document.dart';
import '../models/external_file_kind.dart';

/// Builds preview documents for externally opened files (untrusted content).
String buildExternalPreviewDocument({
  required ExternalFileKind kind,
  required String source,
}) {
  switch (kind) {
    case ExternalFileKind.html:
      return _wrapUntrustedHtml(source);
    case ExternalFileKind.css:
      return _sourcePreviewPage(
        title: 'CSS preview',
        language: 'css',
        source: source,
        note:
            'This is a stylesheet only. DevPath shows the source here; '
            'link it from an HTML file to see styling applied.',
      );
    case ExternalFileKind.javascript:
      return _sourcePreviewPage(
        title: 'JavaScript preview',
        language: 'javascript',
        source: source,
        note:
            'This is a script file only. It is not executed in this preview. '
            'Use Edit to modify the source or open it from an HTML page.',
      );
    case ExternalFileKind.json:
      return _formattedJsonPage(source);
    case ExternalFileKind.xml:
      return _sourcePreviewPage(
        title: 'XML preview',
        language: 'xml',
        source: source,
        note: 'Formatted source preview. External entities and remote resources are not loaded.',
      );
    case ExternalFileKind.unsupported:
      return _sourcePreviewPage(
        title: 'Unsupported file',
        language: 'text',
        source: source,
        note: 'This file type is not supported for preview.',
      );
  }
}

String _wrapUntrustedHtml(String html) {
  final hasHtml = RegExp(r'<html[\s>]', caseSensitive: false).hasMatch(html);
  final doc = hasHtml
      ? html
      : buildPlaygroundPreviewDocument(html: html, css: '', js: '');

  // Inject a note about missing linked assets (no base URL for content://).
  const banner = '''
<div id="devpath-open-banner" style="font-family:system-ui,sans-serif;padding:12px;margin:8px;border:1px solid #3776AB;border-radius:8px;background:#3776AB18;font-size:14px;">
  <strong>Imported HTML preview</strong><br/>
  Linked CSS, JS, or images from other files may be missing unless they were embedded.
  External navigation is blocked for safety.
</div>''';

  if (RegExp(r'<body[\s>]', caseSensitive: false).hasMatch(doc)) {
    return doc.replaceFirstMapped(
      RegExp(r'(<body[^>]*>)', caseSensitive: false),
      (m) => '${m[1]}$banner',
    );
  }
  return buildPlaygroundPreviewDocument(
    html: '$banner\n$html',
    css: '',
    js: '',
  );
}

String _sourcePreviewPage({
  required String title,
  required String language,
  required String source,
  required String note,
}) {
  final escaped = _escapeHtml(source);
  return '''<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<title>$title</title>
<style>
  body { font-family: system-ui, sans-serif; margin: 16px; line-height: 1.5; }
  .note { padding: 12px; border-radius: 8px; background: #3776AB18; border: 1px solid #3776AB; margin-bottom: 12px; font-size: 14px; }
  pre { background: #0f1419; color: #e6e6e6; padding: 16px; border-radius: 8px; overflow-x: auto; white-space: pre-wrap; word-break: break-word; font-size: 13px; }
</style>
</head>
<body>
  <div class="note">$note</div>
  <pre><code class="language-$language">$escaped</code></pre>
</body>
</html>''';
}

String _formattedJsonPage(String source) {
  var display = source;
  try {
    // ignore: avoid_dynamic_calls
    final decoded = _parseJson(source);
    display = const JsonEncoder.withIndent('  ').convert(decoded);
  } catch (_) {
    // keep raw
  }
  return _sourcePreviewPage(
    title: 'JSON preview',
    language: 'json',
    source: display,
    note: 'JSON is shown for reading. Invalid JSON is displayed as raw text.',
  );
}

dynamic _parseJson(String source) {
  return (const JsonDecoder()).convert(source);
}

String _escapeHtml(String input) {
  return input
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}
