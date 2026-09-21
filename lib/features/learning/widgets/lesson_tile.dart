import 'package:flutter/material.dart';

import '../logic/lesson_progression.dart';
import '../models/lesson.dart';

class LessonTile extends StatelessWidget {
  final Lesson lesson;
  final int index;
  final VoidCallback? onTap;

  const LessonTile({
    super.key,
    required this.lesson,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF141820) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF262B35) : const Color(0xFFE4E7EE);

    final visual = resolveLessonVisualState(
      isCompleted: lesson.isCompleted,
      isLocked: lesson.isLocked,
    );
    final disabled = visual == LessonVisualState.locked;
    final completed = visual == LessonVisualState.completed;

    final leadingIcon = completed
        ? Icons.check_circle
        : disabled
            ? Icons.lock_outline
            : Icons.play_circle_outline;
    final leadingColor = completed
        ? const Color(0xFF00B894)
        : disabled
            ? (isDark
                ? const Color(0xFF5D6670)
                : const Color(0xFF94A3B8))
            : Theme.of(context).colorScheme.primary;

    return Opacity(
      opacity: disabled ? 0.55 : 1.0,
      child: Semantics(
        button: !disabled,
        enabled: !disabled,
        label: completed
            ? '${lesson.title}, completed'
            : disabled
                ? '${lesson.title}, locked'
                : lesson.title,
        child: Material(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: disabled ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                _IndexBadge(
                  text: '${index + 1}',
                  color: lesson.difficulty.color,
                  faded: disabled,
                ),
                const SizedBox(width: 12),
                Icon(leadingIcon, color: leadingColor, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lesson.description,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 11,
                            color: isDark
                                ? const Color(0xFF8A929D)
                                : const Color(0xFF5D6670),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${lesson.estimatedMinutes} min',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? const Color(0xFF8A929D)
                                  : const Color(0xFF5D6670),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.star_outline,
                            size: 11,
                            color: isDark
                                ? const Color(0xFF8A929D)
                                : const Color(0xFF5D6670),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '+${lesson.xpReward} XP',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? const Color(0xFF8A929D)
                                  : const Color(0xFF5D6670),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!disabled)
                  const Icon(Icons.chevron_right, size: 20),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _IndexBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool faded;

  const _IndexBadge({
    required this.text,
    required this.color,
    this.faded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: faded ? 0.08 : 0.14),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}
