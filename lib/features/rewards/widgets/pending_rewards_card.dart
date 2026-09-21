import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/achievement.dart';
import '../providers/rewards_provider.dart';
import 'achievement_unlock_overlay.dart';

/// Returns an empty widget when there are no pending rewards. Lets the
/// dashboard render unconditionally without each consumer having to do
/// its own visibility logic.
class PendingRewardsCard extends StatelessWidget {
  const PendingRewardsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final rewards = context.watch<RewardsProvider>();
    final pending = rewards.pendingRewards;

    if (pending.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = pending.first.color;

    return Material(
      borderRadius: BorderRadius.circular(14),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _claimNext(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accent, accent.withValues(alpha: 0.75)],
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: isDark ? 0.3 : 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  pending.first.icon,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pending.length == 1
                          ? 'New achievement!'
                          : '${pending.length} new achievements!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pending.first.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _claimNext(BuildContext context) async {
    final rewards = context.read<RewardsProvider>();
    Achievement? next = rewards.consumeNextCelebration();
    while (next != null && context.mounted) {
      await AchievementUnlockOverlay.show(context, achievement: next);
      if (!context.mounted) break;
      next = rewards.consumeNextCelebration();
    }
  }
}
