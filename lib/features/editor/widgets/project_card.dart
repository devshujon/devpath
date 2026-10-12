import 'package:flutter/material.dart';

import '../models/user_project.dart';

class ProjectCard extends StatelessWidget {
  final UserProject project;
  final VoidCallback onContinue;
  final VoidCallback onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onContinue,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF141820) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF262B35) : const Color(0xFFE4E7EE);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onContinue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Code preview (acts as visual thumbnail)
            Expanded(
              child: _CodeThumbnail(
                code: _previewSource(),
                isDark: isDark,
              ),
            ),
            // Metadata strip
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 6, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatRelative(project.updatedAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? const Color(0xFF8A929D)
                                    : const Color(0xFF5D6670),
                              ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    tooltip: 'More',
                    onSelected: (v) {
                      if (v == 'delete') onDelete();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.delete_outline, size: 18),
                          title: Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Continue button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(36),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.play_arrow, size: 16),
                label: const Text('Continue'),
                onPressed: onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// First lines of whichever buffer has content. Prefer HTML, then CSS, then JS.
  String _previewSource() {
    if (project.htmlCode.trim().isNotEmpty) return project.htmlCode;
    if (project.cssCode.trim().isNotEmpty) return project.cssCode;
    if (project.jsCode.trim().isNotEmpty) return project.jsCode;
    return '<empty>';
  }

  String _formatRelative(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }
}

class _CodeThumbnail extends StatelessWidget {
  final String code;
  final bool isDark;
  const _CodeThumbnail({required this.code, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F8FA),
      child: ClipRect(
        child: Text(
          code,
          maxLines: 8,
          overflow: TextOverflow.fade,
          style: TextStyle(
            fontFamily: 'monospace',
            fontFamilyFallback: const ['Menlo', 'Courier'],
            fontSize: 10,
            height: 1.4,
            color: isDark
                ? const Color(0xFF8A929D)
                : const Color(0xFF5D6670),
          ),
        ),
      ),
    );
  }
}
