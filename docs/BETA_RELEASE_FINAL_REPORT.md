# DevPath v1.2.1+14 — Android beta release preparation (final report)

**Date:** 2026-10-14  
**Branch:** `cursor/app-audit-982f` @ **`744ca2a`**  
**Base integration branch:** `cursor/release-v1-2-1-982f` (quiz fixes through bottom sheet @ `6d10488`)  
**Pull request:** https://github.com/devshujon/devpath/pull/5 (draft — **not merged**)

---

## 1. Final Git branch and commit

| Item | Value |
|------|--------|
| Working branch | `cursor/app-audit-982f` |
| Audit baseline | `9b31b32` — complete audit report |
| Release quiz line | `6d10488` — H1 quiz bottom sheet (1.2.1+13), preserved |
| Beta-prep commit | `744ca2a` — privacy policy, QA checklist, signing/AdMob docs, profile flows |

**Phase 1 — audit review**

- Read `docs/DEVPAT_COMPLETE_AUDIT_REPORT.md`.
- Audit branch is **2 commits ahead** of `cursor/release-v1-2-1-982f`: audit polish `3860c0a`, report `9b31b32`. Quiz architecture unchanged (bottom sheet + Android WebView policy).
- No quiz fixes found on release branch that are missing from audit branch.
- H1 quiz implementation preserved; no rewrite.

---

## 2. PR status

- **PR #5:** `cursor/app-audit-982f` → `cursor/release-v1-2-1-982f` — open, draft.
- **Not merged** per release instructions.
- **PR #4** (release → `main`) unchanged.

---

## 3. Remaining release blockers

| Blocker | Severity | Notes |
|---------|----------|--------|
| Production upload signing | High for Play | No `key.properties` in repo; release APK signed with **debug** fallback |
| Public privacy policy URL | High for Play listing | In-app + repo markdown only; **not hosted** at a public HTTPS URL |
| Full device regression on **+14** | Medium | Honor evidence for **+13** quiz; checklist mostly `[UNVERIFIED]` on +14 |
| AdMob / monetization | Low for ad-free beta | SDK present; **no ad UI**; test App ID in manifest |
| Kotlin 2.2.20 deprecation warning | Low | Flutter warns; build still succeeds |

---

## 4. Privacy policy status

| Deliverable | Status |
|-------------|--------|
| `docs/legal/PRIVACY_POLICY.md` | Authoritative source text |
| `assets/legal/privacy_policy.md` | Bundled asset (pubspec) |
| In-app viewer | `PrivacyPolicyScreen` from Profile |
| Public URL | **Not published** — do not use a invented link in store listings |

Covers: local storage (Hive/SharedPreferences), notifications, network permissions, AdMob dependency (test ID, no UI ads), backups, file picker, AD_ID declaration.

---

## 5. AdMob status

Documented in `docs/ADMOB_AND_MONETIZATION.md`.

- **UI:** No ads displayed.
- **Manifest:** Google **test** App ID only.
- **Consent:** N/A until ads are implemented; UMP noted for future EEA/UK.

---

## 6. Signing status

Documented in `docs/RELEASE_SIGNING.md`.

- `android/app/build.gradle`: release uses upload keystore when `key.properties` exists; otherwise **debug signing**.
- Keystores and passwords **not** in repository.
- This run: **no production-signed artifact** produced.

---

## 7. `flutter analyze`

```
No issues found!
```

---

## 8. `flutter test`

```
89/89 passed
```

---

## 9. Debug build

```
flutter build apk --debug
✓ build/app/outputs/flutter-apk/app-debug.apk
```

| Metric | Value |
|--------|--------|
| Size | 192,252,250 bytes (~183.4 MiB) |
| Application ID | `com.devpath.app.debug` |
| SHA-256 | `01daa35f5fe1e2dcf6b011d51e3efd02be66bf6a92cff3256d1874d6c5f45b95` |

---

## 10. Release build

```
flutter build apk --release
✓ build/app/outputs/flutter-apk/app-release.apk (61.8MB)
flutter build appbundle --release
✓ build/app/outputs/bundle/release/app-release.aab (61.0MB)
```

| Metric | Release APK |
|--------|-------------|
| Path (canonical) | `build/app/outputs/flutter-apk/app-release.apk` |
| Copy | `artifacts/beta/devpath-1.2.1+14-release.apk` |
| Size | 61,783,669 bytes (~58.9 MiB) |
| SHA-256 | `3693bcc763dafada48046c1c5e2dbd63ebe4f2ff519f1e2b6bf9bf2ff7975d9e` |
| Application ID | `com.devpath.app` |
| versionName / versionCode | 1.2.1 / 14 |

| Metric | Release AAB (inspection only) |
|--------|-------------------------------|
| Path | `build/app/outputs/bundle/release/app-release.aab` |
| Copy | `artifacts/beta/devpath-1.2.1+14-release.aab` |
| Size | 60,968,490 bytes (~58.1 MiB) |
| SHA-256 | `de03b3f246534504290346bed3148bee96875731e7f36f0c24bd78088e0439d1` |

**Release configuration:** `minifyEnabled true`, `shrinkResources true`, Material Icons tree-shaken; debug quiz yellow bar and debug Snackbars gated with `kDebugMode` only.

---

## 11. Release APK path, size, SHA-256

See section 10. Primary artifact:

- **Path:** `/workspace/build/app/outputs/flutter-apk/app-release.apk`
- **Size:** 61,783,669 bytes
- **SHA-256:** `3693bcc763dafada48046c1c5e2dbd63ebe4f2ff519f1e2b6bf9bf2ff7975d9e`

---

## 12. Source ZIP

Created after validation from committed tree (`git archive`), excluding `.git/`, `build/`, `.dart_tool/` by design.

| Item | Value |
|------|--------|
| Path | `artifacts/beta/devpath_source_1.2.1+14.zip` |
| Size | 659,413 bytes (~644 KiB) |
| SHA-256 | `3d758a1ab71ff002029257601bc9f3bbf4d1cf79bc9f1ba8b14a00c9d147f9ec` |
| Verify | Extracted to `/tmp/devpath-src-verify` → `flutter pub get` succeeded |

---

## 13. Actual physical-device test results

| Test | Result | Evidence |
|------|--------|----------|
| H1 quiz visible (question, options, Next, progress) | **Pass** | User screenshot on **Honor**, build **v1.2.1+13** |
| About shows version | **Pass** | User screenshot **+14** (conversation) |
| Full `docs/BETA_QA_CHECKLIST.md` on +14 | **Not run** in cloud agent environment | — |
| Editor → Quiz, Playground → Quiz, upgrade path | **Unverified** on device | — |

**Do not** treat cloud VM builds as device tests.

---

## 14. Remaining unverified risks

- Quiz overlay regression on other OEMs / API levels without bottom-sheet path tested.
- Notification scheduling after permission grant/deny on real devices.
- Large APK on metered downloads (acceptable for beta; curriculum + Flutter engine dominate size).
- Release signed with debug key: cannot upload to Play as production; sideload only for internal testers.
- Impeller disabled via manifest meta-data (Honor workaround) — performance tradeoff on other devices.

---

## 15. Final recommendation

| Tier | Verdict |
|------|---------|
| Development only | **Yes** — fully validated in CI |
| Internal beta ready | **Yes** — with debug APK or release APK sideload; run QA checklist on +14 |
| Closed testing ready (Play) | **Conditional** — needs upload keystore, hosted privacy URL for store form, and device QA on target build |
| Production release ready | **No** — signing, store policy hosting, broader QA, ad/monetization strategy unresolved |

**Aligned with audit:** Conditional **GO** for controlled Android beta; **not** production GO.

---

## Phase 4 — APK size notes (~62 MB release)

- **Reasonable** for Flutter 3.x engine + bundled curriculum (`assets/lessons`, `assets/quizzes`, `assets/curriculum/html`, editor assets) and dependencies (WebView plugin, notifications, ads SDK without runtime ad load).
- Release build uses **R8 + resource shrink**; debug ~168–192 MB due to no shrink and debug symbols.
- No essential assets removed for size in this pass.

---

## Phase 3 — Manual QA

See **`docs/BETA_QA_CHECKLIST.md`** for the full matrix (install, H1, b01_html, editor/playground paths, offline, notifications, small screens, system back).

---

## Android permissions (Phase 2)

Reviewed `android/app/src/main/AndroidManifest.xml`:

- **Kept:** INTERNET, ACCESS_NETWORK_STATE (WebView/ads dependency), POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED (notifications), AD_ID (ads SDK).
- **Removed:** None — each maps to declared features or dependencies; removing AD_ID without removing `google_mobile_ads` may break dependency expectations.

Notification: Profile → Daily reminder calls `Permission.notification.request()` with user-facing Snackbar.

---

*No Google Play upload, no branch merges, no production keystore committed in this preparation run.*
