import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../editor/widgets/preview_pane.dart';
import '../providers/code_editor_provider.dart';

class CodeEditorPreviewScreen extends StatelessWidget {
  const CodeEditorPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CodeEditorProvider>(
      builder: (context, editor, _) {
        return FutureBuilder<String>(
          key: ValueKey(editor.previewVersion),
          future: editor.buildPreviewHtml(),
          builder: (context, snap) {
            final html = snap.data;
            return Scaffold(
              appBar: AppBar(
                title: const Text('Preview'),
                actions: [
                  IconButton(
                    tooltip: 'Refresh preview',
                    onPressed: () {
                      editor.bumpPreview();
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              body: snap.connectionState == ConnectionState.waiting &&
                      html == null
                  ? const Center(child: CircularProgressIndicator())
                  : PreviewPane(
                      key: ValueKey(editor.previewVersion),
                      htmlDocument: html ?? '<html><body></body></html>',
                      version: editor.previewVersion,
                    ),
            );
          },
        );
      },
    );
  }
}
