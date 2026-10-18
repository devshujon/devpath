# Android “Open with” — Physical device QA checklist

**Feature:** External file open (VIEW / SEND intents)  
**Automated tests:** Intent parsing, MIME/extension detection, preview HTML builders — **not** the system chooser.

## Prerequisites

- Debug APK: `flutter build apk --debug`
- Install on a physical Android device (Honor/Huawei/other).
- Sample files in Downloads: `test.html`, `test.css`, `test.js`, `test.json`, `test.xml`.

## Checklist

| # | Step | Pass? | Notes |
|---|------|-------|-------|
| 1 | Create/download `test.html` | | |
| 2 | Files app → tap `test.html` | | |
| 3 | **Open with** list includes **DevPath** | | Requires intent filters + installed APK |
| 4 | Choose DevPath (once, not default unless user sets) | | |
| 5 | Open screen shows file name, type, size | | |
| 6 | **Preview** renders HTML | | Linked external CSS/JS may be missing — banner shown |
| 7 | Back → **Edit** opens Playground with source | | |
| 8 | Change HTML → Run/Preview in playground | | |
| 9 | **Save as DevPath project** from open screen | | Does not overwrite Downloads original |
| 10 | **Export as new file** via SAF picker | | User picks destination |
| 11 | Open exported copy via Open with again | | |
| 12 | Repeat 2–7 for `.css` and `.js` | | Source-style preview for standalone CSS/JS |
| 13 | Repeat for `.json` / `.xml` → **Edit** opens Code Editor | | |
| 14 | Open file while DevPath already running (`singleTop`) | | Should show new open screen |
| 15 | From Preview, navigate to a lesson quiz | | Quiz taps work (no WebView overlay) |

## Executed in cloud agent run

- `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug`
- **Not executed:** Rows 1–15 on physical hardware (manual only).

## Known limitations

- `application/octet-stream` without a recognizable extension may not match intent filters.
- Overwriting the **original** external file is only possible if the user exports via SAF to that location; DevPath does not silently write back to the source URI.
- Standalone CSS/JS are not executed as a full site in Preview.
- Max open size: **1 MB** (in-memory read).
