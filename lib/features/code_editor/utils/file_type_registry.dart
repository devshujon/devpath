import '../models/editor_file_type.dart';

/// Maps file extensions to [EditorFileKind]. Add entries here for new types.
class EditorFileTypeRegistry {
  EditorFileTypeRegistry._();

  static const maxImportBytes = 2 * 1024 * 1024;

  static const _extToKind = {
    'html': EditorFileKind.html,
    'htm': EditorFileKind.html,
    'css': EditorFileKind.css,
    'js': EditorFileKind.javascript,
    'json': EditorFileKind.json,
    'xml': EditorFileKind.xml,
    'php': EditorFileKind.php,
    'txt': EditorFileKind.text,
    'md': EditorFileKind.markdown,
  };

  static bool isSupportedExtension(String ext) =>
      _extToKind.containsKey(ext.toLowerCase());

  static EditorFileKind? kindForFileName(String fileName) {
    final ext = extensionOf(fileName);
    if (ext.isEmpty) return null;
    return _extToKind[ext.toLowerCase()];
  }

  static String extensionOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot <= 0 || dot == fileName.length - 1) return '';
    return fileName.substring(dot + 1);
  }

  static String baseName(String fileName) {
    final slash = fileName.lastIndexOf('/');
    final name = slash >= 0 ? fileName.substring(slash + 1) : fileName;
    return name;
  }

  static List<String> get pickerExtensions => _extToKind.keys.toList()..sort();
}
