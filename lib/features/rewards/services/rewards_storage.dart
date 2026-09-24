import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RewardsStorageData {
  final Set<String> unlockedIds;
  final Map<String, DateTime> unlockedAt;
  final Set<String> acknowledgedIds;

  const RewardsStorageData({
    this.unlockedIds = const {},
    this.unlockedAt = const {},
    this.acknowledgedIds = const {},
  });

  static const empty = RewardsStorageData();

  RewardsStorageData copyWith({
    Set<String>? unlockedIds,
    Map<String, DateTime>? unlockedAt,
    Set<String>? acknowledgedIds,
  }) {
    return RewardsStorageData(
      unlockedIds: unlockedIds ?? this.unlockedIds,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      acknowledgedIds: acknowledgedIds ?? this.acknowledgedIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'unlockedIds': unlockedIds.toList(),
        'unlockedAt': {
          for (final e in unlockedAt.entries) e.key: e.value.toIso8601String(),
        },
        'acknowledgedIds': acknowledgedIds.toList(),
      };

  factory RewardsStorageData.fromJson(Map<String, dynamic> j) {
    final atRaw = j['unlockedAt'] as Map<String, dynamic>? ?? const {};
    return RewardsStorageData(
      unlockedIds: Set<String>.from(j['unlockedIds'] as List? ?? const []),
      unlockedAt: {
        for (final e in atRaw.entries) e.key: DateTime.parse(e.value as String),
      },
      acknowledgedIds:
          Set<String>.from(j['acknowledgedIds'] as List? ?? const []),
    );
  }
}

class RewardsStorage {
  RewardsStorage._();
  static final RewardsStorage instance = RewardsStorage._();

  static const _key = 'rewards_v1';

  Future<RewardsStorageData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return RewardsStorageData.empty;
    try {
      return RewardsStorageData.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      await prefs.remove(_key);
      return RewardsStorageData.empty;
    }
  }

  Future<void> save(RewardsStorageData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
