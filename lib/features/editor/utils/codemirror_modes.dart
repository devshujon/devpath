import '../../code_editor/models/editor_file_type.dart';

/// CodeMirror 5 mode strings for workspace file kinds.
class CodemirrorModes {
  CodemirrorModes._();

  static String forKind(EditorFileKind kind) => switch (kind) {
        EditorFileKind.html => 'htmlmixed',
        EditorFileKind.css => 'css',
        EditorFileKind.javascript => 'javascript',
        EditorFileKind.json => 'application/json',
        EditorFileKind.xml => 'xml',
        EditorFileKind.php => 'php',
        EditorFileKind.markdown => 'markdown',
        EditorFileKind.text => 'text/plain',
      };
}
