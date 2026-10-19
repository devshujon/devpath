# DevPath Privacy Policy

**Effective date:** 2026-10-14  
**App:** DevPath — Learn Code & Earn  
**Version:** 1.3.1 (build 16)  
**Android package (production):** `com.devpath.dev`  
**Public web policy:** https://solverpros.com/devpath/privacy-policy/  
**Last updated:** 2026-10-19  
**Contact:** Add a Play-ready support email on the web policy before store submission. Optional: GitHub issues on the DevPath repository (no dedicated in-app email).

This policy describes how the DevPath mobile application handles information when you use it on your device.

---

## 1. Summary

DevPath is designed to work **primarily offline**. Lesson content, quizzes, and most learning features use **bundled assets** on your device. The app stores **learning progress locally** on your phone. DevPath **does not operate a user account system** or sync your progress to DevPath-operated servers in this version.

---

## 2. Information stored on your device

The app may store the following **locally** (for example in SharedPreferences, Hive, or app-private storage):

- Completed lesson IDs and learning progress  
- Experience points (XP), levels, and streaks  
- Earned badges and achievement state  
- Playground / code-editor projects and drafts you save  
- Notification preferences (reminder on/off, time)  
- Code editor settings (font size, theme preferences)  
- Certificate and challenge progress tied to local completion rules  

This data **stays on your device** unless you back up the app through your device manufacturer’s backup system (see Section 6).

---

## 3. Information we do not collect (in-app)

Based on the current application source code for v1.3.0:

- No DevPath login or registration  
- No upload of your learning progress to DevPath servers  
- No in-app analytics SDK usage identified in application Dart code  
- No sale of personal data  

---

## 4. Network use

The app declares **INTERNET** and **ACCESS_NETWORK_STATE** permissions on Android.

**Typical uses:**

- Loading **local** WebView content on platforms where the code editor or preview uses embedded WebViews (on Android, the mobile code editor and playground preview use native Flutter UI instead of WebViews for HTML preview in current builds).  
- **Future or optional features** that may fetch remote content if enabled in a later version.  
- **Google Mobile Ads (AdMob):** Starting in v1.3.0, the app may show **rewarded**, **banner**, and **interstitial** advertisements when enabled in the build. **Debug builds** use Google’s **test** AdMob App ID and test ad units. **Release builds** use DevPath’s production AdMob App ID and ad units configured in the app. Ad requests require network access when ads are shown.
- A **User Messaging Platform (UMP) consent flow is not yet integrated.** Before distributing production ads to users in regions that require consent (for example EEA/UK), DevPath must implement consent and update this policy.

The app does **not** require network access to read bundled curriculum lessons or to take offline lesson quizzes when ads are not loaded or shown.

---

## 5. Notifications

If you enable daily reminders, the app uses **local scheduled notifications** on your device. On Android 13+, the app may request **POST_NOTIFICATIONS** permission. Notification content is generated locally (for example, reminders to continue learning). DevPath does not send your notification history to DevPath servers.

---

## 6. Device backups

Android backup may be enabled (`allowBackup`). Your device or Google backup may copy app-private data according to your system settings. DevPath does not control third-party backup providers.

---

## 7. File import (code editor)

If you use file import, the system file picker lets **you** choose files. DevPath reads only files you select, for editing inside the app. Those files are not transmitted to DevPath servers by the app.

---

## 8. Advertising identifier

The manifest declares **AD_ID** because the project depends on **google_mobile_ads**. AdMob may use the advertising ID per Google’s policies when ads are served. You can limit ad personalization through your device’s advertising settings where your OS provides them.

---

## 9. Children

DevPath is an educational app. We do not knowingly collect personal information from children through DevPath-operated servers. Parents should supervise device permissions and backups.

---

## 10. Changes

We may update this policy for new app versions. The in-app copy is bundled with the app version you install. For the latest text, refer to the copy shipped with your build or the project repository.

---

## 11. Your choices

- You can clear app data in Android system settings to remove local progress.  
- You can deny notification permission; reminders will not appear.  
- You can uninstall the app to remove local data (subject to backup copies on your device).

---

*This document is provided for beta transparency. It is not legal advice.*
