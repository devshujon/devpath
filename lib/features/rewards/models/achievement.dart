import 'package:flutter/material.dart';

/// Condition types supported by the engine. Each maps to a single
/// counter on [AchievementContext]. Keep this stable — values are
/// persisted (in JSON) and used by the catalog.
enum AchievementCondition {
  lessonsCompleted,
  challengesCompleted,
  projectsCreated,
  streakDays,
  xpTotal,
  dailyChallengesCompleted,
  miniProjectsCompleted,
  certificatesEarned;

  String get key => switch (this) {
        AchievementCondition.lessonsCompleted => 'lessons_completed',
        AchievementCondition.challengesCompleted => 'challenges_completed',
        AchievementCondition.projectsCreated => 'projects_created',
        AchievementCondition.streakDays => 'streak_days',
        AchievementCondition.xpTotal => 'xp_total',
        AchievementCondition.dailyChallengesCompleted =>
          'daily_challenges_completed',
        AchievementCondition.miniProjectsCompleted =>
          'mini_projects_completed',
        AchievementCondition.certificatesEarned => 'certificates_earned',
      };

  /// Short human label for UI summaries ("Lessons completed", etc.).
  String get label => switch (this) {
        AchievementCondition.lessonsCompleted => 'Lessons completed',
        AchievementCondition.challengesCompleted => 'Challenges completed',
        AchievementCondition.projectsCreated => 'Projects created',
        AchievementCondition.streakDays => 'Day streak',
        AchievementCondition.xpTotal => 'Total XP',
        AchievementCondition.dailyChallengesCompleted =>
          'Daily challenges',
        AchievementCondition.miniProjectsCompleted =>
          'Mini projects completed',
        AchievementCondition.certificatesEarned => 'Certificates earned',
      };

  static AchievementCondition fromKey(String key) {
    return AchievementCondition.values.firstWhere(
      (c) => c.key == key,
      orElse: () => AchievementCondition.lessonsCompleted,
    );
  }
}

/// Read-only snapshot of all counters the engine evaluates against.
/// Constructed by [RewardsProvider] from the other providers.
class AchievementContext {
  final int lessonsCompleted;
  final int challengesCompleted;
  final int projectsCreated;
  final int streakDays;
  final int xpTotal;
  final int dailyChallengesCompleted;
  final int miniProjectsCompleted;
  final int certificatesEarned;

  const AchievementContext({
    required this.lessonsCompleted,
    required this.challengesCompleted,
    required this.projectsCreated,
    required this.streakDays,
    required this.xpTotal,
    required this.dailyChallengesCompleted,
    this.miniProjectsCompleted = 0,
    this.certificatesEarned = 0,
  });

  static const empty = AchievementContext(
    lessonsCompleted: 0,
    challengesCompleted: 0,
    projectsCreated: 0,
    streakDays: 0,
    xpTotal: 0,
    dailyChallengesCompleted: 0,
    miniProjectsCompleted: 0,
    certificatesEarned: 0,
  );

  int valueFor(AchievementCondition c) => switch (c) {
        AchievementCondition.lessonsCompleted => lessonsCompleted,
        AchievementCondition.challengesCompleted => challengesCompleted,
        AchievementCondition.projectsCreated => projectsCreated,
        AchievementCondition.streakDays => streakDays,
        AchievementCondition.xpTotal => xpTotal,
        AchievementCondition.dailyChallengesCompleted =>
          dailyChallengesCompleted,
        AchievementCondition.miniProjectsCompleted => miniProjectsCompleted,
        AchievementCondition.certificatesEarned => certificatesEarned,
      };
}

/// A single achievement definition. The catalog supplies these as
/// const data; the provider attaches [isUnlocked] / [unlockedAt] at
/// read time via [copyWith].
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int xpReward;
  final AchievementCondition conditionType;
  final int targetValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.xpReward,
    required this.conditionType,
    required this.targetValue,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
    bool clearUnlockedAt = false,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      color: color,
      xpReward: xpReward,
      conditionType: conditionType,
      targetValue: targetValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: clearUnlockedAt ? null : (unlockedAt ?? this.unlockedAt),
    );
  }

  /// Progress toward unlock as a 0..1 ratio against [targetValue].
  double progress(AchievementContext ctx) {
    final actual = ctx.valueFor(conditionType);
    if (targetValue <= 0) return 1.0;
    return (actual / targetValue).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        // Icon is serialized as codePoint + fontFamily — sufficient for
        // round-tripping built-in Material icons.
        'icon': icon.codePoint,
        'iconFamily': icon.fontFamily,
        'color': color.toARGB32(),
        'xpReward': xpReward,
        'conditionType': conditionType.key,
        'targetValue': targetValue,
        'isUnlocked': isUnlocked,
        if (unlockedAt != null) 'unlockedAt': unlockedAt!.toIso8601String(),
      };

  factory Achievement.fromJson(Map<String, dynamic> j) => Achievement(
        id: j['id'] as String,
        title: j['title'] as String,
        description: j['description'] as String,
        // IconData has a const constructor; the analyzer prefers const
        // call sites, but our codePoint / fontFamily come from JSON at
        // runtime and cannot be const. Suppress the lint here.
        // ignore: non_const_argument_for_const_parameter
        icon: IconData(
          // ignore: non_const_argument_for_const_parameter
          j['icon'] as int,
          // ignore: non_const_argument_for_const_parameter
          fontFamily: j['iconFamily'] as String? ?? 'MaterialIcons',
        ),
        color: Color(j['color'] as int),
        xpReward: j['xpReward'] as int,
        conditionType:
            AchievementCondition.fromKey(j['conditionType'] as String),
        targetValue: j['targetValue'] as int,
        isUnlocked: j['isUnlocked'] as bool? ?? false,
        unlockedAt: j['unlockedAt'] != null
            ? DateTime.parse(j['unlockedAt'] as String)
            : null,
      );
}
