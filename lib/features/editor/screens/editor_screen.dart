import 'package:flutter/material.dart';

import '../../../core/routing/app_routes.dart';
import '../services/lesson_templates.dart';

/// Hub for editor-related features. Surfaces three entry points:
///   - Playground (free-form HTML/CSS/JS sandbox)
///   - Lessons (starter templates)
///   - My Projects (saved playground projects)
class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editor')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HubCard(
              icon: Icons.play_circle_outline,
              title: 'Playground',
              subtitle: 'Write HTML, CSS, and JS. Run instantly.',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.playground),
              primary: true,
            ),
            const SizedBox(height: 12),
            _HubCard(
              icon: Icons.school_outlined,
              title: 'Lessons',
              subtitle:
                  '${LessonTemplates.all.length} starter templates to learn from.',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.lessons),
            ),
            const SizedBox(height: 12),
            _HubCard(
              icon: Icons.folder_outlined,
              title: 'My Projects',
              subtitle: 'Continue work you saved.',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.projects),
            ),
          ],
        ),
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool primary;

  const _HubCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: primary
          ? primaryColor.withValues(alpha: isDark ? 0.18 : 0.08)
          : (isDark ? const Color(0xFF141820) : Colors.white),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: primary
                  ? primaryColor.withValues(alpha: 0.35)
                  : (isDark
                      ? const Color(0xFF262B35)
                      : const Color(0xFFE4E7EE)),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: primaryColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
