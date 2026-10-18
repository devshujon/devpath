/// File kinds DevPath accepts from Android "Open with" intents.
enum ExternalFileKind {
  html,
  css,
  javascript,
  json,
  xml,
  unsupported,
}

extension ExternalFileKindMeta on ExternalFileKind {
  String get label => switch (this) {
        ExternalFileKind.html => 'HTML',
        ExternalFileKind.css => 'CSS',
        ExternalFileKind.javascript => 'JavaScript',
        ExternalFileKind.json => 'JSON',
        ExternalFileKind.xml => 'XML',
        ExternalFileKind.unsupported => 'Unsupported',
      };

  bool get supportsHtmlPreview => this == ExternalFileKind.html;

  bool get supportsSourcePreview =>
      this == ExternalFileKind.css ||
      this == ExternalFileKind.javascript ||
      this == ExternalFileKind.json ||
      this == ExternalFileKind.xml;

  String get defaultExtension => switch (this) {
        ExternalFileKind.html => 'html',
        ExternalFileKind.css => 'css',
        ExternalFileKind.javascript => 'js',
        ExternalFileKind.json => 'json',
        ExternalFileKind.xml => 'xml',
        ExternalFileKind.unsupported => 'txt',
      };

  String? get mimeForExport => switch (this) {
        ExternalFileKind.html => 'text/html',
        ExternalFileKind.css => 'text/css',
        ExternalFileKind.javascript => 'text/javascript',
        ExternalFileKind.json => 'application/json',
        ExternalFileKind.xml => 'application/xml',
        ExternalFileKind.unsupported => null,
      };
}
