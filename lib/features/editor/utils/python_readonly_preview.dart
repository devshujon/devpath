/// Builds a read-only HTML document for Python starter code in the
/// WebView playground. Python is **not** executed in-app.
String pythonReadonlyPreviewHtml(String pythonCode) {
  final escaped = pythonCode
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
  return '''<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<style>
  body { font-family: system-ui, sans-serif; margin: 16px; line-height: 1.5; }
  .banner {
    background: #3776AB22;
    border: 1px solid #3776AB;
    border-radius: 8px;
    padding: 12px;
    margin-bottom: 16px;
    font-size: 14px;
  }
  pre {
    background: #0f1419;
    color: #e6e6e6;
    padding: 16px;
    border-radius: 8px;
    overflow-x: auto;
    font-size: 14px;
  }
</style>
</head>
<body>
  <div class="banner">
    <strong>Python example (read-only)</strong><br/>
    DevPath playground preview runs HTML, CSS, and JavaScript only.
    Copy this code to run it in a Python interpreter on your computer.
  </div>
  <pre>$escaped</pre>
</body>
</html>''';
}
