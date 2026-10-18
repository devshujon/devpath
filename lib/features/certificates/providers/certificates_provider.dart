import 'package:flutter/foundation.dart';

import '../../challenges/providers/challenges_provider.dart';
import '../../learning/data/lessons_catalog.dart';
import '../../learning/models/lesson.dart';
import '../../learning/providers/learning_progress_provider.dart';
import '../data/certificates_catalog.dart';
import '../models/certificate.dart';
import '../services/certificates_storage.dart';

/// Owns the certificates state. Reactive to learning + challenges
/// providers. Mirrors the RewardsProvider pattern but doesn't award
/// XP itself — certificates ARE the reward.
class CertificatesProvider extends ChangeNotifier {
  static const int _maxEvaluationIterations = 8;

  final LearningProgressProvider _learning;
  final ChallengesProvider _challenges;

  CertificatesStorageData _data = CertificatesStorageData.empty;
  bool _loaded = false;
  bool _evaluating = false;
  bool _wiredListeners = false;

  /// Certificates earned during this app session that haven't yet
  /// been viewed via the celebration overlay. Drained one at a time
  /// by [consumeNextCelebration].
  final List<Certificate> _celebrationQueue = [];

  CertificatesProvider({
    required LearningProgressProvider learning,
    required ChallengesProvider challenges,
  })  : _learning = learning,
        _challenges = challenges;

  // ── Lifecycle ──

  Future<void> load() async {
    if (_loaded) return;
    _data = await CertificatesStorage.instance.load();
    _loaded = true;

    if (!_wiredListeners) {
      _learning.addListener(_onChange);
      _challenges.addListener(_onChange);
      _wiredListeners = true;
    }

    // Initial pass — catches certs the user is already eligible for
    // (e.g. installed a new build that added a cert they satisfy).
    await _evaluate();

    notifyListeners();
  }

  @override
  void dispose() {
    if (_wiredListeners) {
      _learning.removeListener(_onChange);
      _challenges.removeListener(_onChange);
    }
    super.dispose();
  }

  void _onChange() {
    if (!_loaded) return;
    _evaluate();
  }

  Future<void> _persist() async {
    await CertificatesStorage.instance.save(_data);
  }

  // ── Read accessors ──

  bool get loaded => _loaded;
  int get totalCount => CertificatesCatalog.all.length;
  int get earnedCount => _data.earnedIds.length;

  bool isEarned(String id) => _data.earnedIds.contains(id);
  DateTime? earnedAt(String id) => _data.earnedAt[id];

  List<Certificate> get all => CertificatesCatalog.all;

  /// Build the eligibility snapshot. Per-track counts are derived from
  /// the catalog at call time — adding a new lesson to a track will
  /// automatically tighten the corresponding certificate gate without
  /// touching this code or the cert definitions.
  CertificateContext snapshotContext() {
    final completed = _learning.completedLessons;

    final trackTotals = <LessonTrack, int>{};
    final trackCompleted = <LessonTrack, int>{};
    for (final t in LessonTrack.values) {
      final lessons = LessonsCatalog.byTrack(t);
      trackTotals[t] = lessons.length;
      trackCompleted[t] =
          lessons.where((l) => completed.contains(l.id)).length;
    }

    return CertificateContext(
      completedLessons: completed,
      completedChallenges: _challenges.completedIds,
      totalLessons: LessonsCatalog.all.length,
      totalChallenges: _challenges.totalCount,
      trackCompletedCounts: trackCompleted,
      trackTotalCounts: trackTotals,
    );
  }

  bool get hasPendingCelebrations => _celebrationQueue.isNotEmpty;

  Certificate? consumeNextCelebration() {
    if (_celebrationQueue.isEmpty) return null;
    return _celebrationQueue.removeAt(0);
  }

  // ── Evaluation ──

  Future<void> _evaluate() async {
    if (_evaluating) return;
    _evaluating = true;
    final newlyEarned = <Certificate>[];
    try {
      var iter = 0;
      while (iter < _maxEvaluationIterations) {
        iter++;
        final ctx = snapshotContext();
        final fresh = <Certificate>[];
        for (final c in CertificatesCatalog.all) {
          if (_data.earnedIds.contains(c.id)) continue;
          if (c.isEarned(ctx)) fresh.add(c);
        }
        if (fresh.isEmpty) break;
        final now = DateTime.now();
        final updatedIds = {..._data.earnedIds};
        final updatedAt = {..._data.earnedAt};
        for (final c in fresh) {
          updatedIds.add(c.id);
          updatedAt[c.id] = now;
          newlyEarned.add(c);
          _celebrationQueue.add(c);
        }
        _data = _data.copyWith(earnedIds: updatedIds, earnedAt: updatedAt);
      }
    } finally {
      _evaluating = false;
    }

    if (newlyEarned.isNotEmpty) {
      await _persist();
      notifyListeners();
    }
  }

  Future<void> resetAll() async {
    _data = CertificatesStorageData.empty;
    _celebrationQueue.clear();
    await CertificatesStorage.instance.clear();
    notifyListeners();
  }
}
