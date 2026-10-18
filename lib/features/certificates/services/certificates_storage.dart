import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CertificatesStorageData {
  final Set<String> earnedIds;
  final Map<String, DateTime> earnedAt;

  const CertificatesStorageData({
    this.earnedIds = const {},
    this.earnedAt = const {},
  });

  static const empty = CertificatesStorageData();

  CertificatesStorageData copyWith({
    Set<String>? earnedIds,
    Map<String, DateTime>? earnedAt,
  }) {
    return CertificatesStorageData(
      earnedIds: earnedIds ?? this.earnedIds,
      earnedAt: earnedAt ?? this.earnedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'earnedIds': earnedIds.toList(),
        'earnedAt': {
          for (final e in earnedAt.entries) e.key: e.value.toIso8601String(),
        },
      };

  factory CertificatesStorageData.fromJson(Map<String, dynamic> j) {
    final raw = j['earnedAt'] as Map<String, dynamic>? ?? const {};
    return CertificatesStorageData(
      earnedIds: Set<String>.from(j['earnedIds'] as List? ?? const []),
      earnedAt: {
        for (final e in raw.entries) e.key: DateTime.parse(e.value as String),
      },
    );
  }
}

class CertificatesStorage {
  CertificatesStorage._();
  static final CertificatesStorage instance = CertificatesStorage._();

  static const _key = 'certificates_v1';

  Future<CertificatesStorageData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return CertificatesStorageData.empty;
    try {
      return CertificatesStorageData.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      await prefs.remove(_key);
      return CertificatesStorageData.empty;
    }
  }

  Future<void> save(CertificatesStorageData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
