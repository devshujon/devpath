import 'package:flutter/foundation.dart';

import '../data/challenges_catalog.dart';
import '../models/challenge.dart';
import '../services/challenges_storage.dart';

/// Owns the catalog projection (with completion state) and persists
/// completion via [ChallengesStorage].
///
/// Locking model: beginner challenges are always unlocked; intermediate
/// challenges unlock when ≥50% of beginner challenges are complete.
/// (Mirrors the lesson locking pattern in [LearningProgressProvider].)
class ChallengesProvider extends ChangeNotifier {
  ChallengesStorageData _data = ChallengesStorageData.empty;
  bool _loaded = false;

  bool get loaded => _loaded;
  Set<String> get completedIds => _data.completedChallenges;
  Set<String> get dailyDates => _data.dailyCompletedDates;

  // ── Lifecycle ──
  Future<void> load() async {
    if (_loaded) return;
    _data = await ChallengesStorage.instance.load();
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    await ChallengesStorage.instance.save(_data);
    notifyListeners();
  }

  // ── Read accessors ──

  List<Challenge> get all => ChallengesCatalog.all;

  int get completedCount => _data.completedChallenges.length;
  int get totalCount => ChallengesCatalog.all.length;

  bool isCompleted(String id) => _data.completedChallenges.contains(id);

  bool isLocked(Challenge c) {
    if (c.difficulty == Difficulty.beginner) return false;
    if (c.difficulty == Difficulty.intermediate) {
      return _difficultyProgress(Difficulty.beginner) < 0.5;
    }
    // Advanced (when added later)
    return _difficultyProgress(Difficulty.intermediate) < 0.5;
  }

  double _difficultyProgress(Difficulty d) {
    final inDifficulty = ChallengesCatalog.byDifficulty(d);
    if (inDifficulty.isEmpty) return 0;
    final done = inDifficulty
        .where((c) => _data.completedChallenges.contains(c.id))
        .length;
    return done / inDifficulty.length;
  }

  /// Next uncompleted challenge in catalog order — used to drive
  /// "Next challenge" buttons.
  Challenge? nextAfter(String currentId) {
    var passedCurrent = false;
    for (final c in ChallengesCatalog.all) {
      if (c.id == currentId) {
        passedCurrent = true;
        continue;
      }
      if (!passedCurrent) continue;
      if (!_data.completedChallenges.contains(c.id) && !isLocked(c)) {
        return c;
      }
    }
    // No later uncompleted — try from the start
    for (final c in ChallengesCatalog.all) {
      if (c.id == currentId) break;
      if (!_data.completedChallenges.contains(c.id) && !isLocked(c)) {
        return c;
      }
    }
    return null;
  }

  // ── Mutations ──

  /// Mark a challenge complete. Idempotent. Returns true if this call
  /// actually transitioned the state (false if already done).
  Future<bool> markCompleted(String id) async {
    if (_data.completedChallenges.contains(id)) return false;
    _data = _data.copyWith(
      completedChallenges: {..._data.completedChallenges, id},
    );
    await _persist();
    return true;
  }

  /// Record that the user completed today's daily challenge. Idempotent.
  Future<bool> markDailyCompleted(String dateKey) async {
    if (_data.dailyCompletedDates.contains(dateKey)) return false;
    _data = _data.copyWith(
      dailyCompletedDates: {..._data.dailyCompletedDates, dateKey},
    );
    await _persist();
    return true;
  }
}
