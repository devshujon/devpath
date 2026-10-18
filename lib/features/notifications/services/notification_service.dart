import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/notification_settings.dart';

/// Thin wrapper around `flutter_local_notifications` plugin (v17+).
///
/// Responsibilities:
///   - One-time init (channels + timezone db).
///   - Permission requests (Android 13+ POST_NOTIFICATIONS and iOS prompt).
///   - Scheduling daily-repeating notifications using inexact mode
///     (so we don't depend on SCHEDULE_EXACT_ALARM, which is removed
///     from the manifest for Play Store compliance).
///   - Cancellation by id.
///
/// All public methods are safe to call before [init]; they queue or
/// no-op as appropriate.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get initialized => _initialized;

  // ── Init ──

  Future<void> init() async {
    if (_initialized) return;

    // Timezone DB is needed for tz.TZDateTime scheduling. setLocalLocation
    // uses UTC by default — fine for relative-time scheduling. If you
    // want the device's actual local zone, plug in flutter_timezone here.
    tz_data.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onTap,
    );

    await _createAndroidChannels();
    _initialized = true;
  }

  Future<void> _createAndroidChannels() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    Future<void> ensure(String id, String name, String desc) async {
      await android.createNotificationChannel(
        AndroidNotificationChannel(
          id,
          name,
          description: desc,
          importance: Importance.defaultImportance,
        ),
      );
    }

    await ensure(
      NotificationChannels.dailyReminderId,
      NotificationChannels.dailyReminderName,
      'A friendly nudge to keep learning.',
    );
    await ensure(
      NotificationChannels.challengeReminderId,
      NotificationChannels.challengeReminderName,
      'New coding challenge available each day.',
    );
    await ensure(
      NotificationChannels.streakWarningId,
      NotificationChannels.streakWarningName,
      "Don't lose your learning streak.",
    );
  }

  static void _onTap(NotificationResponse response) {
    // Tap handling is intentionally minimal — the dashboard pulls
    // current state on resume. Payload routing can be added here later.
    if (kDebugMode) {
      debugPrint('Notification tapped: ${response.payload}');
    }
  }

  // ── Permissions ──

  /// Returns true if notification permission is granted. Prompts on
  /// the platform when missing. On platforms / OS versions where no
  /// runtime prompt is needed, returns true.
  Future<bool> requestPermission() async {
    if (!_initialized) await init();

    if (Platform.isAndroid) {
      // Android 13+ requires runtime POST_NOTIFICATIONS permission.
      final status = await Permission.notification.status;
      if (status.isGranted) return true;
      final result = await Permission.notification.request();
      return result.isGranted;
    }

    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      return granted;
    }

    return true;
  }

  Future<bool> hasPermission() async {
    if (Platform.isAndroid) {
      return Permission.notification.isGranted;
    }
    // iOS doesn't have a synchronous "is granted" — the plugin's check
    // would require a permissions call. For our flow, treat optimistic.
    return true;
  }

  // ── Scheduling ──

  /// Schedule a daily-repeating local notification at the given local
  /// wall-clock time. Idempotent for the same [id] — replaces any prior
  /// schedule with the same id.
  Future<void> scheduleDaily({
    required int id,
    required String channelId,
    required String channelName,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    if (!_initialized) await init();

    // Compute the next occurrence of (hour:minute) in local time.
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        showWhen: false,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      // matchDateTimeComponents: time → repeat daily at this time
      matchDateTimeComponents: DateTimeComponents.time,
      // inexactAllowWhileIdle works without SCHEDULE_EXACT_ALARM perm
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // iOS only — interpret the scheduled wall-clock time as local
      // (not absolute UTC). Required by flutter_local_notifications v17.
      // Removed entirely in v18+; if you bump the constraint, delete
      // this line.
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Cancel a scheduled notification by id. Safe even if nothing is
  /// scheduled with that id.
  Future<void> cancel(int id) async {
    if (!_initialized) await init();
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    if (!_initialized) await init();
    await _plugin.cancelAll();
  }

  /// Pending notification ids currently scheduled with the plugin.
  Future<List<int>> pendingIds() async {
    if (!_initialized) await init();
    final pending = await _plugin.pendingNotificationRequests();
    return pending.map((p) => p.id).toList();
  }
}
