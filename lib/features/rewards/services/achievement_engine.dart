import '../data/achievements_catalog.dart';
import '../models/achievement.dart';

/// Pure evaluation logic. No state, no IO — easy to unit-test.
class AchievementEngine {
  const AchievementEngine();

  /// Returns a map of achievement id → progress ratio (0..1).
  /// Useful for "in progress" dashboards and per-achievement bars.
  Map<String, double> evaluateProgress(AchievementContext ctx) {
    return {
      for (final a in AchievementsCatalog.all) a.id: a.progress(ctx),
    };
  }

  /// Returns the subset of catalog entries that are satisfied by [ctx]
  /// AND not already in [alreadyUnlocked]. Order matches catalog order
  /// so chained unlocks (within one [checkUnlocks] call from the caller)
  /// are stable.
  List<Achievement> checkUnlocks(
    AchievementContext ctx,
    Set<String> alreadyUnlocked,
  ) {
    final out = <Achievement>[];
    for (final a in AchievementsCatalog.all) {
      if (alreadyUnlocked.contains(a.id)) continue;
      if (_isSatisfied(a, ctx)) out.add(a);
    }
    return out;
  }

  bool _isSatisfied(Achievement a, AchievementContext ctx) {
    return ctx.valueFor(a.conditionType) >= a.targetValue;
  }

  /// Sum of XP rewards across [achievements]. Caller hands this to the
  /// learning provider so XP is added atomically (one persist).
  int awardRewards(Iterable<Achievement> achievements) {
    return achievements.fold<int>(0, (sum, a) => sum + a.xpReward);
  }
}
