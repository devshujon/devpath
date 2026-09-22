import '../../challenges/providers/daily_challenge_provider.dart';
import '../../learning/providers/learning_progress_provider.dart';
import '../models/notification_settings.dart';
import 'notification_service.dart';

/// Translates [NotificationSettings] + current app state into concrete
/// scheduled notifications. Idempotent — call [refreshAll] anytime
/// (app launch, settings change, lesson completion).
class NotificationScheduler {
  final NotificationService _service;
  final LearningProgressProvider _learning;
  final DailyChallengeProvider _daily;

  NotificationScheduler({
    required NotificationService service,
    required LearningProgressProvider learning,
    required DailyChallengeProvider daily,
  })  : _service = service,
        _learning = learning,
        _daily = daily;

  /// Cancel all current schedules and rebuild from [settings] + state.
  Future<void> refreshAll(NotificationSettings settings) async {
    // Master switch off → nuke everything.
    if (!settings.enabled) {
      await _service.cancelAll();
      return;
    }

    // We always cancel-then-set per id rather than diffing. Cheaper to
    // reason about; the plugin handles a few extra cancels fine.

    if (settings.dailyReminderEnabled) {
      await _service.scheduleDaily(
        id: NotificationIds.dailyReminder,
        channelId: NotificationChannels.dailyReminderId,
        channelName: NotificationChannels.dailyReminderName,
        title: 'Continue your DevPath journey',
        body: 'A few minutes of learning today goes a long way.',
        hour: settings.dailyReminderTime.hour,
        minute: settings.dailyReminderTime.minute,
        payload: 'daily_reminder',
      );
    } else {
      await _service.cancel(NotificationIds.dailyReminder);
    }

    if (settings.challengeReminderEnabled) {
      await _service.scheduleDaily(
        id: NotificationIds.challengeReminder,
        channelId: NotificationChannels.challengeReminderId,
        channelName: NotificationChannels.challengeReminderName,
        title: "Today's challenge is available",
        body: 'Beat it for bonus XP. Less than 5 minutes.',
        hour: settings.challengeReminderTime.hour,
        minute: settings.challengeReminderTime.minute,
        payload: 'challenge_reminder',
      );
    } else {
      await _service.cancel(NotificationIds.challengeReminder);
    }

    // Streak warning is conditional: only schedule when the learner
    // has an active streak (so we don't pester users who haven't
    // started one yet). The "didn't complete today" check happens
    // implicitly — if the user does a lesson, [refreshAll] is called
    // again and the warning is rescheduled for tomorrow (the next
    // matching time).
    final hasActiveStreak = _learning.streakDays > 0;
    if (settings.streakWarningEnabled && hasActiveStreak) {
      // If they already completed something today, push the next fire
      // to tomorrow by computing past time → +1 day in the service.
      // (The service auto-pushes any past time to the next occurrence.)
      await _service.scheduleDaily(
        id: NotificationIds.streakWarning,
        channelId: NotificationChannels.streakWarningId,
        channelName: NotificationChannels.streakWarningName,
        title: 'Complete a lesson today to keep your streak',
        body:
            "You're on a ${_learning.streakDays}-day streak. Don't break it now!",
        hour: settings.streakWarningTime.hour,
        minute: settings.streakWarningTime.minute,
        payload: 'streak_warning',
      );
    } else {
      await _service.cancel(NotificationIds.streakWarning);
    }
  }

  /// Read-only accessor for diagnostics screens (settings).
  Future<List<int>> pendingIds() => _service.pendingIds();

  /// Convenience — exposes whether the daily challenge is currently
  /// uncompleted (useful for showing a "next fire" badge in settings).
  bool get dailyChallengeUncompleted => !_daily.completedToday;
}
