import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/track_project.dart';
import '../providers/projects_track_provider.dart';
import 'project_preview.dart';

/// Resumes the most-recently-opened in-progress project. Returns
/// SizedBox.shrink() when nothing is in progress — same conditional
/// pattern as PendingRewardsCard so the dashboard layout collapses.
class ContinueProjectCard extends StatelessWidget {
  final void Function(TrackProject) onContinue;

  const ContinueProjectCard({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectsTrackProvider>();
    final project = provider.continueCandidate();
    if (project == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF141820) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF262B35) : const Color(0xFFE4E7EE);

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onContinue(project),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: ProjectPreview(
                  project: project,
                  height: 76,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.play_circle_fill,
                            color: Color(0xFFFFB020), size: 16),
                        SizedBox(width: 4),
                        Text(
                          'CONTINUE PROJECT',
                          style: TextStyle(
                            color: Color(0xFFFFB020),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      project.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
