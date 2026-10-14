import 'package:flutter/material.dart';

import '../widgets/preview_pane.dart';

/// Full-screen isolated preview (Android may use WebView; disposed on pop).
class PlaygroundLivePreviewScreen extends StatelessWidget {
  final String htmlDocument;
  final int version;

  const PlaygroundLivePreviewScreen({
    super.key,
    required this.htmlDocument,
    required this.version,
  });

  static const route = '/playground-live-preview';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live preview'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: PreviewPane(
          htmlDocument: htmlDocument,
          version: version,
          androidLivePreview: true,
        ),
      ),
    );
  }
}
