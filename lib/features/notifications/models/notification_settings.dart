import 'package:flutter/material.dart';

/// User-configurable preferences for scheduled local notifications.
///
/// Persisted by [NotificationsProvider] and consumed by
/// [NotificationScheduler] to (re)build the schedule.
class NotificationSettings {
  /// Master switch. When false, the scheduler cancels everything
  /// regardless of per-channel flags.
  final bool enabled;

  /// "Continue your DevPath journey" reminder.
  final bool dailyReminderEnabled;
  final TimeOfDay dailyReminderTime;

  /// "Today's challenge is available" reminder.
  final bool challengeReminderEnabled;
  final TimeOfDay challengeReminderTime;

  /// "Complete a lesson today to keep your streak" — only fired when
  /// the user has an active streak AND hasn't been active today (the
  /// scheduler checks state at refresh time).
  final bool streakWarningEnabled;
  final TimeOfDay streakWarningTime;

  const NotificationSettings({
    this.enabled = true,
    this.dailyReminderEnabled = true,
    this.dailyReminderTime = const TimeOfDay(hour: 19, minute: 0),
    this.challengeReminderEnabled = true,
    this.challengeReminderTime = const TimeOfDay(hour: 9, minute: 0),
    this.streakWarningEnabled = true,
    this.streakWarningTime = const TimeOfDay(hour: 20, minute: 0),
  });

  static const defaults = NotificationSettings();

  NotificationSettings copyWith({
    bool? enabled,
    bool? dailyReminderEnabled,
    TimeOfDay? dailyReminderTime,
    bool? challengeReminderEnabled,
    TimeOfDay? challengeReminderTime,
    bool? streakWarningEnabled,
    TimeOfDay? streakWarningTime,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      dailyReminderEnabled:
          dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      challengeReminderEnabled:
          challengeReminderEnabled ?? this.challengeReminderEnabled,
      challengeReminderTime:
          challengeReminderTime ?? this.challengeReminderTime,
      streakWarningEnabled:
          streakWarningEnabled ?? this.streakWarningEnabled,
      streakWarningTime: streakWarningTime ?? this.streakWarningTime,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'dailyReminderEnabled': dailyReminderEnabled,
        'dailyReminderTime': _formatTime(dailyReminderTime),
        'challengeReminderEnabled': challengeReminderEnabled,
        'challengeReminderTime': _formatTime(challengeReminderTime),
        'streakWarningEnabled': streakWarningEnabled,
        'streakWarningTime': _formatTime(streakWarningTime),
      };

  factory NotificationSettings.fromJson(Map<String, dynamic> j) {
    return NotificationSettings(
      enabled: j['enabled'] as bool? ?? true,
      dailyReminderEnabled: j['dailyReminderEnabled'] as bool? ?? true,
      dailyReminderTime: _parseTime(
        j['dailyReminderTime'] as String?,
        const TimeOfDay(hour: 19, minute: 0),
      ),
      challengeReminderEnabled:
          j['challengeReminderEnabled'] as bool? ?? true,
      challengeReminderTime: _parseTime(
        j['challengeReminderTime'] as String?,
        const TimeOfDay(hour: 9, minute: 0),
      ),
      streakWarningEnabled: j['streakWarningEnabled'] as bool? ?? true,
      streakWarningTime: _parseTime(
        j['streakWarningTime'] as String?,
        const TimeOfDay(hour: 20, minute: 0),
      ),
    );
  }

  static String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static TimeOfDay _parseTime(String? raw, TimeOfDay fallback) {
    if (raw == null) return fallback;
    final parts = raw.split(':');
    if (parts.length != 2) return fallback;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return fallback;
    return TimeOfDay(hour: h, minute: m);
  }
}

/// Stable IDs for each scheduled notification. Kept here so the
/// scheduler and any cancel call agree.
class NotificationIds {
  NotificationIds._();
  static const int dailyReminder = 1001;
  static const int challengeReminder = 1002;
  static const int streakWarning = 1003;
}

/// Channel descriptors — Android requires explicit channels in v17+.
class NotificationChannels {
  NotificationChannels._();
  static const String dailyReminderId = 'devpath_daily_reminder';
  static const String dailyReminderName = 'Daily reminder';
  static const String challengeReminderId = 'devpath_challenge_reminder';
  static const String challengeReminderName = 'Daily challenge';
  static const String streakWarningId = 'devpath_streak_warning';
  static const String streakWarningName = 'Streak protection';
}
