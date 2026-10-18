import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ad_consent.dart';
import 'admob_config.dart';
import 'rewarded_ad_coordinator.dart';

/// Lesson-transition interstitial with frequency cap. Never shown during quiz UI.
class InterstitialAdCoordinator {
  InterstitialAdCoordinator._();
  static final InterstitialAdCoordinator instance =
      InterstitialAdCoordinator._();

  static const _prefLastShownMs = 'admob_interstitial_last_shown_ms';
  static const _minInterval = Duration(minutes: 15);
  static const _showTimeout = Duration(seconds: 8);

  InterstitialAd? _loaded;
  bool _loading = false;
  bool _showing = false;

  Future<void> preload() async {
    if (!AdMobConsent.canRequestAds || _loaded != null || _loading) return;
    await RewardedAdCoordinator.instance.ensureInitialized();
    _loading = true;
    try {
      final completer = Completer<InterstitialAd?>();
      // ignore: unawaited_futures
      InterstitialAd.load(
        adUnitId: AdMobConfig.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            if (!completer.isCompleted) completer.complete(ad);
          },
          onAdFailedToLoad: (error) {
            debugPrint('Interstitial load failed: $error');
            if (!completer.isCompleted) completer.complete(null);
          },
        ),
      );
      final ad = await completer.future.timeout(
        const Duration(seconds: 12),
        onTimeout: () => null,
      );
      _loaded = ad;
    } finally {
      _loading = false;
    }
  }

  Future<void> maybeShowLessonTransition() async {
    if (_showing) return;
    if (!AdMobConsent.canRequestAds) return;
    if (!await _frequencyAllows()) return;

    await preload();
    final ad = _loaded;
    if (ad == null) return;

    _showing = true;
    _loaded = null;
    final completer = Completer<void>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial show failed: $error');
        ad.dispose();
        if (!completer.isCompleted) completer.complete();
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completer.isCompleted) completer.complete();
      },
    );

    try {
      ad.show();
      await completer.future.timeout(_showTimeout, onTimeout: () {});
      await _recordShown();
    } catch (e) {
      debugPrint('Interstitial show error: $e');
    } finally {
      _showing = false;
      // ignore: unawaited_futures
      preload();
    }
  }

  Future<bool> _frequencyAllows() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt(_prefLastShownMs);
    if (last == null) return true;
    final elapsed = DateTime.now().millisecondsSinceEpoch - last;
    return elapsed >= _minInterval.inMilliseconds;
  }

  Future<void> _recordShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _prefLastShownMs,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  void dispose() {
    _loaded?.dispose();
    _loaded = null;
  }
}
