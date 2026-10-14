import 'package:flutter/material.dart';

import 'lesson.dart';

class LearnerBadge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool Function(BadgeContext ctx) earned;

  const LearnerBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.earned,
  });
}

/// Read-only snapshot of progress state used to evaluate badge conditions.
/// Keep this struct narrow — it determines what badges can be expressed.
class BadgeContext {
  final int completedLessonsCount;
  final int streakDays;
  final int savedProjectsCount;

  /// IDs of completed lessons, for module/track-specific checks.
  final Set<String> completedLessonIds;

  /// All lessons in the catalog, used to compute "track mastered" badges.
  final List<Lesson> allLessons;

  const BadgeContext({
    required this.completedLessonsCount,
    required this.streakDays,
    required this.savedProjectsCount,
    required this.completedLessonIds,
    required this.allLessons,
  });

  /// True if every lesson belonging to [module] is in [completedLessonIds].
  ///
  /// Note: with the expanded catalog (37 lessons across 4 tracks), most
  /// modules contain a single lesson — see [isTrackMastered] for the
  /// language-level check used by *_master badges.
  bool isModuleMastered(String module) {
    final inModule = allLessons.where((l) => l.module == module);
    if (inModule.isEmpty) return false;
    return inModule.every((l) => completedLessonIds.contains(l.id));
  }

  /// True if every lesson on [track] is in [completedLessonIds]. This is
  /// what HTML Master / CSS Master / JS Master badges actually want —
  /// they should fire when the whole track is done, not just one lesson.
  bool isTrackMastered(LessonTrack track) {
    final inTrack = allLessons.where((l) => l.track == track);
    if (inTrack.isEmpty) return false;
    return inTrack.every((l) => completedLessonIds.contains(l.id));
  }
}

const List<LearnerBadge> kBadges = [
  LearnerBadge(
    id: 'first_lesson',
    title: 'First Lesson',
    description: 'Completed your first lesson.',
    icon: Icons.flag_outlined,
    color: Color(0xFF00B894),
    earned: _firstLesson,
  ),
  LearnerBadge(
    id: 'streak_7',
    title: '7 Day Streak',
    description: 'Learned 7 days in a row.',
    icon: Icons.local_fire_department,
    color: Color(0xFFFF6B35),
    earned: _streak7,
  ),
  LearnerBadge(
    id: 'projects_10',
    title: '10 Projects',
    description: 'Saved 10 playground projects.',
    icon: Icons.folder_special_outlined,
    color: Color(0xFF6C5CE7),
    earned: _projects10,
  ),
  LearnerBadge(
    id: 'html_master',
    title: 'HTML Master',
    description: 'Completed all HTML lessons.',
    icon: Icons.code,
    color: Color(0xFFE17055),
    earned: _htmlMaster,
  ),
  LearnerBadge(
    id: 'css_master',
    title: 'CSS Master',
    description: 'Completed all CSS lessons.',
    icon: Icons.palette_outlined,
    color: Color(0xFF0984E3),
    earned: _cssMaster,
  ),
  LearnerBadge(
    id: 'js_master',
    title: 'JS Master',
    description: 'Completed all JavaScript lessons.',
    icon: Icons.bolt_outlined,
    color: Color(0xFFFFB020),
    earned: _jsMaster,
  ),
];

// ── Earn predicates — top-level so they can sit in const list ──
bool _firstLesson(BadgeContext c) => c.completedLessonsCount >= 1;
bool _streak7(BadgeContext c) => c.streakDays >= 7;
bool _projects10(BadgeContext c) => c.savedProjectsCount >= 10;
bool _htmlMaster(BadgeContext c) => c.isTrackMastered(LessonTrack.html);
bool _cssMaster(BadgeContext c) => c.isTrackMastered(LessonTrack.css);
bool _jsMaster(BadgeContext c) => c.isTrackMastered(LessonTrack.js);

LearnerBadge? badgeById(String id) {
  for (final b in kBadges) {
    if (b.id == id) return b;
  }
  return null;
}
