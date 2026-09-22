# ─────────────────────────────────────────────────────────────────────
# DevPath release ProGuard / R8 rules
#
# R8 is enabled for release builds (minifyEnabled + shrinkResources in
# build.gradle). Each block below preserves classes that plugins access
# via reflection, intent introspection, or native JNI bridges.
# Without these, classes are stripped and the release APK crashes at
# runtime with NoClassDefFoundError or similar.
# ─────────────────────────────────────────────────────────────────────

# Flutter platform — preserved by Flutter's own consumer rules but we
# keep the explicit declaration to survive R8 mode changes.
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Hive — TypeAdapters are looked up reflectively by class-name suffix.
-keep class **$HiveFieldAdapter { *; }
-keep class **Adapter { *; }
-keep class com.tekartik.hive.** { *; }

# Google Mobile Ads (AdMob)
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.internal.ads.** { *; }
-keep class com.google.android.gms.common.** { *; }
-dontwarn com.google.android.gms.**

# Flutter WebView (CodeMirror editor host)
-keep class io.flutter.plugins.webviewflutter.** { *; }

# flutter_local_notifications — package is com.dexterous.flutterlocalnotifications
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }

# Gson (transitively used by flutter_local_notifications for payload serialization)
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepattributes Signature
-keepattributes *Annotation*
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# share_plus — FileProvider lookup is by manifest entry, but keep the
# class explicit to be safe under aggressive optimization.
-keep class dev.fluttercommunity.plus.share.** { *; }
-keep class androidx.core.content.FileProvider { *; }

# permission_handler
-keep class com.baseflow.permissionhandler.** { *; }

# shared_preferences (Android side uses reflection-free MethodChannel,
# but we keep the impl class to be safe).
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# path_provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Kotlin runtime — coroutines metadata.
-keep class kotlin.Metadata { *; }
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}
-dontwarn kotlin.**
-dontwarn kotlinx.**

# Java desugar — referenced by coreLibraryDesugaring; safe to suppress.
-dontwarn java.lang.invoke.**
-dontwarn java.time.**
-dontwarn javax.annotation.**
-dontwarn org.jetbrains.annotations.**

# Keep attributes that crash-reporting tools rely on. We aren't shipping
# Crashlytics today but keeping these costs nothing.
-keepattributes Signature, *Annotation*, EnclosingMethod, InnerClasses
-keepattributes SourceFile, LineNumberTable

# Re-export source/line numbers for readable stack traces post-obfuscation.
-renamesourcefileattribute SourceFile
