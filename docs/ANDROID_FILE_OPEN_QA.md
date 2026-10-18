# Android “Open with” — Physical QA (PR #9)

**PR:** https://github.com/devshujon/devpath/pull/9  
**Feature commit:** `9045cfe175b9021cb5f3cd4e8089bbb0f1ca8c7a`  
**QA doc / handoff commit:** `7ef7cad` (includes expanded checklist; rebuild debug APK at this commit)  
**Base commit:** `5204fcc045d0ddffbb789eedb4c99caeee21854`

## Build artifact (debug — for Honor manual QA)

| Field | Value |
|--------|--------|
| Branch | `cursor/android-file-open-982f` |
| Git commit (handoff) | `7ef7cad` (feature logic in `9045cfe`) |
| Working tree | Clean (no uncommitted changes at doc refresh) |
| Package ID (debug) | `com.devpath.app.debug` |
| Version (pubspec) | `1.3.0+15` |
| Version name (debug APK) | `1.3.0-debug` (see `android/app/build.gradle` `versionNameSuffix`) |
| APK path (repo build) | `build/app/outputs/flutter-apk/app-debug.apk` |
| APK size | ~184 MB (debug; includes symbols — normal for Flutter debug) |
| SHA-256 | `4f1e35bc79d2e8638a15747fb3937aa9bead7792e2eb4ee9eaa388e442be09b9` |

**Install (USB):**

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Debug build installs **alongside** release (`com.devpath.app`) because of `.debug` application id suffix.

## Automated vs physical

| Automated (CI / agent) | Physical device only |
|------------------------|----------------------|
| `flutter analyze` | Android **Open with** chooser lists DevPath |
| `flutter test` (158 tests) | VIEW / SEND from Files, Downloads, Gmail, WhatsApp |
| MIME/extension detection unit tests | SAF export path on device |
| Preview HTML builder unit tests | Revoked URI permission after delay |
| `flutter build apk --debug` | Quiz not blank/black after Preview (Honor WebView) |
| | Background/foreground intent delivery |

**Do not mark chooser or intent rows PASS unless tested on hardware.**

---

## Sample files (create in Downloads)

Use a plain text editor or transfer from PC.

**test.html**

```html
<!DOCTYPE html>
<html><head><title>QA</title></head>
<body><h1>DevPath QA</h1>
<p><a href="https://example.com">External link</a></p>
</body></html>
```

**test.css** — `body { background: #222; color: #0f0; }`

**test.js** — `console.log('DevPath QA'); document.body?.append('JS OK');`

**test.json** — `{"qa":true,"n":1}`

**test.xml** — `<?xml version="1.0"?><note><qa>true</qa></note>`

**test-empty.html** — empty file (0 bytes)

**test-large.html** — single line > 1 MB (e.g. `python3 -c "print('x'*1048577)"` → save as `.html`)

**test.bin** or **photo.png** — unsupported type

---

## Manual test scripts

Record **PASS / FAIL / SKIP** and notes on device.

### 1. Open HTML from Downloads (ACTION_VIEW)

1. Install debug APK (`com.devpath.app.debug`).
2. Put `test.html` in **Downloads**.
3. Files (or Downloads) → tap `test.html`.
4. If prompted **Open with**, choose **DevPath** (not “Always” unless you intend to test default handler).
5. **Expect:** “Open file” screen with name `test.html`, type **HTML**, size shown if provider supplies it.
6. **Fail if:** DevPath missing from chooser, crash, blank screen.

### 2. Preview HTML — block external navigation

1. From open screen → **Preview**.
2. **Expect:** Heading “DevPath QA” visible; banner about imported HTML / missing linked assets if applicable.
3. Tap link **External link** (`https://example.com`).
4. **Expect:** Page does **not** navigate away (PreviewPane blocks http/https). No external browser unless you add a separate in-app control (there is none).
5. Back to open screen → **Cancel** or system back.

### 3. Edit HTML → save as DevPath project

1. Open `test.html` again → **Edit**.
2. **Expect:** Playground with HTML source loaded.
3. Change visible text (e.g. heading text).
4. Use Playground **Save project** (toolbar/menu — existing flow).
5. Open **Projects** in app → confirm new project with edited content.
6. Alternatively from **Open file** screen (before Edit): **Save as DevPath project** saves **original imported** content — note difference in doc if testing both paths.

### 4. Export new file — original unchanged

1. Open `test.html` → note first line of source in Preview or Edit.
2. **Export as new file** → pick **new name** in Downloads (e.g. `test-export.html`) via SAF.
3. Re-open **original** `test.html` from Downloads (Open with DevPath).
4. **Expect:** Original content unchanged (not the export name/content unless you edited original separately).
5. Open `test-export.html` → **Expect:** exported copy content.

### 5. CSS, JS, JSON, XML — preview & editor

| File | Preview expectation | Edit expectation |
|------|---------------------|------------------|
| `.css` | Source-style page; note “stylesheet only” | Playground, CSS tab/buffer |
| `.js` | Source preview; script **not** executed as full site | Playground, JS buffer |
| `.json` | Pretty-printed if valid JSON | **Code Editor** workspace file |
| `.xml` | Source preview | **Code Editor** workspace file |

Repeat Open with → Preview → Edit for each type.

### 6. ACTION_SEND / Share

For each: `test.html`, `test.css`, `test.js`, `test.json`, `test.xml`:

1. Files app → long-press file → **Share**.
2. **Expect:** DevPath appears (mime-specific SEND filters).
3. Choose DevPath → same **Open file** flow.

If a messenger only sends `application/octet-stream` without extension, DevPath may **not** appear — record as known limitation.

### 7. Edge cases

| Case | Steps | Expect |
|------|--------|--------|
| Empty file | Open `test-empty.html` | Snackbar: file is empty (or read error) — no crash |
| > 1 MB | Open `test-large.html` | Snackbar: too large (max 1 MB) |
| Unsupported MIME | Open `.png` via Open with | DevPath absent **or** unsupported message if opened via generic share |
| Revoked URI | Open file → force-stop provider app / revoke permission if OEM allows → reopen | `permission_denied` or `not_found` snackbar |

### 8. Multiple files & deduplication

1. Open `test.html` → back to home (leave DevPath running).
2. Open `test.css` from Files → **Expect:** new Open file screen for CSS (`onNewIntent`, `force: true`).
3. Open `test.html` again → **Expect:** open screen again (forced delivery).
4. **Risk to watch:** Identical file opened twice in quick succession on **cold start** only may dedupe once (`dedupeKey`); second open from Files while running should still work via `onNewIntent`.

### 9. Preview → Learn → H1 → Quiz (WebView regression)

1. Open `test.html` → **Preview** → back (ensure preview route popped).
2. Bottom nav → **Learn** → open first HTML lesson (**H1 Heading**).
3. **Take Quiz**.
4. **Expect:** Quiz questions visible; timer/options tappable; **no** blank/black screen (Honor platform-view issue).
5. Exit quiz without completing if needed.

### 10. Background / foreground

1. Open any file → Preview.
2. Home button → wait 5 s → return to DevPath.
3. **Expect:** Preview or app resumes without permanent black WebView overlay.
4. Repeat: Open file → Preview → switch to another app → Open **different** file from Files → DevPath.

---

## Cloud agent verification (latest run)

- `flutter analyze` — 12 issues (pre-existing warnings/infos; no errors)
- `flutter test` — **160/160** passed
- `flutter build apk --debug` — success
- **No** physical-device rows executed in cloud

## Remaining risks (PR #9 draft)

1. Chooser visibility varies by OEM MIME guessing (`octet-stream`).
2. Dedupe on cold start only for identical `dedupeKey`.
3. Open-screen “Save as project” uses initial payload, not Playground edits after **Edit**.
4. Linked `<link href="...">` / `<script src="...">` in HTML won't resolve from `content://` parent.
5. Honor/Huawei WebView + Impeller disabled in manifest — quiz regression must be confirmed on device.
6. Debug APK size (~184 MB) — use USB/Wi‑Fi transfer; not Play Store release.

## Short checklist (original)

| # | Step | Pass? | Notes |
|---|------|-------|-------|
| 1 | Create sample files | | |
| 2 | Tap HTML in Files | | |
| 3 | DevPath in Open with | | Device only |
| 4 | Open file UI | | |
| 5 | Preview HTML | | |
| 6 | Edit + Playground | | |
| 7 | Save project / export | | |
| 8 | CSS / JS / JSON / XML | | |
| 9 | Share intent | | |
| 10 | Running app + second file | | |
| 11 | Quiz after preview | | Device only |
