import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:shared_preferences/shared_preferences.dart';

import '../../challenges/providers/challenges_provider.dart';
import '../../learning/providers/learning_progress_provider.dart';
import '../models/notification_settings.dart';
import '../services/notification_scheduler.dart';
import '../services/notification_service.dart';

class NotificationsProvider extends ChangeNotifier {
  static const _settingsKey = 'notification_settings_v1';
  static const _permGrantedKey = 'notification_perm_granted_v1';

  final NotificationScheduler _scheduler;
  final NotificationService _service;
  final LearningProgressProvider _learning;
  final ChallengesProvider _challenges;

  NotificationSettings _settings = NotificationSettings.defaults;
  bool _loaded = false;
  bool _permGrantedHint = false;
  bool _wiredListeners = false;

  NotificationsProvider({
    required NotificationScheduler scheduler,
    required NotificationService service,
    required LearningProgressProvider learning,
    required ChallengesProvider challenges,
  })  : _scheduler = scheduler,
        _service = service,
        _learning = learning,
        _challenges = challenges;

  // ── Read accessors ──
  bool get loaded => _loaded;
  NotificationSettings get settings => _settings;
  bool get permGrantedHint => _permGrantedHint;

  // ── Lifecycle ──

  /// Hydrate from storage and run an initial schedule refresh. Safe to
  /// call multiple times — guarded by [_loaded].
  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw != null) {
      try {
        _settings = NotificationSettings.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {
        await prefs.remove(_settingsKey);
        _settings = NotificationSettings.defaults;
      }
    }
    _permGrantedHint = prefs.getBool(_permGrantedKey) ?? false;
    _loaded = true;

    // Initialise plugin (channels, timezone DB).
    await _service.init();

    // Schedule based on whatever's persisted. If permissions haven't
    // been granted yet, scheduled notifications won't fire — but that
    // matches the user's expectation that prompting is explicit.
    await _scheduler.refreshAll(_settings);

    // Listen for state changes that affect the streak warning.
    if (!_wiredListeners) {
      _learning.addListener(_onLearnerChanged);
      _challenges.addListener(_onLearnerChanged);
      _wiredListeners = true;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    if (_wiredListeners) {
      _learning.removeListener(_onLearnerChanged);
      _challenges.removeListener(_onLearnerChanged);
    }
    super.dispose();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(_settings.toJson()));
    await prefs.setBool(_permGrantedKey, _permGrantedHint);
  }

  void _onLearnerChanged() {
    if (!_loaded) return;
    // Streak count or activity changed — reschedule so the streak
    // warning is current. Fire-and-forget.
    _scheduler.refreshAll(_settings);
  }

  // ── Permissions ──

  Future<bool> ensurePermission() async {
    final granted = await _service.requestPermission();
    _permGrantedHint = granted;
    await _persist();
    notifyListeners();
    return granted;
  }

  // ── Settings mutations ──

  /// Single setter — atomic update + reschedule + persist.
  Future<void> updateSettings(NotificationSettings next) async {
    if (next == _settings) return;
    _settings = next;
    await _persist();
    await _scheduler.refreshAll(_settings);
    notifyListeners();
  }

  Future<void> setEnabled(bool v) =>
      updateSettings(_settings.copyWith(enabled: v));

  Future<void> setDailyReminder({bool? enabled, TimeOfDay? time}) =>
      updateSettings(_settings.copyWith(
        dailyReminderEnabled: enabled,
        dailyReminderTime: time,
      ));

  Future<void> setChallengeReminder({bool? enabled, TimeOfDay? time}) =>
      updateSettings(_settings.copyWith(
        challengeReminderEnabled: enabled,
        challengeReminderTime: time,
      ));

  Future<void> setStreakWarning({bool? enabled, TimeOfDay? time}) =>
      updateSettings(_settings.copyWith(
        streakWarningEnabled: enabled,
        streakWarningTime: time,
      ));

  /// Force a reschedule. Useful from settings screens that want to
  /// reflect "next fire time" updates after a change.
  Future<void> refresh() => _scheduler.refreshAll(_settings);

  Future<List<int>> pendingIds() => _scheduler.pendingIds();
}
