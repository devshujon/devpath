# DevPath PR #6 — Honor / Android physical QA checklist

**Build:** debug APK from `cursor/pro-mobile-editor-982f`  
**Version:** 1.2.1+14  
**Device evidence required:** screenshot or screen recording per section

Mark each row: **PASS** / **FAIL** / **SKIP** + notes.

---

## A. Editor buffers (Playground)

| # | Step | Expected |
|---|------|----------|
| A1 | Open Playground, edit HTML/CSS/JS on each tab | Each tab keeps its own content when switching |
| A2 | Tap **Run** | Live preview opens (full screen on Android); JS runs (e.g. button click) |
| A3 | Back from live preview | Same editor content as before; unsaved dot if edited |
| A4 | Open live preview 3× (open/back) | No crash; editor content unchanged |
| A5 | Save project, kill app, reopen project | All three buffers restored |

---

## B. Embedded vs live preview (Android)

| # | Step | Expected |
|---|------|----------|
| B1 | Editor → **Preview** tab (embedded) | Label **Embedded preview (text only)**; disclaimer about JS/CSS |
| B2 | Embedded preview | **No** styled layout / **no** JS execution |
| B3 | **Open live preview** / **Run** | Full-screen WebView; HTML+CSS+JS work |
| B4 | `alert()` or `console.log` in user JS | Runs in live preview only; app does not crash |

---

## C. Critical quiz regression (Honor)

| # | Step | Expected |
|---|------|----------|
| C1 | Playground → Run → live preview → Back → Learn → H1 → **Take Quiz** | Quiz body visible (Q1, options, Next) — **not blank/black** |
| C2 | Code Studio → Learn → H1 → Quiz (no playground) | Quiz visible |
| C3 | Open quiz twice (back and retake) | Options still visible |
| C4 | After live preview, system Back from quiz | Returns to lesson |

---

## D. WebView / lifecycle

| # | Step | Expected |
|---|------|----------|
| D1 | Live preview open → Home → return to app | No frozen overlay on Dashboard/Learn |
| D2 | Live preview open → switch to Learn tab (if applicable) | No ghost WebView over lesson |
| D3 | App background 30s with live preview open → foreground | Preview or editor recover cleanly |

---

## E. Projects & templates

| # | Step | Expected |
|---|------|----------|
| E1 | Starter template → edit → Save as new | Template list unchanged; new project has edits |
| E2 | Rename / Duplicate / Delete | List updates; duplicate is independent |
| E3 | Import HTML (&lt;1 MB) | Opens in playground as editable HTML tab |

---

## F. Import / export

| # | Step | Expected |
|---|------|----------|
| F1 | Import file &gt;1 MB (if available) | Clear error; no crash |
| F2 | Export HTML from playground menu | Share sheet with combined HTML |
| F3 | Re-open exported file via import | Content readable (spot-check) |

---

## G. Learning progress (no regression)

| # | Step | Expected |
|---|------|----------|
| G1 | Complete a lesson quiz | XP/streak update as before |
| G2 | Existing saved projects | Still listed after app update |

---

**Automated tests cover:** navigation mocks (C partial), buffer logic, static Android copy, import/export limits — **not** real WebView compositing on Honor.
