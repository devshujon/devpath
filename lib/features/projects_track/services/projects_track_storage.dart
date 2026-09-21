import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProjectsTrackStorageData {
  final Set<String> inProgressIds;
  final Set<String> completedIds;
  final Map<String, DateTime> openedAt;
  final Map<String, DateTime> completedAt;

  const ProjectsTrackStorageData({
    this.inProgressIds = const {},
    this.completedIds = const {},
    this.openedAt = const {},
    this.completedAt = const {},
  });

  static const empty = ProjectsTrackStorageData();

  ProjectsTrackStorageData copyWith({
    Set<String>? inProgressIds,
    Set<String>? completedIds,
    Map<String, DateTime>? openedAt,
    Map<String, DateTime>? completedAt,
  }) {
    return ProjectsTrackStorageData(
      inProgressIds: inProgressIds ?? this.inProgressIds,
      completedIds: completedIds ?? this.completedIds,
      openedAt: openedAt ?? this.openedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'inProgressIds': inProgressIds.toList(),
        'completedIds': completedIds.toList(),
        'openedAt': {
          for (final e in openedAt.entries) e.key: e.value.toIso8601String(),
        },
        'completedAt': {
          for (final e in completedAt.entries) e.key: e.value.toIso8601String(),
        },
      };

  factory ProjectsTrackStorageData.fromJson(Map<String, dynamic> j) {
    final openedRaw = j['openedAt'] as Map<String, dynamic>? ?? const {};
    final completedRaw = j['completedAt'] as Map<String, dynamic>? ?? const {};
    return ProjectsTrackStorageData(
      inProgressIds:
          Set<String>.from(j['inProgressIds'] as List? ?? const []),
      completedIds:
          Set<String>.from(j['completedIds'] as List? ?? const []),
      openedAt: {
        for (final e in openedRaw.entries)
          e.key: DateTime.parse(e.value as String),
      },
      completedAt: {
        for (final e in completedRaw.entries)
          e.key: DateTime.parse(e.value as String),
      },
    );
  }
}

class ProjectsTrackStorage {
  ProjectsTrackStorage._();
  static final ProjectsTrackStorage instance = ProjectsTrackStorage._();

  static const _key = 'projects_track_v1';

  Future<ProjectsTrackStorageData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return ProjectsTrackStorageData.empty;
    try {
      return ProjectsTrackStorageData.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      await prefs.remove(_key);
      return ProjectsTrackStorageData.empty;
    }
  }

  Future<void> save(ProjectsTrackStorageData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
