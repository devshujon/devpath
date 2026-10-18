import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/learning_progress_provider.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<LearningProgressProvider>();
    final days = progress.streakDays;
    final minutes = progress.totalMinutesLearned;

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.local_fire_department,
            iconColor: const Color(0xFFFF6B35),
            value: '$days',
            unit: days == 1 ? 'day' : 'days',
            label: 'Streak',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.schedule,
            iconColor: const Color(0xFF6C5CE7),
            value: '$minutes',
            unit: 'min',
            label: 'Learned',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.check_circle_outline,
            iconColor: const Color(0xFF00B894),
            value: '${(progress.overallProgress() * 100).round()}',
            unit: '%',
            label: 'Done',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String unit;
  final String label;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.unit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141820) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDark ? const Color(0xFF262B35) : const Color(0xFFE4E7EE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 8),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
              children: [
                TextSpan(text: value),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFF8A929D)
                        : const Color(0xFF5D6670),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? const Color(0xFF8A929D)
                      : const Color(0xFF5D6670),
                ),
          ),
        ],
      ),
    );
  }
}
