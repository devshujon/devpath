import 'package:flutter/foundation.dart';

/// AdMob identifiers. Production values must be supplied via `--dart-define`
/// or build flavors; defaults use Google's official test unit IDs.
class AdMobConfig {
  AdMobConfig._();

  /// Android rewarded test unit (Google sample).
  static const String androidRewardedTestUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  static String get rewardedAdUnitId {
    const fromEnv = String.fromEnvironment('ADMOB_REWARDED_UNIT_ID');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) return androidRewardedTestUnitId;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidRewardedTestUnitId;
      default:
        return androidRewardedTestUnitId;
    }
  }
}
