import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persistent shape of learning progress. Stored under a single
/// SharedPreferences key as JSON.
class LearningProgressData {
  final Set<String> completedLessons;
  final int currentXP;
  final int streakDays;
  final int longestStreak;
  final int totalMinutesLearned;
  final DateTime? lastActiveDate;
  final Set<String> earnedBadges;

  const LearningProgressData({
    this.completedLessons = const {},
    this.currentXP = 0,
    this.streakDays = 0,
    this.longestStreak = 0,
    this.totalMinutesLearned = 0,
    this.lastActiveDate,
    this.earnedBadges = const {},
  });

  static const empty = LearningProgressData();

  LearningProgressData copyWith({
    Set<String>? completedLessons,
    int? currentXP,
    int? streakDays,
    int? longestStreak,
    int? totalMinutesLearned,
    DateTime? lastActiveDate,
    Set<String>? earnedBadges,
    bool clearLastActive = false,
  }) {
    return LearningProgressData(
      completedLessons: completedLessons ?? this.completedLessons,
      currentXP: currentXP ?? this.currentXP,
      streakDays: streakDays ?? this.streakDays,
      longestStreak: longestStreak ?? this.longestStreak,
      totalMinutesLearned: totalMinutesLearned ?? this.totalMinutesLearned,
      lastActiveDate:
          clearLastActive ? null : (lastActiveDate ?? this.lastActiveDate),
      earnedBadges: earnedBadges ?? this.earnedBadges,
    );
  }

  Map<String, dynamic> toJson() => {
        'completedLessons': completedLessons.toList(),
        'currentXP': currentXP,
        'streakDays': streakDays,
        'longestStreak': longestStreak,
        'totalMinutesLearned': totalMinutesLearned,
        if (lastActiveDate != null)
          'lastActiveDate': lastActiveDate!.toIso8601String(),
        'earnedBadges': earnedBadges.toList(),
      };

  factory LearningProgressData.fromJson(Map<String, dynamic> j) {
    return LearningProgressData(
      completedLessons:
          Set<String>.from(j['completedLessons'] as List? ?? []),
      currentXP: j['currentXP'] as int? ?? 0,
      streakDays: j['streakDays'] as int? ?? 0,
      longestStreak: j['longestStreak'] as int? ?? 0,
      totalMinutesLearned: j['totalMinutesLearned'] as int? ?? 0,
      lastActiveDate: j['lastActiveDate'] != null
          ? DateTime.parse(j['lastActiveDate'] as String)
          : null,
      earnedBadges: Set<String>.from(j['earnedBadges'] as List? ?? []),
    );
  }
}

class LearningStorage {
  LearningStorage._();
  static final LearningStorage instance = LearningStorage._();

  static const _key = 'learning_progress_v1';

  Future<LearningProgressData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return LearningProgressData.empty;
    try {
      return LearningProgressData.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      // Corrupted — wipe and start fresh rather than crash on launch
      await prefs.remove(_key);
      return LearningProgressData.empty;
    }
  }

  Future<void> save(LearningProgressData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data.toJson()));
  }

  /// Dev/test helper. Not exposed in UI.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
