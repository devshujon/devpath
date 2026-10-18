/// Builds a full HTML document from playground HTML/CSS/JS buffers.
String buildPlaygroundPreviewDocument({
  required String html,
  required String css,
  required String js,
}) {
  final safeJs = js.replaceAll('</script>', r'<\/script>');
  final cssBlock = css.trim().isEmpty ? '' : '<style>$css</style>';
  final jsBlock = safeJs.trim().isEmpty ? '' : '<script>$safeJs</script>';

  final hasHtmlTag =
      RegExp(r'<html[\s>]', caseSensitive: false).hasMatch(html);
  final hasHead = RegExp(r'<head[\s>]', caseSensitive: false).hasMatch(html);
  final hasBodyClose =
      RegExp(r'</body\s*>', caseSensitive: false).hasMatch(html);

  if (hasHtmlTag) {
    var doc = html;
    if (cssBlock.isNotEmpty) {
      if (hasHead) {
        doc = doc.replaceFirstMapped(
          RegExp(r'(<head[^>]*>)', caseSensitive: false),
          (m) => '${m[1]}$cssBlock',
        );
      } else {
        doc = doc.replaceFirstMapped(
          RegExp(r'(<html[^>]*>)', caseSensitive: false),
          (m) => '${m[1]}<head>$cssBlock</head>',
        );
      }
    }
    if (jsBlock.isNotEmpty) {
      if (hasBodyClose) {
        doc = doc.replaceFirstMapped(
          RegExp(r'(</body\s*>)', caseSensitive: false),
          (m) => '$jsBlock${m[1]}',
        );
      } else {
        doc = '$doc\n$jsBlock';
      }
    }
    return doc;
  }

  return '''<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
$cssBlock
</head>
<body>
$html
$jsBlock
</body>
</html>''';
}
