## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

## Gson (used for JSON serialization)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

## Keep all model classes (your data models)
-keep class co.nowshipping.nowcourier.** { *; }

## Geolocator
-keep class com.baseflow.geolocator.** { *; }

## Permission handler
-keep class com.baseflow.permissionhandler.** { *; }

## Image picker
-keep class io.flutter.plugins.imagepicker.** { *; }

## Shared preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

## URL launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

## Path provider
-keep class io.flutter.plugins.pathprovider.** { *; }

## Mobile Scanner and ML Kit for barcode scanning
-keep class com.google.mlkit.vision.barcode.** { *; }
-keep class com.google.android.gms.vision.** { *; }
-keep class dev.steenbakker.mobile_scanner.** { *; }
-dontwarn com.google.mlkit.vision.barcode.**
-dontwarn com.google.android.gms.vision.**

# For CameraX
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

## Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

## Preserve some attributes
-keepattributes SourceFile,LineNumberTable
-keepattributes *Annotation*

## For enumeration classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

## Keep Parcelables
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

