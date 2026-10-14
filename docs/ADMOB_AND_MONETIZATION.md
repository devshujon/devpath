# AdMob and monetization — DevPath v1.2.1 beta

## Current status (code inspection, v1.2.1+14)

| Item | Status |
|------|--------|
| `google_mobile_ads` in `pubspec.yaml` | Present |
| `MobileAds`, `BannerAd`, `RewardedAd` in `lib/` | **Not used** |
| Ad widgets in UI | **None** |
| AndroidManifest `APPLICATION_ID` | **Google test ID** `ca-app-pub-3940256099942544~3347511713` |
| `AD_ID` permission | Declared (dependency default) |

## Beta behavior

- **No advertisements are displayed** to users in this build.
- The test App ID must **not** be replaced with production IDs until ads are implemented and reviewed.
- **Do not** enable production ad units for closed testing without implementing UI, error handling, and policy updates.

## Consent (future)

If ads are added for EEA/UK users, integrate Google’s User Messaging Platform (UMP) or equivalent consent flow before loading ads. Document the choice in an updated privacy policy.

## Recommendation for beta

Safe to ship **without ad UI** for learning-focused closed testing. Before Play production with ads: implement ads, switch manifest ID, add consent where required, and re-audit.
