import 'package:flutter/material.dart';

import '../../../core/routing/app_routes.dart';
import '../../learning/models/lesson.dart';

/// Bottom sheet preview shown when a lesson node is tapped on the path.
/// Reuses the existing lesson-detail route — this is just an intermediate
/// step that gives the user context before committing.
class LessonStartSheet extends StatelessWidget {
  final Lesson lesson;

  const LessonStartSheet({super.key, required this.lesson});

  /// Convenience entry point. Returns the future from showModalBottomSheet.
  static Future<void> show(BuildContext context, Lesson lesson) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF141820)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => LessonStartSheet(lesson: lesson),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = lesson.track.color;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Track + difficulty chip strip
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _Chip(
                  label: lesson.track.label,
                  color: accent,
                ),
                _Chip(
                  label: lesson.difficulty.label,
                  color: lesson.difficulty.color,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_outline,
                          size: 13, color: Color(0xFF6C5CE7)),
                      const SizedBox(width: 3),
                      Text(
                        '+${lesson.xpReward} XP',
                        style: const TextStyle(
                          color: Color(0xFF6C5CE7),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Title
            Text(
              lesson.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),

            // Description
            Text(
              lesson.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    color:
                        Theme.of(context).textTheme.bodyMedium?.color?.withValues(
                              alpha: 0.85,
                            ),
                  ),
            ),
            const SizedBox(height: 14),

            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _MetaItem(
                  icon: Icons.schedule,
                  label: '${lesson.estimatedMinutes} min',
                ),
                _MetaItem(
                  icon: Icons.quiz_outlined,
                  label: '${lesson.quizQuestions.length} questions',
                ),
                if (lesson.isCompleted)
                  const _MetaItem(
                    icon: Icons.check_circle,
                    label: 'Completed',
                    color: Color(0xFF00B894),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Primary action
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: accent,
              ),
              icon: Icon(
                lesson.isCompleted ? Icons.replay : Icons.play_arrow,
              ),
              label: Text(
                lesson.isCompleted
                    ? 'Review lesson'
                    : 'Start lesson',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () => _open(context),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);
    final args = LessonDetailArguments(lessonId: lesson.id);
    navigator.pop(); // close sheet first
    navigator.pushNamed(
      AppRoutes.lessonDetail,
      arguments: args,
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _MetaItem({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).textTheme.bodySmall?.color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c),
        ),
      ],
    );
  }
}
