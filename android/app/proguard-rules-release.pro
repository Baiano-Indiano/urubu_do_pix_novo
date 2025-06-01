# Regras específicas para release

# Mantém as classes anotadas com @Keep
-keep class * {
    @androidx.annotation.Keep <fields>;
}
-keep class * {
    @androidx.annotation.Keep <methods>;
}
-keep @androidx.annotation.Keep class *
-keepclasseswithmembers class * {
    @androidx.annotation.Keep <fields>;
}
-keepclasseswithmembers class * {
    @androidx.annotation.Keep <methods>;
}
-keepclasseswithmembers class * {
    @androidx.annotation.Keep <init>(...);
}

# Mantém classes nativas
-keepclasseswithmembernames class * {
    native <methods>;
}

# Mantém classes de serialização
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Mantém construtores de View
-keepclasseswithmembers class * {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# Mantém métodos de callback
-keepclassmembers class * {
    void *(**On*Event*);
    void *(**On*Listener);
}

# Mantém classes do AndroidX
-keep class androidx.** { *; }
-dontwarn androidx.**

# Mantém classes de suporte
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference
-keep public class * extends android.view.View
-keep public class * extends android.view.ViewGroup
-keep public class * extends android.widget.BaseAdapter
-keep public class * extends androidx.fragment.app.Fragment
-keep public class * extends com.google.android.material.navigation.NavigationView$OnNavigationItemSelectedListener

# Mantém métodos de ciclo de vida
-keep class * extends android.app.Activity {
   public void *(android.view.View);
}
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Remove logs em produção
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}

# Otimizações agressivas
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-mergeinterfacesaggressively
-repackageclasses ''

# Mantém classes de recursos
-keepclassmembers class **.R$* {
    public static <fields>;
}
