import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../../certificates/providers/certificates_provider.dart';
import '../../certificates/widgets/certificates_card.dart';
import '../../challenges/models/challenge.dart';
import '../../challenges/providers/challenges_provider.dart';
import '../../challenges/widgets/daily_challenge_card.dart';
import '../../editor/providers/projects_list_provider.dart';
import '../../projects_track/models/track_project.dart';
import '../../projects_track/providers/projects_track_provider.dart';
import '../../projects_track/widgets/continue_project_card.dart';
import '../../projects_track/widgets/projects_track_card.dart';
import '../../rewards/providers/rewards_provider.dart';
import '../../rewards/widgets/achievement_card.dart';
import '../../rewards/widgets/achievement_unlock_overlay.dart';
import '../../rewards/widgets/pending_rewards_card.dart';
import '../../rewards/widgets/recent_unlocks_card.dart';
import '../data/lessons_catalog.dart';
import '../models/lesson.dart';
import '../providers/learning_progress_provider.dart';
import '../widgets/continue_card.dart';
import '../widgets/recent_projects_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/xp_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  static const route = '/dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  RewardsProvider? _rewards;
  bool _celebrating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Ensure providers have hydrated their state
      context.read<LearningProgressProvider>().load();
      context.read<ProjectsListProvider>().load();
      context.read<ChallengesProvider>().load();
      context.read<ProjectsTrackProvider>().load();
      context.read<CertificatesProvider>().load();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final rewards = context.read<RewardsProvider>();
    if (!identical(_rewards, rewards)) {
      _rewards?.removeListener(_maybeShowCelebration);
      _rewards = rewards;
      _rewards!.addListener(_maybeShowCelebration);
      // Surface any celebration queued from past sessions on first
      // frame so it shows automatically without user action.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _maybeShowCelebration(),
      );
    }
  }

  @override
  void dispose() {
    _rewards?.removeListener(_maybeShowCelebration);
    super.dispose();
  }

  /// Drains the celebration queue one overlay at a time. Re-entrancy
  /// guard prevents stacking overlays if the listener fires while one
  /// is already animating.
  Future<void> _maybeShowCelebration() async {
    if (_celebrating || !mounted) return;
    final rewards = _rewards;
    if (rewards == null || !rewards.hasPendingCelebrations) return;

    _celebrating = true;
    try {
      var next = rewards.consumeNextCelebration();
      while (next != null && mounted) {
        await AchievementUnlockOverlay.show(context, achievement: next);
        if (!mounted) break;
        next = rewards.consumeNextCelebration();
      }
    } finally {
      _celebrating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DevPath'),
        actions: [
          _PendingBadge(
            child: IconButton(
              tooltip: 'Achievements',
              icon: const Icon(Icons.emoji_events_outlined),
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.achievements),
            ),
          ),
          IconButton(
            tooltip: 'Challenges',
            icon: const Icon(Icons.terminal),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.challenges),
          ),
          IconButton(
            tooltip: 'Mini Projects',
            icon: const Icon(Icons.build_circle_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.projectsTrack),
          ),
          IconButton(
            tooltip: 'Roadmap',
            icon: const Icon(Icons.map_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.roadmap),
          ),
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.notificationSettings,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context
              .read<LearningProgressProvider>()
              .load(); // safe no-op after first
          if (!context.mounted) return;
          await context
              .read<ProjectsListProvider>()
              .load(force: true);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Pending rewards callout — only renders when there are
            // unacknowledged unlocks. Sits at the top to catch the eye.
            const PendingRewardsCard(),
            Selector<RewardsProvider, bool>(
              selector: (_, r) => r.pendingRewards.isNotEmpty,
              builder: (_, hasPending, __) =>
                  SizedBox(height: hasPending ? 16 : 0),
            ),

            // 0. First-time user hero. Only renders when the user has
            // zero completed lessons. Acts as the dominant CTA so the
            // first action is unambiguous, then disappears forever.
            Selector<LearningProgressProvider, bool>(
              selector: (_, p) => p.completedLessons.isEmpty,
              builder: (_, isNewUser, __) => isNewUser
                  ? const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: _StartFirstLessonHero(),
                    )
                  : const SizedBox.shrink(),
            ),

            // 1. XP / Level
            const XpCard(),
            const SizedBox(height: 16),

            // 2. Streak / Time / Progress %
            const StreakCard(),
            const SizedBox(height: 16),

            // 3. Achievements progress
            AchievementCard(
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.achievements),
            ),
            const SizedBox(height: 16),

            // 3b + 3c. Mini projects + Certificates cards.
            // Hidden while the user has 0 completed lessons — showing
            // "0/9 Projects" and "0/4 Certs" on day-zero is demotivating
            // and clutters the day-one screen.
            Selector<LearningProgressProvider, bool>(
              selector: (_, p) => p.completedLessons.isNotEmpty,
              builder: (_, hasAnyProgress, __) {
                if (!hasAnyProgress) return const SizedBox.shrink();
                return Column(
                  children: [
                    ProjectsTrackCard(
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.projectsTrack),
                    ),
                    const SizedBox(height: 16),
                    CertificatesCard(
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.certificates),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),

            // 4. Continue learning (recommended lesson)
            _SectionLabel(
              icon: Icons.school_outlined,
              text: 'Up next',
              trailing: TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.roadmap),
                child: const Text('Roadmap'),
              ),
            ),
            const SizedBox(height: 8),
            ContinueCard(onContinue: (l) => _openLesson(context, l)),

            // 4b. Continue Project — only renders when one is in progress
            Selector<ProjectsTrackProvider, bool>(
              selector: (_, p) => p.continueCandidate() != null,
              builder: (_, hasInProgress, __) =>
                  SizedBox(height: hasInProgress ? 12 : 0),
            ),
            ContinueProjectCard(
              onContinue: (p) => _openTrackProject(context, p),
            ),
            const SizedBox(height: 20),

            // 5. Daily challenge
            DailyChallengeCard(onContinue: (c) => _openDailyChallenge(context, c)),
            const SizedBox(height: 20),

            // 6. Recent badge unlocks (only renders if any unlocked)
            RecentUnlocksCard(
              onSeeAll: () =>
                  Navigator.pushNamed(context, AppRoutes.achievements),
            ),
            Selector<RewardsProvider, bool>(
              selector: (_, r) => r.unlockedCount > 0,
              builder: (_, hasUnlocks, __) =>
                  SizedBox(height: hasUnlocks ? 20 : 0),
            ),

            // 7. Recent projects
            const RecentProjectsCard(),
            const SizedBox(height: 20),

            // 8. Quick-launch playground
            _QuickPlayground(
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.playground),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _openLesson(BuildContext context, Lesson lesson) {
    Navigator.pushNamed(
      context,
      AppRoutes.lessonDetail,
      arguments: LessonDetailArguments(lessonId: lesson.id),
    );
  }

  void _openDailyChallenge(BuildContext context, Challenge c) {
    Navigator.pushNamed(
      context,
      AppRoutes.challenge,
      arguments: ChallengeRouteArguments(
        challengeId: c.id,
        isDailyEntry: true,
      ),
    );
  }

  void _openTrackProject(BuildContext context, TrackProject p) {
    Navigator.pushNamed(
      context,
      AppRoutes.projectDetail,
      arguments: ProjectDetailArguments(projectId: p.id),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? trailing;

  const _SectionLabel({
    required this.icon,
    required this.text,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _QuickPlayground extends StatelessWidget {
  final VoidCallback onTap;
  const _QuickPlayground({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: isDark ? const Color(0xFF141820) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF262B35)
                  : const Color(0xFFE4E7EE),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.bolt_outlined, color: primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Open Playground',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Free-form HTML, CSS, and JS.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wraps a child (typically an IconButton) and overlays a small badge
/// when there are unacknowledged achievement unlocks. Used in the
/// dashboard AppBar to draw attention to the achievements entry.
class _PendingBadge extends StatelessWidget {
  final Widget child;
  const _PendingBadge({required this.child});

  @override
  Widget build(BuildContext context) {
    final count = context.select<RewardsProvider, int>(
      (r) => r.pendingRewards.length,
    );
    if (count == 0) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: 8,
          top: 8,
          child: IgnorePointer(
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
//  _StartFirstLessonHero
//
//  Shown on dashboard ONLY while completedLessons is empty. Acts as
//  the dominant "first action" for brand-new users — the previous
//  layout buried "Continue learning" four cards down, which left
//  day-zero users with no obvious next step.
//
//  Pulls the very first lesson from LessonsCatalog (currently
//  h1_heading) and routes to its detail screen.
// ─────────────────────────────────────────────────────────────────────

class _StartFirstLessonHero extends StatelessWidget {
  const _StartFirstLessonHero();

  @override
  Widget build(BuildContext context) {
    // First lesson in the catalog = canonical "start here".
    // If the catalog is ever empty, render nothing rather than crash.
    final lessons = LessonsCatalog.all;
    if (lessons.isEmpty) return const SizedBox.shrink();
    final firstLesson = lessons.first;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C5CE7), Color(0xFF8B5CF6)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.lessonDetail,
            arguments: LessonDetailArguments(lessonId: firstLesson.id),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Eyebrow line
                const Row(
                  children: [
                    Icon(Icons.celebration_outlined,
                        size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'WELCOME TO DEVPATH',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ready to start coding?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Begin with ${firstLesson.title} — '
                  '${firstLesson.estimatedMinutes} min · '
                  '+${firstLesson.xpReward} XP',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),

                // Primary CTA
                Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow,
                          color: Color(0xFF6C5CE7), size: 20),
                      SizedBox(width: 4),
                      Text(
                        'Start your first lesson',
                        style: TextStyle(
                          color: Color(0xFF6C5CE7),
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
