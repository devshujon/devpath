/// Builds an offline HTML document for WebView preview, inlining sibling
/// workspace files referenced by relative `<link>` / `<script>` tags.
class HtmlPreviewBuilder {
  HtmlPreviewBuilder._();

  static String build({
    required String htmlSource,
    required Map<String, String> workspaceFilesByLowerName,
    Set<String> ambiguousBasenames = const {},
  }) {
    var html = htmlSource;

    html = _inlineStylesheets(
      html,
      workspaceFilesByLowerName,
      ambiguousBasenames,
    );
    html = _inlineScripts(
      html,
      workspaceFilesByLowerName,
      ambiguousBasenames,
    );

    if (!_looksLikeFullDocument(html)) {
      html = '''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
</head>
<body>
$html
</body>
</html>''';
    }

    return html;
  }

  static bool _looksLikeFullDocument(String s) {
    final lower = s.toLowerCase();
    return lower.contains('<html') && lower.contains('<body');
  }

  static String _ambigComment(Set<String> ambiguous, String key) {
    if (!ambiguous.contains(key)) return '';
    return '<!-- workspace: multiple files named $key; using most recently updated -->\n';
  }

  static String _inlineStylesheets(
    String html,
    Map<String, String> files,
    Set<String> ambiguous,
  ) {
    final linkRe = RegExp(
      r'''<link[^>]+rel=["']stylesheet["'][^>]*href=["']([^"']+)["'][^>]*>''',
      caseSensitive: false,
    );
    return html.replaceAllMapped(linkRe, (m) {
      final href = m.group(1)!;
      if (_isRemote(href)) return '<!-- offline: skipped remote CSS $href -->';
      final key = _basename(href).toLowerCase();
      final css = files[key];
      if (css == null) {
        return '<!-- missing local CSS: $href -->';
      }
      return '${_ambigComment(ambiguous, key)}<style data-inlined-from="$key">\n$css\n</style>';
    });
  }

  static String _inlineScripts(
    String html,
    Map<String, String> files,
    Set<String> ambiguous,
  ) {
    final scriptRe = RegExp(
      r'''<script[^>]+src=["']([^"']+)["'][^>]*>\s*</script>''',
      caseSensitive: false,
    );
    return html.replaceAllMapped(scriptRe, (m) {
      final src = m.group(1)!;
      if (_isRemote(src)) return '<!-- offline: skipped remote JS $src -->';
      final key = _basename(src).toLowerCase();
      final js = files[key];
      if (js == null) {
        return '<!-- missing local JS: $src -->';
      }
      final safe = js.replaceAll('</script>', r'<\/script>');
      return '${_ambigComment(ambiguous, key)}<script data-inlined-from="$key">\n$safe\n</script>';
    });
  }

  static bool _isRemote(String href) {
    final h = href.trim().toLowerCase();
    return h.startsWith('http://') ||
        h.startsWith('https://') ||
        h.startsWith('//');
  }

  static String _basename(String path) {
    final cleaned = path.split('?').first.split('#').first;
    final slash = cleaned.lastIndexOf('/');
    return slash >= 0 ? cleaned.substring(slash + 1) : cleaned;
  }
}
