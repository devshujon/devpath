import 'package:flutter/foundation.dart';

import 'rewarded_ad_purpose.dart';

/// AdMob App IDs and ad unit IDs for DevPath.
///
/// **Debug / profile builds** use Google's official **test** unit IDs.
/// **Release builds** use production IDs from the AdMob console.
///
/// Override for CI or manual QA:
/// `--dart-define=ADMOB_FORCE_TEST_IDS=true` on a release build → test units.
class AdMobConfig {
  AdMobConfig._();

  // ── Google sample (safe for development) ──
  static const String androidTestAppId =
      'ca-app-pub-3940256099942544~3347511713';
  static const String androidTestRewardedUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String androidTestBannerUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String androidTestInterstitialUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  // ── DevPath production (AdMob console) ──
  static const String androidProductionAppId =
      'ca-app-pub-3995622198490756~4702943512';
  static const String productionRewardedQuizTimerRetry =
      'ca-app-pub-3995622198490756/6724892612';
  static const String productionBannerMain =
      'ca-app-pub-3995622198490756/3876947009';
  static const String productionInterstitialLesson =
      'ca-app-pub-3995622198490756/4098729279';

  /// Manifest App ID is selected per build type (see `src/debug` vs `src/main`).
  static String get androidAppId => useProductionAdUnitIds
      ? androidProductionAppId
      : androidTestAppId;

  /// Test units in debug/profile; production units in release unless forced.
  static bool get useProductionAdUnitIds => resolveUseProductionAdUnitIds(
        debugMode: kDebugMode,
        forceTestFromEnvironment: const bool.fromEnvironment(
          'ADMOB_FORCE_TEST_IDS',
          defaultValue: false,
        ),
      );

  @visibleForTesting
  static bool resolveUseProductionAdUnitIds({
    required bool debugMode,
    required bool forceTestFromEnvironment,
  }) {
    if (forceTestFromEnvironment) return false;
    if (debugMode) return false;
    return true;
  }

  static String rewardedAdUnitId(RewardedAdPurpose purpose) {
    return rewardedAdUnitIdFor(
      purpose: purpose,
      productionMode: useProductionAdUnitIds,
    );
  }

  @visibleForTesting
  static String rewardedAdUnitIdFor({
    required RewardedAdPurpose purpose,
    required bool productionMode,
  }) {
    if (!productionMode) return androidTestRewardedUnitId;
    // Official unit: DevPath_Quiz_Timer_Retry — used for all rewarded
    // placements in production until separate units are registered.
    return productionRewardedQuizTimerRetry;
  }

  static String get bannerAdUnitId => useProductionAdUnitIds
      ? productionBannerMain
      : androidTestBannerUnitId;

  static String get interstitialAdUnitId => useProductionAdUnitIds
      ? productionInterstitialLesson
      : androidTestInterstitialUnitId;

  /// Legacy getter — prefer [rewardedAdUnitId].
  static String get rewardedAdUnitIdLegacy => rewardedAdUnitId(
        RewardedAdPurpose.questionTimerRetry,
      );
}
