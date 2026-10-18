import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/rewards_provider.dart';

/// Compact dashboard card showing unlocked / total progress, with a
/// tap target that opens the full achievements screen.
class AchievementCard extends StatelessWidget {
  final VoidCallback onTap;

  const AchievementCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rewards = context.watch<RewardsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = const Color(0xFFFFB020);
    final unlocked = rewards.unlockedCount;
    final total = rewards.totalAchievements;
    final ratio = total == 0 ? 0.0 : unlocked / total;

    return Material(
      color: isDark ? const Color(0xFF141820) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF262B35)
                  : const Color(0xFFE4E7EE),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.emoji_events_outlined,
                  color: accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Achievements',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          '$unlocked / $total',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: ratio),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => LinearProgressIndicator(
                          value: v,
                          minHeight: 6,
                          backgroundColor: accent.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation(accent),
                        ),
                      ),
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
