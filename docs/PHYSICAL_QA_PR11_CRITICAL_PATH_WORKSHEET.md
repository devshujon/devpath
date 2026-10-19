# PR #11 — Critical-path manual QA worksheet

**Use with:** `docs/PHYSICAL_QA_PR11_HONOR_CHECKLIST.md` (full checklist)  
**Build:** `1.3.0+15` debug · branch `cursor/web-dev-ecosystem-982f`  
**Device status:** Pending — fill Pass/Fail only on a **physical** Honor (or target) device.

**Tester:** __________ **Date:** __________ **Model / Android:** __________

---

## A. Filter chips (Learn + Roadmap)

Enable airplane mode **after** install unless a step needs network. Note any horizontal overflow or clipped chip labels.

| dp width | All → PHP → SQL → Python → Web Dev → All | Roadmap same chips OK? | Pass/Fail |
|---------:|------------------------------------------|-------------------------|-----------|
| 360 | | | |
| 390 | | | |
| 430 | | | |

---

## B. Offline lessons (new tracks)

Airplane mode **ON**. Open each lesson → confirm rich content (not blank) → open quiz → one question visible.

| ID | Track | Content | Quiz | Pass/Fail |
|----|-------|---------|------|-----------|
| `php_01` | PHP | | | |
| `sql_06` | SQL | | | |
| `python_01` | Python | | | |
| `web_essentials_14` | Web Dev | | | |

---

## C. Progress upgrade (optional baseline APK)

If you have a **pre–PR #11** debug build: complete `h1_heading` + `html_semantic`, then install PR #11 over the top.

| Check | Expected | Pass/Fail |
|-------|----------|-----------|
| Completed badges unchanged | Same lessons still complete | |
| `html_semantic` not re-locked | Can open without re-doing beginner | |
| XP total | Same as before upgrade | |
| Re-open completed lesson quiz | No duplicate XP | |

---

## D. Playground → Live Preview → Back → H1 → Quiz (WebView path)

Network optional. Use **`h1_heading`**.

1. Open **H1** lesson → scroll content (figures if shown) — note ghost WebView: __________  
2. **Open playground** from lesson → edit/run HTML if available → **Live Preview** / static preview on Android — note: __________  
3. **Back** to lesson detail (not force-kill app).  
4. **Take Quiz** — full-screen sheet, buttons tappable — Pass/Fail: __________  
5. Finish or dismiss quiz → navigate **Back** — no WebView overlay blocking taps — Pass/Fail: __________  

---

## E. XP and quiz retry

Pick an **incomplete** lesson (e.g. new track beginner). Record starting XP: __________

| Step | Expected | Pass/Fail |
|------|----------|-----------|
| Pass quiz first time | +XP once | |
| Open same lesson, pass again | +0 XP | |
| Fail quiz once, retry and pass | XP only on first ever pass for that lesson | |
| Rewarded timer retry (if shown) | Extra attempt only via reward rules; no double grant | |

---

## Sign-off

- [ ] Sections A–E attempted on physical device  
- [ ] Failures logged with screenshot + lesson/route  
- **Merge recommendation:** Blocked until A, B, D, E are Pass on device (or waivers documented)
