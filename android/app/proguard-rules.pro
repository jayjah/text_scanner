# Google GMS
-keep public class com.google.android.gms.* { public *; }
-keep class com.google.android.gms.measurement.AppMeasurementInstallReferrerReceiver
-dontwarn com.google.android.gms.**

# GMS TextRecognizer
-keep public class com.google.mlkit.** { *; }
-keep class com.google.mlkit.** { *; }

-keep public class com.google.mlkit.vision.text.devanagari
-keep class com.google.mlkit.vision.text.devanagari
-keep class com.google.mlkit.vision.text.**
-keep public class com.google.mlkit.vision.text.**
-keep public class com.google.android.gms.vision.text.TextRecognizer { public *; }
-keep public class com.google.android.gms.vision.text.TextRecognizer.** { public *; }
-keep class com.google.android.gms.vision.text.TextRecognizer
-keep class com.google.android.gms.vision.text.TextRecognizer.**

#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.card.payment.** { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugins.googlemaps.** { *; }
-keep class io.flutter.plugins.firebasemessaging.** { *; }
-keep class io.flutter.plugins.firebase.core.** { *; }
-keep class com.google.android.material.slider.** { *; }
-keep interface com.google.android.material.slider.** { *; }
-keep,includedescriptorclasses class io.flutter.plugins.pathprovider.** { *; }
-keep,includedescriptorclasses interface io.flutter.plugins.pathprovider.** { *; }
-keep,includedescriptorclasses class * implements com.google.android.gms.** { *; }
-keep,includedescriptorclasses class com.google.** { *; }
-keep,includedescriptorclasses interface com.google.** { *; }
-keep,includedescriptorclasses class com.google.common.** { *; }
-keep,includedescriptorclasses interface com.google.common.** { *; }
-keep,includedescriptorclasses class android.util.** { *; }
-keep,includedescriptorclasses interface android.util.** { *; }
-keep,includedescriptorclasses class com.google.android.gms.maps.** { *; }
-keep,includedescriptorclasses interface com.google.android.gms.maps.** { *; }
-keep,includedescriptorclasses class javax.inject.Provider.** { *; }
-keep,includedescriptorclasses interface javax.inject.Provider.** { *; }
-keep,includedescriptorclasses class java.lang.ClassValue.** { *; }
-keep,includedescriptorclasses class com.nimbusds.jose.** { *; }
-keep,includedescriptorclasses interface com.nimbusds.jose.** { *; }
-keep,includedescriptorclasses class net.minidev.asm.** { *; }
-keep,includedescriptorclasses interface net.minidev.asm.** { *; }
-keep,includedescriptorclasses class com.stripe.android.** { *; }
-keep,includedescriptorclasses interface com.stripe.android.** { *; }
-keep, includedescriptorclasses class io.card.payment.** { *; }
-keep, includedescriptorclasses interface io.card.payment.** { *; }
-ignorewarnings


# The Maps API uses custom Parcelables.
# Use this rule (which is slightly broader than the standard recommended one)
# to avoid obfuscating them.
-keepclassmembers class * implements android.os.Parcelable {
    static *** CREATOR;
}
# The Maps API uses serialization.
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
-keep class * {
    public private *;
}
-dontwarn com.google.android.maps.GeoPoint
-dontwarn com.google.android.maps.MapActivity
-dontwarn com.google.android.maps.MapView
-dontwarn com.google.android.maps.MapController
-dontwarn com.google.android.maps.Overlay
-dontwarn com.google.android.gms.maps.model.*
-dontwarn javax.annotation.**
-dontwarn javax.inject.**
-dontwarn sun.misc.Unsafe
-dontwarn com.google.common.util.concurrent
-dontwarn com.google.common.reflect
-dontwarn com.google.common.primitives
-dontwarn com.google.common.math
-dontwarn com.google.errorprone.**
-keep class com.google.j2objc.annotations.** { *; }
-dontwarn   com.google.j2objc.annotations.**
-keep class java.lang.ClassValue { *; }
-dontwarn   java.lang.ClassValue
-keep class org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement { *; }
-dontwarn   org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement
-keep,includedescriptorclasses class com.google.protobuf.** { *; }
-keep class androidx.lifecycle.** { *; }
-keep class com.google.crypto.tink.** { *; }
-keep class org.objectweb.asm.** { *; }
-keep class org.bouncycastle.** { *; }
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase
-keepnames class org.jsoup.nodes.Entities
-keepattributes LineNumberTable,SourceFile
-keepattributes *Annotation*, Signature, Exception