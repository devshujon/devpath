import 'package:devpath/core/ads/interstitial_ad_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('frequency gate allows first show and blocks within 15 minutes', () {
    expect(
      InterstitialAdCoordinator.frequencyAllows(
        lastShownMs: null,
        nowMs: 0,
        minIntervalMs: const Duration(minutes: 15).inMilliseconds,
      ),
      isTrue,
    );
    expect(
      InterstitialAdCoordinator.frequencyAllows(
        lastShownMs: 0,
        nowMs: 14 * 60 * 1000,
        minIntervalMs: const Duration(minutes: 15).inMilliseconds,
      ),
      isFalse,
    );
    expect(
      InterstitialAdCoordinator.frequencyAllows(
        lastShownMs: 0,
        nowMs: 15 * 60 * 1000,
        minIntervalMs: const Duration(minutes: 15).inMilliseconds,
      ),
      isTrue,
    );
  });
}
