import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'admob_config.dart';

/// Outcome of attempting to show a post-quiz rewarded ad (monetization only).
enum RewardedAdFlowResult {
  /// User earned the ad reward (watch completed).
  rewardGranted,

  /// Ad closed without earning reward.
  dismissedWithoutReward,

  /// No fill / offline / not supported.
  unavailable,

  /// Load or show failed.
  failed,
}

/// Abstraction for tests and alternate platforms.
abstract class RewardedAdGateway {
  Future<RewardedAdFlowResult> showPostQuizRewardedAd({
    VoidCallback? onAdShowing,
  });
}

/// Loads and shows one rewarded ad at a time. Does not grant app XP.
class RewardedAdCoordinator implements RewardedAdGateway {
  RewardedAdCoordinator._();
  static final RewardedAdCoordinator instance = RewardedAdCoordinator._();

  @visibleForTesting
  static RewardedAdGateway? debugGatewayOverride;

  static RewardedAdGateway get gateway =>
      debugGatewayOverride ?? RewardedAdCoordinator.instance;

  bool _initialized = false;
  bool _sessionInFlight = false;
  RewardedAd? _loadedAd;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true;
      return;
    }
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
    } catch (e, st) {
      debugPrint('AdMob init failed: $e\n$st');
    }
  }

  void dispose() {
    _loadedAd?.dispose();
    _loadedAd = null;
  }

  @override
  Future<RewardedAdFlowResult> showPostQuizRewardedAd({
    VoidCallback? onAdShowing,
  }) async {
    if (_sessionInFlight) {
      return RewardedAdFlowResult.unavailable;
    }
    if (kIsWeb) {
      return RewardedAdFlowResult.unavailable;
    }

    await ensureInitialized();
    if (!_initialized) {
      return RewardedAdFlowResult.unavailable;
    }

    _sessionInFlight = true;
    try {
      final ad = await _loadRewardedAd();
      if (ad == null) {
        return RewardedAdFlowResult.unavailable;
      }

      final completer = Completer<RewardedAdFlowResult>();
      var rewardReported = false;
      var finished = false;

      void finish(RewardedAdFlowResult result) {
        if (finished) return;
        finished = true;
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      }

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Rewarded show failed: $error');
          ad.dispose();
          _loadedAd = null;
          finish(RewardedAdFlowResult.failed);
        },
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadedAd = null;
          finish(
            rewardReported
                ? RewardedAdFlowResult.rewardGranted
                : RewardedAdFlowResult.dismissedWithoutReward,
          );
        },
      );

      onAdShowing?.call();
      await ad.show(
        onUserEarnedReward: (ad, reward) {
          if (rewardReported) return;
          rewardReported = true;
          // Monetization only — no duplicate quiz XP or lesson completion.
        },
      );

      return await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () => RewardedAdFlowResult.failed,
      );
    } catch (e, st) {
      debugPrint('Rewarded ad flow error: $e\n$st');
      return RewardedAdFlowResult.failed;
    } finally {
      _sessionInFlight = false;
    }
  }

  Future<RewardedAd?> _loadRewardedAd() async {
    _loadedAd?.dispose();
    _loadedAd = null;

    final completer = Completer<RewardedAd?>();

    RewardedAd.load(
      adUnitId: AdMobConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _loadedAd = ad;
          if (!completer.isCompleted) completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded load failed: $error');
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );

    return completer.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () => null,
    );
  }
}
