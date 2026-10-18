# PR #6 — QA hardening report (automated + code audit)

**Date:** 2026-10-18  
**Branch:** `cursor/pro-mobile-editor-982f`  
**Baseline commit (start):** `66352da`  
**PR:** https://github.com/devshujon/devpath/pull/6  

---

## 1. Report vs implementation

| Report claim | Code verified |
|--------------|---------------|
| Android Run → live preview | `playground_toolbar.dart` → `PlaygroundPreviewLauncher.commitAndOpenLive` when `embeddedPreviewIsStaticOnly` |
| Embedded preview static | `PreviewPane` → `_AndroidStaticPreview` when `!useHtmlPreviewWebViewOnAndroid` |
| Live route WebView | `PlaygroundLivePreviewScreen` sets `androidLivePreview: true` |
| WebView detach on pop | `PreviewPane.dispose` → `_hardReleaseWebView`, registry, gate listener |
| Quiz gate | `lesson_quiz_launcher.dart` → `PlatformViewGate.forceOpen()` on Android |
| 10 templates + legacy map | `lesson_templates.dart` |
| Import 1 MB / export 2 MB | `html_import_service.dart`, `html_export_service.dart` |
| Rename/duplicate/delete | `playground_screen.dart`, `projects_screen.dart`, `project_storage.dart` |

**Mismatch:** None material. Phase 3–6 report accurately describes behavior.

---

## 2. Editor buffer persistence (automated)

Covered by new `playground_buffer_persistence_test.dart`: tab isolation, run vs draft, template copy, starter load.

**Not automated (device):** app kill/restart, autosave dialog, keyboard focus after preview.

---

## 3. WebView / quiz regression (automated)

| Scenario | Automation |
|----------|------------|
| Stale playground/editor routes → quiz | `lesson_quiz_stale_route_test.dart` |
| Playground → mock preview pop → quiz (VM) | Removed — hung `pumpAndSettle` with lesson stack; Honor checklist **C1** |
| Android static vs live preview policy | `preview_android_static_widget_test.dart` |
| Embedded disclaimer UI copy on device | **Physical device** (checklist B1–B2) |
| Real WebView compositing on Honor | **Physical device only** |
| App background with live preview open | **Physical device only** |

---

## 4. Import/export & projects (automated)

Extended `html_export_import_test.dart` with `decodeBytes` UTF-8, latin1 fallback, size cap, empty file.

Existing: export build, export oversize, duplicate project independence, template catalog immutability.

---

## 5. Validation commands (this run)

| Command | Result |
|---------|--------|
| `flutter analyze` | **12 info** (const hints in `playground_code_themes.dart`); **0 errors** |
| `flutter test` | **113/113 passed** |
| `flutter build apk --debug` | **Success** — `build/app/outputs/flutter-apk/app-debug.apk` (**168,081,371** bytes) |

---

## 6. Confirmed bugs / fixes

| Issue | Fix |
|-------|-----|
| Import decode not unit-testable | Added `HtmlImportService.decodeBytes` (behavior unchanged) |
| Missing buffer/regression tests | Added tests listed above |
| No Honor checklist | `docs/PHYSICAL_DEVICE_QA_HONOR_CHECKLIST.md` |

No quiz-architecture changes in this pass.

---

## 7. Remaining risks

- Live preview WebView on real Android may still interact with OEM compositor (Honor) — **requires checklist section C**.
- `Share.share` text export is not a `.html` file attachment on all targets.
- Autosave + preview race on force-kill not fully tested.

---

## 8. Physical device

Use **`docs/PHYSICAL_DEVICE_QA_HONOR_CHECKLIST.md`**. Do not mark production-ready until section **C** passes on Honor with build from this branch.
