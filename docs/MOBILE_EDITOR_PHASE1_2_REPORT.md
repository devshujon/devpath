# DevPath mobile code editor — Phases 0–2 report

**Date:** 2026-10-14  
**Branch:** `cursor/pro-mobile-editor-982f`  
**Baseline:** `cursor/app-audit-982f` @ `5fd1fae` (v1.2.1+14)

---

## 1. Baseline branch and commit

| Item | Value |
|------|--------|
| Starting branch | `cursor/app-audit-982f` |
| Work branch | `cursor/pro-mobile-editor-982f` |
| App version | 1.2.1+14 (unchanged) |

---

## 2. Architecture findings (Phase 0)

| Area | Finding |
|------|---------|
| **Editor hub** | `EditorScreen` in main shell tab; routes to Playground, Lessons, Projects, separate `CodeEditorHomeScreen` |
| **Playground** | `PlaygroundProvider` + Hive `ProjectStorage` + `AutosaveService`; HTML/CSS/JS tabs |
| **Preview** | `PreviewPane` with WebView on non-Android; Android embedded preview = static text (quiz-safe) |
| **CodeMirror assets** | `assets/editor/` bundled; used by `CodemirrorEditorPane` when WebView allowed |
| **Android policy** | `android_webview_policy.dart` disables CodeMirror + embedded preview WebView on Android |
| **Quiz protection** | `PlatformViewGate`, route-aware detach, lesson quiz bottom sheet on Android |
| **Reuse** | No duplicate project models; settings shared via `CodeEditorSettingsStorage` |

---

## 3. Files changed (summary)

- **Hub:** `lib/features/editor/screens/editor_screen.dart`
- **Playground UI:** `playground_screen.dart`, `playground_toolbar.dart`
- **Editor:** `playground_code_editor_pane.dart`, `syntax_highlighted_editor.dart`, accessory/find/settings widgets
- **Preview:** `playground_preview_document.dart`, `playground_live_preview_screen.dart`, `preview_pane.dart`, `android_webview_policy.dart`
- **Provider:** `playground_provider.dart` (pane view mode)
- **Deps:** `code_text_field`, `highlight`
- **Tests:** `test/editor/*`
- **Docs:** this report

---

## 4. Features implemented

### Phase 1 — Editor experience

- **Code Studio** hub: Playground, New project, Import HTML, Recent projects, Templates, My projects, File workspace link
- **Playground:** project title in app bar, unsaved indicator, HTML/CSS/JS tabs, Run/Save/Copy/Reset toolbar
- **Mobile layout:** Editor ↔ Preview segmented control (360–430dp friendly); wide layout keeps side-by-side split
- **Settings sheet:** font size, word wrap, line numbers, dark editor surface (persisted)

### Phase 2 — Real code editing

- **Android:** `CodeField` (`code_text_field`) with HTML/CSS/JS highlight modes, line numbers, tab indent + block modifiers from package
- **iOS/desktop:** existing CodeMirror WebView via `PlaygroundCodeEditorPane`
- **Accessory bar:** undo/redo stack, select all, copy, find/replace sheet, symbol shortcuts per tab
- **Minimum safe preview validation:** embedded preview remains static on Android; **full-screen Live preview** route may use WebView and is disposed on pop

---

## 5. Features not implemented (deferred Phases 3–6)

- Live preview in **embedded** Android split (intentionally static)
- Ten-template catalog expansion (still 7 lesson templates)
- Export/share HTML bundle from playground
- Rename/duplicate project from playground app bar
- ZIP import
- UMP / ad changes
- Desktop-IDE parity (multi-pane, SCM, debugger)

---

## 6. Editor / preview architecture

```
EditorScreen (hub)
  → PlaygroundScreen
       → PlaygroundCodeEditorPane
            Android: SyntaxHighlightedEditor (CodeField, no platform view)
            Other:   CodemirrorEditorPane (WebView + gate)
       → PreviewPane (embedded)
            Android: static text strip
            Other:   WebView + navigation block + error trap
       → PlaygroundLivePreviewScreen (pushed)
            Android: WebView allowed (androidLivePreview: true), torn down on pop
```

Document assembly: `buildPlaygroundPreviewDocument()`.

---

## 7. WebView security and lifecycle

- Navigation limited to `about:` / `data:` in `PreviewPane`
- No JS bridges to user code
- `PlatformViewGate`, `RouteAware` detach, registry hard-release unchanged
- **No WebView on Android playground editor surface** (quiz regression avoidance)
- Dedicated preview route only when user opens full-screen live preview

---

## 8. Project storage changes

**None** — reuses `ProjectStorage`, `AutosaveService`, `ProjectsListProvider`.

---

## 9. Tests added

| Test | Purpose |
|------|---------|
| `playground_document_builder_test.dart` | HTML/CSS/JS merge + script escape |
| `playground_provider_view_test.dart` | Pane view + Run commit |
| `editor_hub_layout_test.dart` | Hub at 390dp width |

Existing quiz/platform tests still pass (94 total).

---

## 10–11. flutter analyze / flutter test

- **analyze:** clean (info-level const hints only)
- **test:** **94/94 passed**

---

## 12. Debug build

`flutter build apk --debug` — success (see CI/local `build/app/outputs/flutter-apk/app-debug.apk`).

---

## 13. Release build

**Not run** in this scope (no release artifact requested).

---

## 14. Remaining issues

- Android **embedded** preview does not execute JS (by design until Phase 3 validates device-safe embedded WebView)
- Live preview WebView on Android needs **physical device** verification (Honor quiz regression)
- Undo/redo is custom stack (not merged with system undo on all platforms)
- `CodeField` performance on very large files untested on device

---

## 15. Physical device tests still required

- Editor keyboard + accessory bar at 360/390/430 dp
- Full-screen **Live preview** with user JS; then Learn → H1 quiz (no blank sheet)
- Editor → Preview → back → lesson quiz path
- CodeMirror path on iOS if available

---

## Phases 3–6 readiness

**Ready to begin Phase 3** with focus on: device-proven live preview strategy, expanded templates, import/export polish, and navigation regression suite on Android hardware — **after** closed-device validation of the new live preview route + quiz interaction.
