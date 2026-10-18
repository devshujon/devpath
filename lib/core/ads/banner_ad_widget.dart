import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_consent.dart';
import 'admob_config.dart';
import 'rewarded_ad_coordinator.dart';

/// Adaptive banner for non-intrusive placements (Home dashboard footer).
class DevPathBannerAd extends StatefulWidget {
  const DevPathBannerAd({super.key});

  @override
  State<DevPathBannerAd> createState() => _DevPathBannerAdState();
}

class _DevPathBannerAdState extends State<DevPathBannerAd> {
  BannerAd? _banner;
  bool _loaded = false;
  AdSize? _size;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!AdMobConsent.canRequestAds) return;
    await RewardedAdCoordinator.instance.ensureInitialized();
    if (!mounted) return;

    final width = MediaQuery.sizeOf(context).width.truncate();
    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || size == null) return;

    final banner = BannerAd(
      adUnitId: AdMobConfig.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _loaded = true;
            _size = size;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed to load: $error');
          ad.dispose();
        },
      ),
    );
    _banner = banner;
    await banner.load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _banner == null || _size == null) {
      return const SizedBox.shrink();
    }
    return SafeArea(
      top: false,
      child: SizedBox(
        width: _size!.width.toDouble(),
        height: _size!.height.toDouble(),
        child: AdWidget(ad: _banner!),
      ),
    );
  }
}
