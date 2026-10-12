import 'package:flutter/material.dart';

enum LearnerLevel { beginner, explorer, builder, developer, master }

class LearnerLevelInfo {
  final LearnerLevel level;
  final String label;
  final int xpThreshold;
  final Color color;
  final IconData icon;

  const LearnerLevelInfo({
    required this.level,
    required this.label,
    required this.xpThreshold,
    required this.color,
    required this.icon,
  });
}

/// Stable, ordered list of all levels. The active level is the highest
/// one whose threshold is <= currentXP.
const List<LearnerLevelInfo> kLearnerLevels = [
  LearnerLevelInfo(
    level: LearnerLevel.beginner,
    label: 'Beginner',
    xpThreshold: 0,
    color: Color(0xFF94A3B8),
    icon: Icons.person_outline,
  ),
  LearnerLevelInfo(
    level: LearnerLevel.explorer,
    label: 'Explorer',
    xpThreshold: 200,
    color: Color(0xFF00B894),
    icon: Icons.explore_outlined,
  ),
  LearnerLevelInfo(
    level: LearnerLevel.builder,
    label: 'Builder',
    xpThreshold: 500,
    color: Color(0xFF6C5CE7),
    icon: Icons.construction_outlined,
  ),
  LearnerLevelInfo(
    level: LearnerLevel.developer,
    label: 'Developer',
    xpThreshold: 1000,
    color: Color(0xFF0984E3),
    icon: Icons.terminal_outlined,
  ),
  LearnerLevelInfo(
    level: LearnerLevel.master,
    label: 'Master',
    xpThreshold: 2000,
    color: Color(0xFFFFB020),
    icon: Icons.workspace_premium_outlined,
  ),
];

LearnerLevelInfo learnerLevelFor(int xp) {
  var current = kLearnerLevels.first;
  for (final lvl in kLearnerLevels) {
    if (xp >= lvl.xpThreshold) current = lvl;
  }
  return current;
}

/// Next level above [xp], or null if already at the top.
LearnerLevelInfo? nextLearnerLevelFor(int xp) {
  for (final lvl in kLearnerLevels) {
    if (lvl.xpThreshold > xp) return lvl;
  }
  return null;
}
