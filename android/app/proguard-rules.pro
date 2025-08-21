# ProGuard rules for file_picker plugin
-keep class androidx.lifecycle.DefaultLifecycleObserver
-keep class androidx.lifecycle.LifecycleOwner
-keep class androidx.lifecycle.ProcessLifecycleOwner

# Rules for PDF and document handling
-keep class com.itextpdf.** { *; }
-keep class org.apache.** { *; }
-keep class org.bouncycastle.** { *; }

# Rules for AndroidX
-keep class androidx.** { *; }
-dontwarn androidx.**

# Rules for Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# Rules for file_picker specific classes
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }