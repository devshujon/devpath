/// Hive box name constants. Keep stable forever.
class HiveBoxes {
  HiveBoxes._();

  static const lessons      = 'lessons';
  static const progress     = 'progress';
  static const projects     = 'projects';
  static const questions    = 'questions';
  static const quizAttempts = 'quiz_attempts';
  static const unlockTimers = 'unlock_timers';
  static const settings     = 'settings';
}

/// Type IDs for Hive adapters. NEVER reuse a number — even if a model is
/// deleted, its typeId is reserved forever to prevent corruption on upgrade.
class HiveTypeIds {
  HiveTypeIds._();

  static const lesson      = 0;
  static const progress    = 1;
  static const project     = 2;
  static const question    = 3;
  static const quizAttempt = 4;
  static const unlockTimer = 5;
  // 6 reserved for future use (e.g., portfolio state)
}

/// Settings box keys.
class SettingsKeys {
  SettingsKeys._();

  // Streak
  static const streak         = 'streak';
  static const longestStreak  = 'longest_streak';
  static const streakFreezes  = 'streak_freezes';
  static const lastActiveDay  = 'last_active_day';

  // Content version
  static const lessonVersion  = 'lesson_version';
  static const quizVersion    = 'quiz_version';

  // Onboarding
  static const onboardingDone = 'onboarding_done';
  static const dailyGoalMinutes = 'daily_goal_minutes';

  // Permission flow
  static const notifPromptAsked = 'notif_permission_asked_v1';
  static const batteryPrompted = 'battery_prompted_v1';

  // Theme
  static const themeMode = 'theme_mode';

  // Device
  static const deviceId = 'device_id';
}
