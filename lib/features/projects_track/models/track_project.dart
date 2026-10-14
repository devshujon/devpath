import 'package:flutter/material.dart';

import '../../learning/models/lesson.dart' show Difficulty;

export '../../learning/models/lesson.dart' show Difficulty, DifficultyMeta;

/// A curated project the user is expected to build after lessons.
/// Unlike free-form playground projects (see ProjectsListProvider),
/// these have a fixed starter template, required-lesson gating, and
/// fixed completion XP. Completion is user-attested via "Mark Complete"
/// — we don't validate the produced code (that's what challenges
/// are for).
class TrackProject {
  final String id;
  final String title;
  final String description;
  final Difficulty difficulty;

  /// Lesson IDs the user must finish before this project unlocks.
  final List<String> requiredLessons;

  final List<String> instructions;

  final String starterHtml;
  final String starterCss;
  final String starterJs;

  /// XP awarded on "Mark Complete". By convention:
  ///   beginner = 100, intermediate = 200, advanced = 400.
  final int xpReward;

  /// Icon shown on the gradient placeholder (no image assets — keeps
  /// the APK lean for tier-2 markets).
  final IconData previewIcon;

  /// Two-stop gradient for the preview placeholder.
  final List<Color> previewGradient;

  const TrackProject({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.requiredLessons,
    required this.instructions,
    required this.starterHtml,
    required this.starterCss,
    required this.starterJs,
    required this.xpReward,
    required this.previewIcon,
    required this.previewGradient,
  });
}

enum TrackProjectStatus { locked, notStarted, inProgress, completed }
