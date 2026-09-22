import 'package:flutter/material.dart';

import '../../features/certificates/screens/certificate_detail_screen.dart';
import '../../features/certificates/screens/certificates_screen.dart';
import '../../features/challenges/screens/challenge_screen.dart';
import '../../features/challenges/screens/challenges_screen.dart';
import '../../features/editor/screens/editor_screen.dart';
import '../../features/editor/screens/html_practice_screen.dart';
import '../../features/editor/screens/lesson_picker_screen.dart';
import '../../features/editor/screens/playground_screen.dart';
import '../../features/editor/screens/projects_screen.dart';
import '../../features/home/screens/main_shell.dart';
import '../../features/learn/screens/learn_screen.dart';
import '../../features/learning/screens/dashboard_screen.dart';
import '../../features/learning/screens/lesson_detail_screen.dart';
import '../../features/learning/screens/lesson_quiz_screen.dart';
import '../../features/learning/screens/roadmap_screen.dart';
import '../../features/notifications/screens/notification_settings_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/quiz_engine/screens/quiz_runner_screen.dart';
import '../../features/projects_track/screens/project_detail_screen.dart';
import '../../features/projects_track/screens/projects_track_screen.dart';
import '../../features/rewards/screens/achievements_screen.dart';

// Re-exported so callers don't need to import the screen file directly
// just to construct route arguments.
export '../../features/editor/screens/playground_screen.dart'
    show PlaygroundArguments;
export '../../features/learning/screens/lesson_detail_screen.dart'
    show LessonDetailArguments;
export '../../features/challenges/screens/challenges_screen.dart'
    show ChallengeRouteArguments;
export '../../features/projects_track/screens/projects_track_screen.dart'
    show ProjectDetailArguments;
export '../../features/certificates/screens/certificate_detail_screen.dart'
    show CertificateDetailArguments;

class AppRoutes {
  AppRoutes._();

  static const shell        = '/';
  static const learn        = '/learn';
  static const editor       = '/editor';
  static const htmlPractice = '/html-practice';
  static const playground   = '/playground';
  static const projects     = '/projects';
  static const lessons      = '/lessons';
  static const profile      = '/profile';

  // Learning system
  static const dashboard    = '/dashboard';
  static const roadmap      = '/roadmap';
  static const lessonDetail = '/lesson-detail';
  static const lessonQuiz   = '/lesson-quiz';
  static const quizRunner   = '/quiz-runner';

  // Challenges
  static const challenges   = '/challenges';
  static const challenge    = '/challenge';

  // Rewards
  static const achievements = '/achievements';

  // Mini projects track
  static const projectsTrack = '/projects-track';
  static const projectDetail = '/project-detail';

  // Certificates
  static const certificates       = '/certificates';
  static const certificateDetail  = '/certificate-detail';

  // Notifications
  static const notificationSettings = '/notification-settings';

  static Map<String, WidgetBuilder> routes = {
    shell:                (_) => const MainShell(),
    learn:                (_) => const LearnScreen(),
    editor:               (_) => const EditorScreen(),
    htmlPractice:         (_) => const HtmlPracticeScreen(),
    playground:           (_) => const PlaygroundScreen(),
    projects:             (_) => const ProjectsScreen(),
    lessons:              (_) => const LessonPickerScreen(),
    profile:              (_) => const ProfileScreen(),
    dashboard:            (_) => const DashboardScreen(),
    roadmap:              (_) => const RoadmapScreen(),
    lessonDetail:         (_) => const LessonDetailScreen(),
    lessonQuiz:           (_) => const LessonQuizScreen(),
    quizRunner:           (_) => const QuizRunnerScreen(),
    challenges:           (_) => const ChallengesScreen(),
    challenge:            (_) => const ChallengeScreen(),
    achievements:         (_) => const AchievementsScreen(),
    projectsTrack:        (_) => const ProjectsTrackScreen(),
    projectDetail:        (_) => const ProjectDetailScreen(),
    certificates:         (_) => const CertificatesScreen(),
    certificateDetail:    (_) => const CertificateDetailScreen(),
    notificationSettings: (_) => const NotificationSettingsScreen(),
  };
}
