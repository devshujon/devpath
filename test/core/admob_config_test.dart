import 'package:devpath/core/ads/admob_config.dart';
import 'package:devpath/core/ads/rewarded_ad_purpose.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdMobConfig production vs test selection', () {
    test('debug mode uses test units', () {
      expect(
        AdMobConfig.resolveUseProductionAdUnitIds(
          debugMode: true,
          forceTestFromEnvironment: false,
        ),
        isFalse,
      );
      expect(
        AdMobConfig.rewardedAdUnitIdFor(
          purpose: RewardedAdPurpose.questionTimerRetry,
          productionMode: false,
        ),
        AdMobConfig.androidTestRewardedUnitId,
      );
      expect(
        AdMobConfig.rewardedAdUnitIdFor(
          purpose: RewardedAdPurpose.questionTimerRetry,
          productionMode: true,
        ),
        AdMobConfig.productionRewardedQuizTimerRetry,
      );
    });

    test('release mode uses production units unless forced test', () {
      expect(
        AdMobConfig.resolveUseProductionAdUnitIds(
          debugMode: false,
          forceTestFromEnvironment: false,
        ),
        isTrue,
      );
      expect(
        AdMobConfig.resolveUseProductionAdUnitIds(
          debugMode: false,
          forceTestFromEnvironment: true,
        ),
        isFalse,
      );
    });

    test('production IDs are not confused with App ID format', () {
      expect(
        AdMobConfig.productionRewardedQuizTimerRetry,
        isNot(contains('~')),
      );
      expect(
        AdMobConfig.androidProductionAppId,
        contains('~'),
      );
    });
  });
}
