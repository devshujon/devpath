import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/rewards_provider.dart';

class RecentUnlocksCard extends StatelessWidget {
  final VoidCallback onSeeAll;

  const RecentUnlocksCard({super.key, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final rewards = context.watch<RewardsProvider>();
    final recent = rewards.recentUnlocks(limit: 6);

    if (recent.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.workspace_premium_outlined, size: 18),
            const SizedBox(width: 8),
            Text(
              'Recent unlocks',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
            ),
            const Spacer(),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onSeeAll,
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: recent.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final ach = recent[i];
              return SizedBox(
                width: 96,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141820) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ach.color.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: ach.color.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(ach.icon, color: ach.color, size: 18),
                      ),
                      const Spacer(),
                      Text(
                        ach.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
