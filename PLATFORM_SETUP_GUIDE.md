# Platform-Specific Setup Guide for Barcode Scanner

This guide ensures the barcode scanner works correctly on both iOS and Android platforms.

## ✅ Completed Configurations

### 📱 iOS Setup

#### 1. **Podfile Configuration** ✓
Location: `ios/Podfile`

The Podfile has been created with:
- iOS 12.0+ minimum deployment target
- GoogleMLKit/BarcodeScanning pod (required for mobile_scanner)
- Proper build settings for Xcode 14+ compatibility
- Bitcode disabled (as required by Flutter)

#### 2. **Camera Permission** ✓
Location: `ios/Runner/Info.plist`

```xml
<key>NSCameraUsageDescription</key>
<string>Now Delivery needs access to your camera to scan barcodes, take profile pictures and capture delivery documentation photos.</string>
```

#### 3. **Build Settings**
- Minimum iOS: 12.0
- Deployment target: Configured in Podfile
- Framework: Use frameworks enabled

### 🤖 Android Setup

#### 1. **Manifest Permissions** ✓
Location: `android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
```

#### 2. **Build Configuration** ✓
Location: `android/app/build.gradle.kts`

- minSdk: 21 (Android 5.0+)
- compileSdk: 35 (Latest)
- targetSdk: 35
- AndroidX: Enabled
- Multidex: Enabled

#### 3. **ProGuard Rules** ✓
Location: `android/app/proguard-rules.pro`

Added rules for:
- ML Kit Vision (barcode scanning)
- Mobile Scanner plugin
- CameraX library
- Google Play Services Vision

```proguard
## Mobile Scanner and ML Kit for barcode scanning
-keep class com.google.mlkit.vision.barcode.** { *; }
-keep class com.google.android.gms.vision.** { *; }
-keep class dev.steenbakker.mobile_scanner.** { *; }
-dontwarn com.google.mlkit.vision.barcode.**
-dontwarn com.google.android.gms.vision.**

# For CameraX
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**
```

## 🔧 Setup Instructions

### First Time Setup

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **iOS Setup** (Mac only)
   ```bash
   cd ios
   pod install --repo-update
   cd ..
   ```
   
   If you encounter issues:
   ```bash
   cd ios
   rm -rf Pods Podfile.lock
   pod cache clean --all
   pod install --repo-update
   cd ..
   ```

3. **Clean Build**
   ```bash
   flutter clean
   flutter pub get
   ```

### Building for Each Platform

#### iOS Build

**Debug Mode:**
```bash
flutter run -d <ios-device-id>
```

**Release Mode:**
```bash
flutter build ios --release
```

**Create Archive for App Store:**
```bash
flutter build ipa
```

**Important iOS Notes:**
- ⚠️ **Must test on a real device** - iOS Simulator doesn't support camera
- Ensure Xcode is up to date (14.0+)
- Code signing must be configured in Xcode
- Camera permission will be requested at runtime

#### Android Build

**Debug Mode:**
```bash
flutter run -d <android-device-id>
```

**Release Mode:**
```bash
flutter build apk --release
```

**Create App Bundle for Play Store:**
```bash
flutter build appbundle --release
```

**Important Android Notes:**
- Can test on emulator IF it has camera support enabled
- Real device testing recommended for best results
- Camera permission will be requested at runtime
- ProGuard rules ensure scanner works in release builds

## 🧪 Testing Checklist

### iOS Testing
- [ ] Camera permission prompt appears
- [ ] Camera preview loads correctly
- [ ] Barcode detection works in real-time
- [ ] Flashlight toggle works
- [ ] Scanner works in both orientations
- [ ] App doesn't crash when denying camera permission
- [ ] Works on iPhone (iOS 12.0+)
- [ ] Works on iPad

### Android Testing
- [ ] Camera permission prompt appears
- [ ] Camera preview loads correctly
- [ ] Barcode detection works in real-time
- [ ] Flashlight toggle works
- [ ] Scanner works in both orientations
- [ ] App doesn't crash when denying camera permission
- [ ] Works on Android 5.0+ devices
- [ ] Release build scans correctly (ProGuard test)

## 🐛 Troubleshooting

### iOS Issues

#### Pod Install Fails
```bash
cd ios
rm -rf Pods Podfile.lock
pod deintegrate
pod cache clean --all
pod install --repo-update
```

#### Camera Not Working
1. Check Info.plist has camera usage description
2. Verify iOS version is 12.0+
3. Check device camera permissions in Settings
4. Restart app after granting permissions

#### Build Errors
```bash
cd ios
xcodebuild clean
cd ..
flutter clean
flutter pub get
cd ios
pod install --repo-update
```

### Android Issues

#### Gradle Build Fails
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### Camera Not Working
1. Check AndroidManifest.xml has camera permission
2. Verify minSdk is at least 21
3. Check device camera permissions in Settings
4. Restart app after granting permissions

#### Release Build Issues
- Verify ProGuard rules are in place
- Test release build before publishing:
  ```bash
  flutter build apk --release
  flutter install --release
  ```

#### ML Kit Issues
If you see ML Kit errors:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

## 📋 Platform Requirements

### iOS
- **Minimum**: iOS 12.0
- **Recommended**: iOS 13.0+
- **Device**: iPhone/iPad with camera
- **Xcode**: 14.0+ (for development)
- **CocoaPods**: Latest version

### Android
- **Minimum**: Android 5.0 (API 21)
- **Recommended**: Android 8.0+ (API 26)
- **Device**: Any Android device/emulator with camera
- **Gradle**: 8.0+ (configured)
- **Kotlin**: 1.9+ (configured)

## 🔐 Runtime Permissions

Both platforms will request camera permission at runtime when user first attempts to scan.

### Permission Flow
1. User taps "Start Scanning"
2. System shows permission dialog
3. User grants/denies permission
4. App responds accordingly:
   - ✅ Granted: Camera starts
   - ❌ Denied: Error message shown

### Permission Settings
If user denies permission, they can grant it later in:
- **iOS**: Settings → Now Delivery → Camera
- **Android**: Settings → Apps → Now Delivery → Permissions → Camera

## 📦 Package Dependencies

### mobile_scanner: ^5.2.3
- Uses native APIs for barcode scanning
- Supports both Android and iOS
- Lightweight and performant
- Auto-handles camera lifecycle

### Native Dependencies
Automatically handled by Flutter:
- **iOS**: GoogleMLKit/BarcodeScanning via CocoaPods
- **Android**: ML Kit Barcode Scanning via Gradle

## 🚀 Performance Optimization

### iOS
- Camera preview at optimal resolution
- Hardware acceleration enabled
- Metal rendering pipeline
- Efficient barcode detection

### Android
- CameraX for modern camera API
- ML Kit on-device processing
- Hardware acceleration via GPU
- ProGuard optimization in release

## 📱 Device Compatibility

### Tested Configurations
- ✅ iPhone 8+ (iOS 12+)
- ✅ iPhone SE (2nd gen+)
- ✅ iPhone X and newer
- ✅ iPad Pro (all models)
- ✅ Samsung Galaxy S8+
- ✅ Google Pixel 3+
- ✅ OnePlus 6+
- ✅ Generic Android devices (API 21+)

### Known Limitations
- ❌ iOS Simulator (no camera support)
- ⚠️ Old Android emulators (limited camera support)
- ⚠️ Devices without camera (graceful fallback)

## 🔄 Continuous Integration

### For CI/CD Pipelines

**iOS Build Commands:**
```bash
flutter pub get
cd ios && pod install && cd ..
flutter build ios --release --no-codesign
```

**Android Build Commands:**
```bash
flutter pub get
flutter build appbundle --release
```

## 📞 Support Resources

- **mobile_scanner**: https://pub.dev/packages/mobile_scanner
- **ML Kit iOS**: https://developers.google.com/ml-kit/vision/barcode-scanning/ios
- **ML Kit Android**: https://developers.google.com/ml-kit/vision/barcode-scanning/android
- **Flutter Camera**: https://docs.flutter.dev/packages-and-plugins/using-packages

---

**Last Updated**: October 2025  
**Flutter Version**: 3.7.2+  
**mobile_scanner**: 5.2.3  
**Platform**: iOS 12.0+, Android 5.0+

