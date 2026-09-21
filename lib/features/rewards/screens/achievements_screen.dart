import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/achievement.dart';
import '../providers/rewards_provider.dart';
import '../widgets/achievement_tile.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});
  static const route = '/achievements';

  @override
  Widget build(BuildContext context) {
    final rewards = context.watch<RewardsProvider>();
    final ctx = rewards.snapshotContext();
    final all = rewards.all;

    final byCondition = <AchievementCondition, List<Achievement>>{
      for (final c in AchievementCondition.values) c: [],
    };
    for (final a in all) {
      byCondition[a.conditionType]!.add(a);
    }
    // Sort within each group by target ascending so users see progression.
    for (final list in byCondition.values) {
      list.sort((a, b) => a.targetValue.compareTo(b.targetValue));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: rewards.totalAchievements == 0
                ? 0
                : rewards.unlockedCount / rewards.totalAchievements,
            minHeight: 4,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Header(
            unlocked: rewards.unlockedCount,
            total: rewards.totalAchievements,
          ),
          const SizedBox(height: 20),
          for (final entry in byCondition.entries)
            if (entry.value.isNotEmpty) ...[
              _GroupHeader(
                condition: entry.key,
                progressValue: ctx.valueFor(entry.key),
              ),
              const SizedBox(height: 10),
              ...entry.value.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AchievementTile(
                    achievement: a,
                    progress: a.progress(ctx),
                    currentValue: ctx.valueFor(a.conditionType),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int unlocked;
  final int total;
  const _Header({required this.unlocked, required this.total});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = const Color(0xFFFFB020);
    final ratio = total == 0 ? 0.0 : unlocked / total;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, accent.withValues(alpha: 0.75)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.3 : 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Achievements',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '$unlocked of $total unlocked',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final AchievementCondition condition;
  final int progressValue;
  const _GroupHeader({
    required this.condition,
    required this.progressValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          condition.label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const Spacer(),
        Text(
          'Current: $progressValue',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
