import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../models/challenge.dart';
import '../providers/challenges_provider.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});
  static const route = '/challenges';

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChallengesProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final challenges = context.watch<ChallengesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: challenges.totalCount == 0
                ? 0
                : challenges.completedCount / challenges.totalCount,
            minHeight: 4,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final difficulty in [
            Difficulty.beginner,
            Difficulty.intermediate,
          ]) ...[
            _DifficultyHeader(
              difficulty: difficulty,
              completed: ChallengeListSplit(challenges).completedIn(difficulty),
              total: ChallengeListSplit(challenges).totalIn(difficulty),
            ),
            const SizedBox(height: 10),
            ...challenges.all
                .where((c) => c.difficulty == difficulty)
                .map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ChallengeRow(
                      challenge: c,
                      locked: challenges.isLocked(c),
                      completed: challenges.isCompleted(c.id),
                      onTap: () => _open(context, c),
                    ),
                  ),
                ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  void _open(BuildContext context, Challenge c) {
    Navigator.pushNamed(
      context,
      AppRoutes.challenge,
      arguments: ChallengeRouteArguments(challengeId: c.id),
    );
  }
}

class ChallengeListSplit {
  final ChallengesProvider _provider;
  ChallengeListSplit(this._provider);

  int totalIn(Difficulty d) =>
      _provider.all.where((c) => c.difficulty == d).length;

  int completedIn(Difficulty d) => _provider.all
      .where(
          (c) => c.difficulty == d && _provider.isCompleted(c.id))
      .length;
}

class _DifficultyHeader extends StatelessWidget {
  final Difficulty difficulty;
  final int completed;
  final int total;

  const _DifficultyHeader({
    required this.difficulty,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 24,
              decoration: BoxDecoration(
                color: difficulty.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              difficulty.label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Spacer(),
            Text(
              '$completed / $total',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: difficulty.color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(difficulty.color),
          ),
        ),
      ],
    );
  }
}

class _ChallengeRow extends StatelessWidget {
  final Challenge challenge;
  final bool locked;
  final bool completed;
  final VoidCallback onTap;

  const _ChallengeRow({
    required this.challenge,
    required this.locked,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF141820) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF262B35) : const Color(0xFFE4E7EE);

    final leadingIcon = completed
        ? Icons.check_circle
        : locked
            ? Icons.lock_outline
            : Icons.terminal;
    final leadingColor = completed
        ? const Color(0xFF00B894)
        : locked
            ? (isDark
                ? const Color(0xFF5D6670)
                : const Color(0xFF94A3B8))
            : Theme.of(context).colorScheme.primary;

    return Opacity(
      opacity: locked ? 0.55 : 1.0,
      child: Material(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: locked ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(leadingIcon, color: leadingColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        challenge.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.star_outline,
                            size: 11,
                            color: isDark
                                ? const Color(0xFF8A929D)
                                : const Color(0xFF5D6670),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '+${challenge.xpReward} XP',
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
                if (!locked) const Icon(Icons.chevron_right, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChallengeRouteArguments {
  final String challengeId;

  /// When true, completion grants daily bonus XP and marks the daily.
  /// The dashboard's "Today's Challenge" entry sets this.
  final bool isDailyEntry;

  const ChallengeRouteArguments({
    required this.challengeId,
    this.isDailyEntry = false,
  });
}
