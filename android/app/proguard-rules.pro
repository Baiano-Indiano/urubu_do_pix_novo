# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugin.editing.** { *; }

# Supabase
-keep class io.supabase.** { *; }
-keep class gotrue.** { *; }
-keep class postgrest.** { *; }
-keep class functions.** { *; }
-keep class storage.** { *; }
-keep class realtime.** { *; }

# GSON
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses
-keep class com.google.gson.** { *; }
-keep class com.google.**{*;}

# OkHttp3
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-keep class okio.** { *; }
-keep interface okio.** { *; }

# Retrofit
-keep class retrofit2.** { *; }
-keepclasseswithmembers class * {
    @retrofit2.http.* <methods>;
}

# AndroidX
-keep class androidx.lifecycle.DefaultLifecycleObserver

# Keep R classes
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Keep ViewModels
-keepclassmembers class * extends androidx.lifecycle.ViewModel {
    <init>(...);
}

# Keep Parcelables
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Keep Serializable
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep annotations
-keepattributes *Annotation*
-keep class * extends java.lang.annotation.Annotation { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep JavaScriptInterface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep resources
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Keep the application class
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference
-keep public class * extends androidx.fragment.app.Fragment
-keep public class * extends android.app.Fragment
-keep public class * extends android.view.View
-keep public class * extends android.view.ViewGroup
-keep public class * extends android.widget.BaseAdapter
-keep public class * extends android.widget.AdapterView
-keep public class * extends android.widget.CompoundButton
-keep public class * extends android.widget.TextView
-keep public class * extends android.widget.ImageView
-keep public class * extends android.widget.ImageButton
-keep public class * extends android.widget.ListView
-keep public class * extends android.widget.GridView
-keep public class * extends android.webkit.WebView
-keep public class * extends android.webkit.WebViewClient
