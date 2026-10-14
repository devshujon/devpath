import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/achievement.dart';

class AchievementTile extends StatelessWidget {
  final Achievement achievement;

  /// Progress 0..1 toward the target. Used when locked.
  final double progress;

  /// Actual counter value (e.g. "3 / 7").
  final int currentValue;

  const AchievementTile({
    super.key,
    required this.achievement,
    required this.progress,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF141820) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF262B35) : const Color(0xFFE4E7EE);
    final fgMuted =
        isDark ? const Color(0xFF8A929D) : const Color(0xFF5D6670);

    final unlocked = achievement.isUnlocked;
    final tileBorderColor = unlocked
        ? achievement.color.withValues(alpha: 0.45)
        : borderColor;

    return Opacity(
      opacity: unlocked ? 1.0 : 0.92,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tileBorderColor, width: unlocked ? 1.2 : 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: unlocked
                    ? achievement.color.withValues(alpha: 0.18)
                    : (isDark
                        ? const Color(0xFF1E232C)
                        : const Color(0xFFF2F4F8)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                unlocked ? achievement.icon : Icons.lock_outline,
                color: unlocked
                    ? achievement.color
                    : fgMuted,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (unlocked) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.check_circle,
                          color: achievement.color,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    achievement.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  if (unlocked)
                    _UnlockedFooter(
                      ach: achievement,
                      fgMuted: fgMuted,
                    )
                  else
                    _LockedProgress(
                      ach: achievement,
                      progress: progress,
                      currentValue: currentValue,
                      fgMuted: fgMuted,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnlockedFooter extends StatelessWidget {
  final Achievement ach;
  final Color fgMuted;
  const _UnlockedFooter({required this.ach, required this.fgMuted});

  @override
  Widget build(BuildContext context) {
    final unlockedAt = ach.unlockedAt;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF6C5CE7).withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '+${ach.xpReward} XP',
            style: const TextStyle(
              color: Color(0xFF6C5CE7),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (unlockedAt != null) ...[
          const SizedBox(width: 8),
          Icon(Icons.schedule, size: 11, color: fgMuted),
          const SizedBox(width: 3),
          Text(
            DateFormat.yMMMd().format(unlockedAt),
            style: TextStyle(fontSize: 11, color: fgMuted),
          ),
        ],
      ],
    );
  }
}

class _LockedProgress extends StatelessWidget {
  final Achievement ach;
  final double progress;
  final int currentValue;
  final Color fgMuted;

  const _LockedProgress({
    required this.ach,
    required this.progress,
    required this.currentValue,
    required this.fgMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: ach.color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(ach.color),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '$currentValue / ${ach.targetValue}',
              style: TextStyle(fontSize: 11, color: fgMuted),
            ),
            const Spacer(),
            Text(
              '+${ach.xpReward} XP',
              style: TextStyle(
                fontSize: 11,
                color: fgMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
