import 'package:devpath/core/ads/rewarded_ad_coordinator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class _SequentialMockGateway implements RewardedAdGateway {
  var calls = 0;

  @override
  Future<RewardedAdFlowResult> showPostQuizRewardedAd({
    VoidCallback? onAdShowing,
  }) async {
    calls++;
    onAdShowing?.call();
    return RewardedAdFlowResult.unavailable;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    RewardedAdCoordinator.debugGatewayOverride = null;
  });

  test('mock gateway reports unavailable without granting app rewards', () async {
    final mock = _SequentialMockGateway();
    RewardedAdCoordinator.debugGatewayOverride = mock;

    final result = await RewardedAdCoordinator.gateway.showPostQuizRewardedAd();
    expect(result, RewardedAdFlowResult.unavailable);
    expect(mock.calls, 1);
  });
}
