import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/services/storage_service.dart';
import 'features/code_editor/providers/code_editor_provider.dart';
import 'features/certificates/providers/certificates_provider.dart';
import 'features/challenges/providers/challenges_provider.dart';
import 'features/challenges/providers/daily_challenge_provider.dart';
import 'features/editor/providers/projects_list_provider.dart';
import 'features/learning/providers/learning_progress_provider.dart';
import 'features/notifications/providers/notifications_provider.dart';
import 'features/notifications/services/notification_scheduler.dart';
import 'features/notifications/services/notification_service.dart';
import 'features/projects_track/providers/projects_track_provider.dart';
import 'features/rewards/providers/rewards_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.instance.init();

  // ── Eager-loaded providers ──
  // Source-of-truth providers are constructed and hydrated before
  // runApp so the dashboard's first frame has real data, AND so the
  // RewardsProvider can attach listeners after these are populated.
  final learning = LearningProgressProvider();
  final challenges = ChallengesProvider();
  final projectsList = ProjectsListProvider();
  await Future.wait([
    learning.load(),
    challenges.load(),
    projectsList.load(),
  ]);

  final daily = DailyChallengeProvider(challenges);

  // Mini-projects track depends on learning for lock evaluation.
  // Certificates depend on learning + challenges. Both must be loaded
  // BEFORE rewards so its snapshotContext sees real data on first eval.
  final projectsTrack = ProjectsTrackProvider(learning);
  final certificates = CertificatesProvider(
    learning: learning,
    challenges: challenges,
  );
  await Future.wait([
    projectsTrack.load(),
    certificates.load(),
  ]);

  // Rewards depends on all five source providers. Construct + load
  // here so any pending celebrations from past sessions are queued
  // before the dashboard renders.
  final rewards = RewardsProvider(
    learning: learning,
    challenges: challenges,
    projects: projectsList,
    projectsTrack: projectsTrack,
    certificates: certificates,
  );
  await rewards.load();

  // Notifications: service + scheduler are stateless wrappers; the
  // provider owns settings persistence and wires the listener chain.
  final notificationService = NotificationService.instance;
  final scheduler = NotificationScheduler(
    service: notificationService,
    learning: learning,
    daily: daily,
  );
  final codeEditor = CodeEditorProvider();
  // ignore: unawaited_futures
  codeEditor.load();

  final notifications = NotificationsProvider(
    scheduler: scheduler,
    service: notificationService,
    learning: learning,
    challenges: challenges,
  );
  // Don't await — notification init can fail without blocking the UI.
  // The provider re-tries on first user interaction with the settings.
  // ignore: unawaited_futures
  notifications.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: projectsList),
        ChangeNotifierProvider.value(value: learning),
        ChangeNotifierProvider.value(value: challenges),
        ChangeNotifierProvider.value(value: daily),
        ChangeNotifierProvider.value(value: projectsTrack),
        ChangeNotifierProvider.value(value: certificates),
        ChangeNotifierProvider.value(value: rewards),
        ChangeNotifierProvider.value(value: notifications),
        ChangeNotifierProvider.value(value: codeEditor),
      ],
      child: const DevPathApp(),
    ),
  );
}
