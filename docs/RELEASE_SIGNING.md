# Android release signing — DevPath

## Current configuration

Release builds use `android/app/build.gradle`:

- If `key.properties` exists at the project root ( **not committed** ), release APKs/AABs are signed with that keystore.
- If `key.properties` is **missing**, Gradle falls back to **debug signing** for release builds (suitable for local/CI smoke tests only).

## Required for Play Console upload

1. Create an upload keystore (outside the repo).
2. Add `key.properties` locally:

```properties
storePassword=<secret>
keyPassword=<secret>
keyAlias=<alias>
storeFile=<absolute-or-relative-path-to-keystore>
```

3. Run `flutter build appbundle --release` (or `apk --release`).
4. **Never** commit keystore files, passwords, or `key.properties`.

## Beta recommendation

- **Internal / closed testing:** Use Play App Signing with an upload key you control, or distribute debug APK (`applicationIdSuffix .debug`) outside Play.
- This agent run **does not** produce Play-uploadable signed artifacts without your keystore.
