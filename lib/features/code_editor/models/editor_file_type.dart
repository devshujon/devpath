/// Supported workspace file kinds. Extend [EditorFileTypeRegistry] to add more.
enum EditorFileKind {
  html,
  css,
  javascript,
  json,
  xml,
  php,
  markdown,
  text,
}

extension EditorFileKindMeta on EditorFileKind {
  String get label => switch (this) {
        EditorFileKind.html => 'HTML',
        EditorFileKind.css => 'CSS',
        EditorFileKind.javascript => 'JavaScript',
        EditorFileKind.json => 'JSON',
        EditorFileKind.xml => 'XML',
        EditorFileKind.php => 'PHP',
        EditorFileKind.markdown => 'Markdown',
        EditorFileKind.text => 'Text',
      };

  String get defaultExtension => switch (this) {
        EditorFileKind.html => 'html',
        EditorFileKind.css => 'css',
        EditorFileKind.javascript => 'js',
        EditorFileKind.json => 'json',
        EditorFileKind.xml => 'xml',
        EditorFileKind.php => 'php',
        EditorFileKind.markdown => 'md',
        EditorFileKind.text => 'txt',
      };

  bool get supportsHtmlPreview => this == EditorFileKind.html;

  bool get isPhp => this == EditorFileKind.php;
}
