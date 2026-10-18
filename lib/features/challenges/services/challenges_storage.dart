import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ChallengesStorageData {
  final Set<String> completedChallenges;
  final Set<String> dailyCompletedDates; // 'YYYY-MM-DD'

  const ChallengesStorageData({
    this.completedChallenges = const {},
    this.dailyCompletedDates = const {},
  });

  static const empty = ChallengesStorageData();

  ChallengesStorageData copyWith({
    Set<String>? completedChallenges,
    Set<String>? dailyCompletedDates,
  }) {
    return ChallengesStorageData(
      completedChallenges: completedChallenges ?? this.completedChallenges,
      dailyCompletedDates: dailyCompletedDates ?? this.dailyCompletedDates,
    );
  }

  Map<String, dynamic> toJson() => {
        'completedChallenges': completedChallenges.toList(),
        'dailyCompletedDates': dailyCompletedDates.toList(),
      };

  factory ChallengesStorageData.fromJson(Map<String, dynamic> j) {
    return ChallengesStorageData(
      completedChallenges:
          Set<String>.from(j['completedChallenges'] as List? ?? []),
      dailyCompletedDates:
          Set<String>.from(j['dailyCompletedDates'] as List? ?? []),
    );
  }
}

class ChallengesStorage {
  ChallengesStorage._();
  static final ChallengesStorage instance = ChallengesStorage._();

  static const _key = 'challenges_v1';

  Future<ChallengesStorageData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return ChallengesStorageData.empty;
    try {
      return ChallengesStorageData.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      await prefs.remove(_key);
      return ChallengesStorageData.empty;
    }
  }

  Future<void> save(ChallengesStorageData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
