import 'package:flutter/material.dart';

import '../../../core/routing/app_routes.dart';
import '../services/lesson_templates.dart';

class LessonPickerScreen extends StatelessWidget {
  const LessonPickerScreen({super.key});
  static const route = '/lessons';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lessons')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: LessonTemplates.all.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final lesson = LessonTemplates.all[i];
          return _LessonTile(
            number: i + 1,
            lesson: lesson,
            onTap: () => _openLesson(context, lesson.id),
          );
        },
      ),
    );
  }

  void _openLesson(BuildContext context, String lessonId) {
    Navigator.pushNamed(
      context,
      AppRoutes.playground,
      arguments: PlaygroundArguments(lessonId: lessonId),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final int number;
  final LessonTemplate lesson;
  final VoidCallback onTap;

  const _LessonTile({
    required this.number,
    required this.lesson,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF141820) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF262B35) : const Color(0xFFE4E7EE);

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lesson.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
