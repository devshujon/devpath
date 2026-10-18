import 'package:flutter/material.dart';

import '../../editor/widgets/preview_pane.dart';
import '../models/external_open_payload.dart';
import '../services/external_file_export_service.dart';

/// Isolated preview for externally opened files (WebView disposed on pop).
class ExternalFilePreviewScreen extends StatefulWidget {
  final String title;
  final String htmlDocument;
  final ExternalOpenPayload payload;

  const ExternalFilePreviewScreen({
    super.key,
    required this.title,
    required this.htmlDocument,
    required this.payload,
  });

  @override
  State<ExternalFilePreviewScreen> createState() =>
      _ExternalFilePreviewScreenState();
}

class _ExternalFilePreviewScreenState extends State<ExternalFilePreviewScreen> {
  final int _version = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share_outlined),
            onPressed: () => ExternalFileExportService.shareContent(
              fileName: widget.payload.displayName,
              content: widget.payload.content,
            ),
          ),
          IconButton(
            tooltip: 'Export copy',
            icon: const Icon(Icons.upload_file),
            onPressed: _export,
          ),
        ],
      ),
      body: SafeArea(
        child: PreviewPane(
          htmlDocument: widget.htmlDocument,
          version: _version,
          androidLivePreview: true,
        ),
      ),
    );
  }

  Future<void> _export() async {
    final ok = await ExternalFileExportService.saveCopy(
      fileName: widget.payload.displayName,
      kind: widget.payload.kind,
      content: widget.payload.content,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Export saved' : 'Export cancelled')),
    );
  }
}
