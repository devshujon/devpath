import 'package:flutter/material.dart';

import '../models/lesson.dart';

/// Horizontal track filter chips used on Learn and Roadmap screens.
class TrackFilterRow extends StatelessWidget {
  final LessonTrack? selected;
  final ValueChanged<LessonTrack?> onChanged;

  const TrackFilterRow({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: 'All',
            color: Theme.of(context).colorScheme.primary,
            selected: selected == null,
            onTap: () => onChanged(null),
          ),
          for (final track in LessonTrack.filterChips) ...[
            const SizedBox(width: 8),
            _Chip(
              label: _chipLabel(track),
              color: track.color,
              selected: selected == track,
              onTap: () => onChanged(track),
            ),
          ],
        ],
      ),
    );
  }

  static String _chipLabel(LessonTrack track) {
    if (track == LessonTrack.webEssentials) return 'Web Dev';
    return track.label;
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: color.withValues(alpha: 0.25),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: selected ? color : null,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 13,
      ),
      side: BorderSide(color: selected ? color : Theme.of(context).dividerColor),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
