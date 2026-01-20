# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.**

# Google Fonts
-keep class com.google.android.gms.fonts.** { *; }
-keep class com.google.fonts.** { *; }

# Google Fonts
-keep class com.google.android.gms.fonts.** { *; }
-keep class io.flutter.plugins.googlefonts.** { *; }

# Prevent obfuscation of specific names if used in reflection (just in case)
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
