import 'package:flutter/material.dart';

import '../../learning/models/lesson.dart' show LessonTrack;

/// Per-kind discriminator so the certificate template can vary by type.
enum CertificateKind {
  html,
  css,
  javascript,
  graduate;

  String get key => switch (this) {
        CertificateKind.html => 'html',
        CertificateKind.css => 'css',
        CertificateKind.javascript => 'javascript',
        CertificateKind.graduate => 'graduate',
      };

  static CertificateKind fromKey(String s) =>
      CertificateKind.values.firstWhere(
        (k) => k.key == s,
        orElse: () => CertificateKind.html,
      );
}

/// Snapshot of completion state used to evaluate certificate eligibility.
/// Built by [CertificatesProvider] from learning + challenges. Includes
/// per-track lesson counts so [Certificate.isEarned] can check track
/// completion without importing [LessonsCatalog] from the model layer.
class CertificateContext {
  /// All completed lesson IDs (across all tracks).
  final Set<String> completedLessons;

  /// All completed challenge IDs.
  final Set<String> completedChallenges;

  /// Total lessons in the catalog (across all tracks). Used by gates
  /// that need "all lessons complete" — the Graduate cert.
  final int totalLessons;

  /// Total challenges in the catalog. Same role as [totalLessons].
  final int totalChallenges;

  /// Number of lessons completed PER TRACK. Drives track-specific
  /// certificate eligibility.
  final Map<LessonTrack, int> trackCompletedCounts;

  /// Total lessons available PER TRACK. The cert is earned when
  /// completed == total for the required track.
  final Map<LessonTrack, int> trackTotalCounts;

  const CertificateContext({
    required this.completedLessons,
    required this.completedChallenges,
    required this.totalLessons,
    required this.totalChallenges,
    required this.trackCompletedCounts,
    required this.trackTotalCounts,
  });

  static const empty = CertificateContext(
    completedLessons: {},
    completedChallenges: {},
    totalLessons: 0,
    totalChallenges: 0,
    trackCompletedCounts: {},
    trackTotalCounts: {},
  );

  int completedIn(LessonTrack t) => trackCompletedCounts[t] ?? 0;
  int totalIn(LessonTrack t) => trackTotalCounts[t] ?? 0;
}

/// Certificate definition. Eligibility is composed of optional gates;
/// all set gates must pass for [isEarned] to return true.
///
/// Track-based gating ([requiredTrack]) is the preferred mechanism —
/// the lesson catalog determines which IDs count, so adding a lesson
/// to a track auto-extends the cert requirement. Hardcoded ID lists
/// are intentionally NOT supported.
class Certificate {
  final String id;
  final CertificateKind kind;
  final String title;
  final String description;
  final IconData icon;

  /// Primary color used in the rendered certificate template.
  final Color accentColor;

  /// When set, the cert requires every lesson on this track to be
  /// completed. The set of lessons is resolved at evaluation time
  /// from the lesson catalog — NOT hardcoded here.
  final LessonTrack? requiredTrack;

  /// When true, ALL lessons in the catalog must be complete.
  /// (Used by the Graduate cert.)
  final bool requireAllLessons;

  /// When true, ALL challenges in the catalog must be complete.
  final bool requireAllChallenges;

  const Certificate({
    required this.id,
    required this.kind,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    this.requiredTrack,
    this.requireAllLessons = false,
    this.requireAllChallenges = false,
  });

  bool isEarned(CertificateContext ctx) {
    if (requireAllLessons &&
        ctx.completedLessons.length < ctx.totalLessons) {
      return false;
    }
    if (requireAllChallenges &&
        ctx.completedChallenges.length < ctx.totalChallenges) {
      return false;
    }
    if (requiredTrack != null) {
      final done = ctx.completedIn(requiredTrack!);
      final total = ctx.totalIn(requiredTrack!);
      if (total == 0 || done < total) return false;
    }
    return true;
  }

  /// 0..1 — fraction of the gate(s) satisfied. Used for "X% complete"
  /// progress bars on the certificate screen.
  double progress(CertificateContext ctx) {
    final scores = <double>[];

    if (requireAllLessons) {
      scores.add(ctx.totalLessons == 0
          ? 1.0
          : (ctx.completedLessons.length / ctx.totalLessons).clamp(0.0, 1.0));
    }
    if (requireAllChallenges) {
      scores.add(ctx.totalChallenges == 0
          ? 1.0
          : (ctx.completedChallenges.length / ctx.totalChallenges)
              .clamp(0.0, 1.0));
    }
    if (requiredTrack != null) {
      final done = ctx.completedIn(requiredTrack!);
      final total = ctx.totalIn(requiredTrack!);
      scores.add(total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0));
    }

    if (scores.isEmpty) return 1.0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }
}
