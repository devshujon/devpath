import '../models/workspace_file.dart';
import '../services/code_editor_storage.dart';

/// Resolves workspace file bodies for offline HTML preview.
class WorkspacePreviewAssets {
  WorkspacePreviewAssets._();

  /// Maps lowercase basename → content. When several workspace files share a
  /// name, the most recently updated entry wins; [ambiguousBasenames] lists
  /// those names so the preview HTML can document the choice.
  static Future<({
    Map<String, String> byBasename,
    Set<String> ambiguousBasenames,
  })> load({
    required CodeEditorStorage storage,
    String? liveFileId,
    String? liveContent,
  }) async {
    final index = await storage.loadIndex();
    final grouped = <String, List<WorkspaceFile>>{};
    for (final f in index) {
      final key = f.displayName.toLowerCase();
      grouped.putIfAbsent(key, () => []).add(f);
    }

    final ambiguous = <String>{};
    final out = <String, String>{};

    for (final entry in grouped.entries) {
      final list = entry.value
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      if (list.length > 1) ambiguous.add(entry.key);
      final body = await storage.readContent(list.first.id);
      if (body != null) out[entry.key] = body;
    }

    if (liveFileId != null && liveContent != null) {
      final file = index.where((f) => f.id == liveFileId).firstOrNull;
      if (file != null) {
        out[file.displayName.toLowerCase()] = liveContent;
      }
    }

    return (byBasename: out, ambiguousBasenames: ambiguous);
  }
}
