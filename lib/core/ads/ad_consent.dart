import 'package:flutter/foundation.dart';

/// Consent gate before requesting ads.
///
/// **UMP (User Messaging Platform) is not integrated yet.** DevPath does not
/// claim GDPR/EEA consent compliance for production ad serving. Before enabling
/// production ads for regulated regions, integrate UMP and update the privacy
/// policy. See `docs/ADMOB_AND_MONETIZATION.md`.
class AdMobConsent {
  AdMobConsent._();

  static bool _canRequestAds = true;

  /// When false, coordinators must not load or show ads.
  static bool get canRequestAds => _canRequestAds;

  static Future<void> prepareForAds() async {
    if (kReleaseMode) {
      debugPrint(
        'AdMob: UMP consent flow not implemented — verify Play/AdMob policy '
        'before serving production ads in EEA/UK.',
      );
    }
    // Placeholder for future UMP integration:
    // final consentInfo = ConsentInformation.instance;
    // await consentInfo.requestConsentInfoUpdate(...);
    _canRequestAds = true;
  }

  @visibleForTesting
  static void resetForTests() {
    _canRequestAds = true;
  }
}
