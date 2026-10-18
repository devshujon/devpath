import 'package:flutter/material.dart';

import '../models/track_project.dart';
import 'project_preview.dart';

class TrackProjectCard extends StatelessWidget {
  final TrackProject project;
  final TrackProjectStatus status;
  final VoidCallback? onTap;

  const TrackProjectCard({
    super.key,
    required this.project,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF141820) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF262B35) : const Color(0xFFE4E7EE);
    final isLocked = status == TrackProjectStatus.locked;
    final isCompleted = status == TrackProjectStatus.completed;
    final isInProgress = status == TrackProjectStatus.inProgress;

    return Opacity(
      opacity: isLocked ? 0.55 : 1.0,
      child: Material(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isLocked ? null : onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ProjectPreview(
                      project: project,
                      height: 100,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                    ),
                    if (isCompleted)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B894),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check,
                                  color: Colors.white, size: 12),
                              SizedBox(width: 3),
                              Text(
                                'Done',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (isInProgress)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB020),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'In progress',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    else if (isLocked)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.5),
                          child: const Center(
                            child: Icon(Icons.lock,
                                color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  project.difficulty.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              project.difficulty.label,
                              style: TextStyle(
                                color: project.difficulty.color,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.star_outline,
                              size: 12, color: Color(0xFF6C5CE7)),
                          const SizedBox(width: 2),
                          Text(
                            '+${project.xpReward}',
                            style: const TextStyle(
                              color: Color(0xFF6C5CE7),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
