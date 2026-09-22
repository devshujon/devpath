import 'package:flutter/material.dart';

/// Multiple-choice question attached to a lesson.
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        if (explanation != null) 'explanation': explanation,
      };

  factory QuizQuestion.fromJson(Map<String, dynamic> j) => QuizQuestion(
        question: j['question'] as String,
        options: List<String>.from(j['options'] as List),
        correctIndex: j['correctIndex'] as int,
        explanation: j['explanation'] as String?,
      );
}

enum Difficulty { beginner, intermediate, advanced }

extension DifficultyMeta on Difficulty {
  String get label => switch (this) {
        Difficulty.beginner => 'Beginner',
        Difficulty.intermediate => 'Intermediate',
        Difficulty.advanced => 'Advanced',
      };

  String get key => switch (this) {
        Difficulty.beginner => 'beginner',
        Difficulty.intermediate => 'intermediate',
        Difficulty.advanced => 'advanced',
      };

  Color get color => switch (this) {
        Difficulty.beginner => const Color(0xFF00B894),
        Difficulty.intermediate => const Color(0xFFFFB020),
        Difficulty.advanced => const Color(0xFFEF4444),
      };
}

/// Curriculum track a lesson belongs to. Used to compute certificate
/// eligibility without hardcoding lesson IDs at the call site.
///
/// [capstone] is a synthesis track for lessons that mix all three
/// languages — it doesn't grant any track-specific certificate but
/// counts toward the Graduate certificate.
enum LessonTrack { html, css, js, capstone }

extension LessonTrackMeta on LessonTrack {
  String get label => switch (this) {
        LessonTrack.html => 'HTML',
        LessonTrack.css => 'CSS',
        LessonTrack.js => 'JavaScript',
        LessonTrack.capstone => 'Capstone',
      };

  String get key => switch (this) {
        LessonTrack.html => 'html',
        LessonTrack.css => 'css',
        LessonTrack.js => 'js',
        LessonTrack.capstone => 'capstone',
      };

  Color get color => switch (this) {
        LessonTrack.html => const Color(0xFFE17055),
        LessonTrack.css => const Color(0xFF0984E3),
        LessonTrack.js => const Color(0xFFFFB020),
        LessonTrack.capstone => const Color(0xFF6C5CE7),
      };
}

/// A single learning unit: explanation + starter code + quiz.
///
/// [isLocked] and [isCompleted] are state fields populated by the
/// provider when reading lessons; the canonical catalog entries
/// always carry defaults (false/false). Use
/// [LearningProgressProvider.lessonWithProgress] to get a decorated
/// copy.
class Lesson {
  final String id;
  final String title;
  final String description;
  final String module;
  final Difficulty difficulty;

  /// Curriculum track this lesson belongs to. Drives certificate
  /// eligibility (HTML/CSS/JS certificates require all lessons of
  /// the matching track). Defaults to [LessonTrack.capstone] when
  /// missing from persisted data so old saves don't crash.
  final LessonTrack track;

  final int estimatedMinutes;
  final int xpReward;
  final Map<String, String> starterCode;
  final List<QuizQuestion> quizQuestions;
  final bool isLocked;
  final bool isCompleted;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.module,
    required this.difficulty,
    required this.track,
    required this.estimatedMinutes,
    required this.xpReward,
    required this.starterCode,
    required this.quizQuestions,
    this.isLocked = false,
    this.isCompleted = false,
  });

  Lesson copyWith({
    bool? isLocked,
    bool? isCompleted,
  }) {
    return Lesson(
      id: id,
      title: title,
      description: description,
      module: module,
      difficulty: difficulty,
      track: track,
      estimatedMinutes: estimatedMinutes,
      xpReward: xpReward,
      starterCode: starterCode,
      quizQuestions: quizQuestions,
      isLocked: isLocked ?? this.isLocked,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'module': module,
        'difficulty': difficulty.key,
        'track': track.key,
        'estimatedMinutes': estimatedMinutes,
        'xpReward': xpReward,
        'starterCode': starterCode,
        'quizQuestions': quizQuestions.map((q) => q.toJson()).toList(),
        'isLocked': isLocked,
        'isCompleted': isCompleted,
      };

  factory Lesson.fromJson(Map<String, dynamic> j) => Lesson(
        id: j['id'] as String,
        title: j['title'] as String,
        description: j['description'] as String,
        module: j['module'] as String,
        difficulty: Difficulty.values.firstWhere(
          (d) => d.key == (j['difficulty'] as String),
          orElse: () => Difficulty.beginner,
        ),
        track: LessonTrack.values.firstWhere(
          (t) => t.key == (j['track'] as String? ?? 'capstone'),
          orElse: () => LessonTrack.capstone,
        ),
        estimatedMinutes: j['estimatedMinutes'] as int,
        xpReward: j['xpReward'] as int,
        starterCode: Map<String, String>.from(j['starterCode'] as Map),
        quizQuestions: (j['quizQuestions'] as List)
            .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
            .toList(),
        isLocked: j['isLocked'] as bool? ?? false,
        isCompleted: j['isCompleted'] as bool? ?? false,
      );
}
