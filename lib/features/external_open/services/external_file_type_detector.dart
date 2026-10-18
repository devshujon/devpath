import '../models/external_file_kind.dart';

/// Detects [ExternalFileKind] from MIME type and file name hints.
class ExternalFileTypeDetector {
  ExternalFileTypeDetector._();

  static const maxOpenBytes = 1024 * 1024;

  static ExternalFileKind detect({
    required String? mimeType,
    required String? displayName,
    required String? uriString,
  }) {
    final mime = (mimeType ?? '').toLowerCase().trim();
    if (mime.isNotEmpty) {
      final fromMime = _fromMime(mime);
      if (fromMime != ExternalFileKind.unsupported) return fromMime;
    }

    final name = _fileNameFrom(displayName, uriString);
    if (name != null) {
      final ext = _extension(name);
      final fromExt = _fromExtension(ext);
      if (fromExt != ExternalFileKind.unsupported) return fromExt;
    }

    return ExternalFileKind.unsupported;
  }

  static ExternalFileKind _fromMime(String mime) {
    if (mime == 'text/html' || mime == 'application/xhtml+xml') {
      return ExternalFileKind.html;
    }
    if (mime == 'text/css') return ExternalFileKind.css;
    if (mime == 'text/javascript' ||
        mime == 'application/javascript' ||
        mime == 'application/x-javascript' ||
        mime == 'text/ecmascript' ||
        mime == 'application/ecmascript') {
      return ExternalFileKind.javascript;
    }
    if (mime == 'application/json' || mime == 'text/json') {
      return ExternalFileKind.json;
    }
    if (mime == 'application/xml' ||
        mime == 'text/xml' ||
        mime.endsWith('+xml')) {
      return ExternalFileKind.xml;
    }
    return ExternalFileKind.unsupported;
  }

  static ExternalFileKind _fromExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'html':
      case 'htm':
        return ExternalFileKind.html;
      case 'css':
        return ExternalFileKind.css;
      case 'js':
      case 'mjs':
        return ExternalFileKind.javascript;
      case 'json':
        return ExternalFileKind.json;
      case 'xml':
      case 'xsl':
        return ExternalFileKind.xml;
      default:
        return ExternalFileKind.unsupported;
    }
  }

  static String? _fileNameFrom(String? displayName, String? uriString) {
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }
    if (uriString == null || uriString.isEmpty) return null;
    final uri = Uri.tryParse(uriString);
    if (uri == null) return null;
    final seg = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
    if (seg.isNotEmpty) return seg;
    return null;
  }

  static String _extension(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot <= 0 || dot == fileName.length - 1) return '';
    return fileName.substring(dot + 1);
  }

  static String displayFileName(String? displayName, String? uriString) {
    return _fileNameFrom(displayName, uriString) ?? 'Opened file';
  }
}
