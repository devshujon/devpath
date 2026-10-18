import 'package:flutter/material.dart';

import '../models/editor_file_type.dart';

Future<EditorFileKind?> showNewFileSheet(BuildContext context) {
  const kinds = [
    EditorFileKind.html,
    EditorFileKind.css,
    EditorFileKind.javascript,
    EditorFileKind.php,
    EditorFileKind.json,
    EditorFileKind.text,
    EditorFileKind.markdown,
  ];

  return showModalBottomSheet<EditorFileKind>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Text(
              'New file',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          ...kinds.map(
            (k) => ListTile(
              leading: Icon(_iconFor(k)),
              title: Text(k.label),
              subtitle: Text('.${k.defaultExtension}'),
              onTap: () => Navigator.pop(ctx, k),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

IconData _iconFor(EditorFileKind k) => switch (k) {
      EditorFileKind.html => Icons.language_outlined,
      EditorFileKind.css => Icons.palette_outlined,
      EditorFileKind.javascript => Icons.javascript_outlined,
      EditorFileKind.php => Icons.code_outlined,
      EditorFileKind.json => Icons.data_object_outlined,
      EditorFileKind.markdown => Icons.article_outlined,
      EditorFileKind.text => Icons.notes_outlined,
      EditorFileKind.xml => Icons.account_tree_outlined,
    };
