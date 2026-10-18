import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/projects_track_provider.dart';

class ProjectsTrackCard extends StatelessWidget {
  final VoidCallback onTap;

  const ProjectsTrackCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectsTrackProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accent = Color(0xFFE17055);
    final completed = provider.completedCount;
    final total = provider.totalCount;
    final inProgress = provider.inProgressCount;
    final ratio = total == 0 ? 0.0 : completed / total;

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
                child: const Icon(
                  Icons.build_circle_outlined,
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
                          'Mini Projects',
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
                          '$completed / $total',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      inProgress > 0
                          ? '$inProgress in progress · build real projects to earn XP'
                          : 'Build real projects to earn XP',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                          valueColor: const AlwaysStoppedAnimation(accent),
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
