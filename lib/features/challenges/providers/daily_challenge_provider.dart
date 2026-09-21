import 'package:flutter/foundation.dart';

import '../data/challenges_catalog.dart';
import '../models/challenge.dart';
import 'challenges_provider.dart';

/// Picks one challenge per calendar day deterministically. Tied to the
/// [ChallengesProvider] for completion data.
///
/// Selection algorithm:
///   1. Prefer uncompleted challenges from the catalog.
///   2. Index into that pool using the date hash so the same day always
///      yields the same challenge.
///   3. If the user has completed every challenge, cycle the full pool.
///
/// Bonus XP: 2x the challenge's base reward when completed as today's
/// daily. The challenge's own completion (regular path) still awards
/// the base reward — daily just adds the extra.
class DailyChallengeProvider extends ChangeNotifier {
  final ChallengesProvider _challenges;

  DailyChallengeProvider(this._challenges) {
    _challenges.addListener(_onChallengesChanged);
  }

  void _onChallengesChanged() {
    // Daily selection may flip uncompleted → completed, so rebroadcast.
    notifyListeners();
  }

  @override
  void dispose() {
    _challenges.removeListener(_onChallengesChanged);
    super.dispose();
  }

  /// Multiplier applied to a challenge's base XP for daily completion.
  static const int dailyBonusMultiplier = 2;

  /// 'YYYY-MM-DD' for today in local time.
  String get todayKey => _formatDate(DateTime.now());

  bool get completedToday =>
      _challenges.dailyDates.contains(todayKey);

  Challenge get todaysChallenge {
    // Prefer uncompleted; fall back to full pool when nothing's left.
    final uncompleted = ChallengesCatalog.all
        .where((c) => !_challenges.completedIds.contains(c.id))
        .toList();
    final pool =
        uncompleted.isNotEmpty ? uncompleted : ChallengesCatalog.all;
    return _pickByDate(pool, todayKey);
  }

  /// XP the user would earn for completing today's daily right now.
  /// (Base reward × multiplier.)
  int xpForToday() => todaysChallenge.xpReward * dailyBonusMultiplier;

  /// Mark today's daily as done. Returns true on a fresh transition.
  Future<bool> markTodayCompleted() async {
    return _challenges.markDailyCompleted(todayKey);
  }

  // ── Date helpers ──
  String _formatDate(DateTime t) {
    final m = t.month.toString().padLeft(2, '0');
    final d = t.day.toString().padLeft(2, '0');
    return '${t.year}-$m-$d';
  }

  Challenge _pickByDate(List<Challenge> pool, String dateKey) {
    // Deterministic but well-distributed: stable hash of date string.
    var h = 0x1505;
    for (final ch in dateKey.codeUnits) {
      h = ((h << 5) + h + ch) & 0x7fffffff;
    }
    return pool[h % pool.length];
  }
}
