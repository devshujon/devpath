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
      completedLessons: _stringSet(j['completedLessons']),
      currentXP: _asInt(j['currentXP']),
      streakDays: _asInt(j['streakDays']),
      longestStreak: _asInt(j['longestStreak']),
      totalMinutesLearned: _asInt(j['totalMinutesLearned']),
      lastActiveDate: _asDate(j['lastActiveDate']),
      earnedBadges: _stringSet(j['earnedBadges']),
    );
  }

  static int _asInt(Object? v, [int fallback = 0]) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static DateTime? _asDate(Object? v) {
    if (v is! String || v.isEmpty) return null;
    return DateTime.tryParse(v);
  }

  static Set<String> _stringSet(Object? v) {
    if (v is! List) return {};
    return {
      for (final e in v)
        if (e is String && e.isNotEmpty)
          e
        else if (e != null && '$e'.isNotEmpty)
          '$e',
    };
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
