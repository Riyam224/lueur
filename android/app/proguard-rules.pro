# Firebase (Auth, Analytics) — these SDKs ship their own consumer-rules.pro
# inside their AARs, applied automatically. These extra rules are a
# defense-in-depth safety net, not strictly required in most setups.
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Sentry — also ships consumer rules, but native crash-handling code
# specifically benefits from an explicit keep rule since it's invoked
# via JNI, which R8 can't trace automatically.
-keep class io.sentry.** { *; }
-dontwarn io.sentry.**

# Flutter's own embedding — required, not just precautionary. Flutter's
# Java/Kotlin host code is invoked from native engine code that R8 can't
# see, so this one actually matters.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Play Core (used by Flutter's deferred components / split install support)
-dontwarn com.google.android.play.core.**

# Keep any class annotated with @Keep (Firebase and other Google SDKs use
# this annotation internally to mark reflection-accessed classes)
-keep @androidx.annotation.Keep class * { *; }
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}
