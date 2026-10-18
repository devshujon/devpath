# DevPath — Learn Code & Earn

Android-first Flutter app for learning HTML, CSS, and JavaScript on a phone. Offline playground, roadmap, quizzes, challenges, XP, and a rich curriculum renderer.

See `CHANGELOG.md` for the 1.2.0 curriculum / mobile harden notes.

## Quick start

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

The first command installs dependencies. The second generates Hive type adapter files (`*.g.dart`). The third launches on a connected device or emulator.

## What's in this scaffold

| Layer | Status | Notes |
|-------|--------|-------|
| Folder structure | ✅ Complete | Feature-first |
| `pubspec.yaml` | ✅ Complete | Pinned versions |
| `AndroidManifest.xml` | ✅ Complete | No exact-alarm perms, backup enabled |
| `MainActivity.kt` | ✅ Complete | Battery MethodChannel handler |
| Backup XML | ✅ Complete | `backup_rules.xml`, `data_extraction_rules.xml` |
| Hive models | ⚠️ Stubbed | Annotated, need `build_runner` for `.g.dart` |
| Providers | ⚠️ Stubbed | Class shapes; logic TODO |
| Screens | ⚠️ Stubbed | Compile-clean placeholders |
| Theme | ✅ Complete | Light + dark, Material 3 |
| Routing | ✅ Complete | Named routes, IndexedStack shell |
| Sample lesson JSON | ✅ Complete | One per language (1-2 lessons) |
| Sample quiz JSON | ✅ Complete | One per language (3-5 questions) |
| Quiz validator | ✅ Complete | `dart run tool/validate_quizzes.dart` |

## Where to find the full specifications

This scaffold implements only the structural foundation. For the complete implementation, follow the 17 planning documents (delivered separately):

| Module | Doc | What's inside |
|--------|-----|---------------|
| Foundation | `devpath_foundation.md` | Hive setup, theme, navigation |
| Lessons | `devpath_learning_module.md` | Lesson loader + progress |
| Editor | `devpath_editor.md` | CodeMirror WebView + projects |
| Ads | `devpath_admob.md` | Banner/interstitial/rewarded |
| Quiz | `devpath_gamification.md` | Quiz + roadmap + streak |
| UI polish | `devpath_uiux_launch.md` | Microinteractions, ASO |
| Share/Export | `devpath_share_export.md` | PDF + ZIP + screenshot |
| Bug fixes | `devpath_fixes_5.md` | 5 critical fixes (apply before ship) |
| Launch | `devpath_launch_runbook.md` | Play Store submission |

## Build order recommendation

1. Run the scaffold to confirm it compiles: `flutter run`
2. Implement `learn_provider.dart` from `devpath_learning_module.md`
3. Implement `editor_screen.dart` from `devpath_editor.md`
4. Implement `quiz_provider.dart` from `devpath_gamification.md`
5. Add AdMob per `devpath_admob.md`
6. Apply all 5 fixes from `devpath_fixes_5.md`
7. Run pre-ship checklist from `devpath_launch_runbook.md`
8. Submit to Play Store internal testing

## Before shipping to production

- [ ] Replace `applicationId` in `android/app/build.gradle` with your own (currently `com.devpath.app`)
- [ ] Generate a signing keystore and configure `key.properties`
- [ ] Replace AdMob App ID in `AndroidManifest.xml` (currently the test ID)
- [ ] Create AdMob unit IDs and wire them in
- [ ] Write actual lesson content (the sample JSON is 1-2 lessons; you need 80+ for launch)
- [ ] Generate app icon (currently using Flutter default)
- [ ] Write privacy policy and host the URL
- [ ] Run `dart run tool/validate_quizzes.dart` — must exit 0
- [ ] Test on Android 8 (API 26) device — your floor
- [ ] Test on a Xiaomi/Vivo device for OEM behavior
