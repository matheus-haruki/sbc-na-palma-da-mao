# Regras ProGuard / R8 para o SBC + i

# Flutter Engine e Plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Preserva anotações e assinaturas para reflexão e JNI
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep Flutter MethodChannels e EventChannels
-keep class * implements io.flutter.plugin.common.PluginRegistry$* { *; }
-keep class * implements io.flutter.embedding.engine.plugins.FlutterPlugin { *; }
-keep class * implements io.flutter.plugin.common.MethodChannel$MethodCallHandler { *; }
-dontwarn java.awt.**
-dontwarn javax.annotation.**
-dontwarn com.google.android.play.core.**

