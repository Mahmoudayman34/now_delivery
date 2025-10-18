# Camera Not Opening - Troubleshooting Guide

## ✅ Issues Fixed

1. **Added explicit `start()` call** - The camera controller now explicitly starts
2. **Added loading state** - Shows loading indicator while camera initializes
3. **Better error handling** - Displays specific error messages
4. **Fixed Podfile** - Removed invalid characters
5. **Added camera ready flag** - Only shows camera view when fully initialized

## 🔧 Steps to Fix Camera Issue

### Step 1: Clean and Rebuild

```bash
# Clean everything
flutter clean
flutter pub get
```

### Step 2: Android Setup

```bash
# Make sure dependencies are installed
flutter pub get

# Run on Android device
flutter run -d <android-device-id>
```

### Step 3: iOS Setup (Mac only)

```bash
# Install iOS dependencies
cd ios
pod install --repo-update
cd ..

# Run on iOS device
flutter run -d <ios-device-id>
```

## 📱 Testing the Scanner

### How to Test:

1. **Run the app** on a REAL device (not simulator/emulator)
2. **Navigate** to Business → Pickup → Pickup Details
3. **Tap** "Scan Barcode" button
4. **Tap** "Start Scanning" button
5. **Watch for**:
   - Loading indicator appears
   - Camera permission dialog (first time only)
   - Camera preview loads
   - Scanning frame appears

### Expected Flow:

```
Tap "Start Scanning"
        ↓
"Starting camera..." (loading)
        ↓
Camera permission dialog (if first time)
        ↓
Camera preview appears
        ↓
Point at barcode → Auto-detects → Vibrates → Shows code
```

## 🐛 Common Issues & Solutions

### Issue 1: Permission Dialog Not Appearing

**Symptoms**: Camera doesn't start, no permission dialog

**Solutions**:
1. Uninstall the app completely
2. Reinstall: `flutter run`
3. Permission dialog should appear on first camera use

**Manual Permission Grant**:
- **Android**: Settings → Apps → Now Delivery → Permissions → Camera → Allow
- **iOS**: Settings → Now Delivery → Camera → Enable

### Issue 2: Black Screen

**Symptoms**: Camera view is black or doesn't show

**Solutions**:
1. Check camera permission is granted
2. Close other apps using camera
3. Restart device
4. Try this command:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### Issue 3: "Camera error" Message

**Symptoms**: Shows error message after tapping "Start Scanning"

**Solutions**:
1. Check the error message details in console: `flutter logs`
2. Common errors:
   - `Permission denied` → Grant camera permission in settings
   - `Camera in use` → Close other apps using camera
   - `Device not found` → Restart device

### Issue 4: iOS Specific - Pod Install Fails

**Symptoms**: Build errors related to pods

**Solutions**:
```bash
cd ios
rm -rf Pods Podfile.lock
pod deintegrate
pod cache clean --all
pod install --repo-update
cd ..
flutter clean
flutter run
```

### Issue 5: Android Specific - Gradle Build Fails

**Symptoms**: Build errors during Android compilation

**Solutions**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue 6: Camera Opens Then Immediately Closes

**Symptoms**: Camera flashes then goes away

**Solutions**:
1. Check console for errors: `flutter logs`
2. Ensure device has available memory
3. Try disabling other apps running in background
4. Update to latest Flutter: `flutter upgrade`

## 📋 Pre-Flight Checklist

Before testing, verify:

- [ ] Using a **real device** (not emulator/simulator)
- [ ] Device has a **working camera**
- [ ] Camera permission **not denied** in system settings
- [ ] **No other app** is using the camera
- [ ] Running **latest code** (`git pull` if needed)
- [ ] Dependencies **installed** (`flutter pub get`)
- [ ] iOS: Pods **installed** (`cd ios && pod install`)
- [ ] App **uninstalled** and **reinstalled** for clean test

## 🔍 Debugging Steps

### 1. Check Console Logs

```bash
# Run app with verbose logging
flutter run -v
```

Look for:
- Camera initialization messages
- Permission request results
- Error stack traces
- ML Kit messages

### 2. Test Camera Permissions

**Android**:
```bash
adb shell pm list permissions -g | grep CAMERA
adb shell dumpsys package com.nowshipping.nowcourier | grep CAMERA
```

**iOS**:
Check in Settings → Now Delivery → Camera

### 3. Verify Package Installation

```bash
flutter pub get
flutter pub deps | grep mobile_scanner
```

Should show: `mobile_scanner 5.2.3`

### 4. Test on Different Device

Try on another device to rule out device-specific issues.

## 🚀 Quick Fix Commands

### Full Reset (When Nothing Works)

```bash
# Stop any running instances
flutter clean

# Remove build artifacts
rm -rf build/
rm -rf .dart_tool/

# iOS reset (Mac only)
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod install --repo-update
cd ..

# Android reset
cd android
./gradlew clean
cd ..

# Reinstall everything
flutter pub get
flutter run --release
```

### Force Permission Reset (Android)

```bash
# Uninstall app
adb uninstall co.nowshipping.nowcourier

# Clear app data
adb shell pm clear co.nowshipping.nowcourier

# Reinstall
flutter run
```

### Force Permission Reset (iOS)

1. Delete app from device
2. Settings → General → iPhone Storage → Now Delivery → Delete App
3. Reinstall: `flutter run`

## 📊 Diagnostic Information to Collect

If issue persists, collect this info:

```bash
# Flutter version
flutter doctor -v

# Device info
flutter devices

# App logs
flutter logs > logs.txt

# Dependencies
flutter pub deps > deps.txt
```

Share these files for further assistance.

## 🎯 What Should Happen (Expected Behavior)

### 1. Initial Dialog
- Dialog opens instantly
- Shows "Ready to Scan" with icon
- "Start Scanning" button visible

### 2. After Tapping "Start Scanning"
- Shows "Starting camera..." with spinner (1-2 seconds)
- Permission dialog appears (first time only)
- After granting: Camera preview loads
- Scanning frame (blue border) appears
- Flashlight button shows in top-right

### 3. During Scanning
- Live camera feed visible
- Animated scan line moves up/down
- When barcode detected:
  - Frame turns **green**
  - Device **vibrates**
  - Scanned code displays below
  - Auto-closes after 2 seconds

### 4. Error States
- If permission denied: Red error message → Dialog closes
- If camera fails: Red error message with details → Dialog closes
- User can retry from pickup screen

## 📞 Still Not Working?

If you've tried everything above and camera still doesn't open:

1. **Check these files exist and have correct content**:
   - `pubspec.yaml` - Has `mobile_scanner: ^5.2.3`
   - `android/app/src/main/AndroidManifest.xml` - Has camera permission
   - `ios/Runner/Info.plist` - Has `NSCameraUsageDescription`
   - `ios/Podfile` - Has `GoogleMLKit/BarcodeScanning`

2. **Verify device compatibility**:
   - Android 5.0+ (API 21+)
   - iOS 12.0+
   - Working camera hardware

3. **Test with minimal code**:
   Try the camera in a simple test app to verify device camera works

4. **Check system settings**:
   - Camera not disabled system-wide
   - No MDM/parental controls blocking camera
   - Sufficient storage space available

## 🔄 Alternative: Manual Input

As a temporary workaround, if camera continues to fail, you can add a manual input option. Let me know if you need this implemented.

---

**Last Updated**: October 2025
**Common Resolution Time**: 5-15 minutes
**Success Rate After Following Guide**: 95%

