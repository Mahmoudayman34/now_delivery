# Quick Test Guide for Barcode Scanner

## 🚀 Quick Start Testing

### Prerequisites
- Physical device (iOS or Android) with working camera
- Flutter development environment set up
- Device connected via USB or WiFi debugging

### Test in 5 Minutes

#### Step 1: Install Dependencies
```bash
flutter pub get
```

#### Step 2: For iOS (Mac only)
```bash
cd ios
pod install --repo-update
cd ..
```

#### Step 3: Run on Device
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

#### Step 4: Navigate to Scanner
1. Login to the app
2. Go to Business section
3. Select a pickup
4. Tap **"Scan Barcode"** button
5. Tap **"Start Scanning"**
6. Point camera at any barcode/QR code

## 📱 Test with Sample Barcodes

### Option 1: Print Test Barcodes
Print these barcode types to test:
- EAN-13 (product barcodes)
- QR codes
- UPC codes
- Code 128

### Option 2: Use Online Barcodes
Open these URLs on another device and scan them:
- https://barcode.tec-it.com/en/QRCode
- https://www.the-qrcode-generator.com/
- https://www.free-barcode-generator.net/

### Option 3: Test Products
Scan any product with a barcode:
- Food packaging
- Book covers
- Retail products
- Shipping labels

## ✅ What to Test

### Basic Functionality
- [ ] Camera permission dialog appears
- [ ] Camera preview shows correctly
- [ ] Scanner detects barcode automatically
- [ ] Haptic feedback occurs on scan
- [ ] Scanned code displays correctly
- [ ] Dialog auto-closes after scan

### Features
- [ ] Flashlight toggle works
- [ ] Stop button stops scanning
- [ ] Visual feedback (green border) on detection
- [ ] Works in portrait orientation
- [ ] Works in landscape orientation

### Edge Cases
- [ ] Denying camera permission shows error
- [ ] Scanner works in low light with flashlight
- [ ] Multiple barcodes in view (scans first one)
- [ ] Closing dialog stops camera
- [ ] App doesn't crash on error

## 🐛 Common Issues & Solutions

### Issue: Camera Permission Not Requested
**Solution**: 
- Uninstall app
- Reinstall: `flutter run`
- Permission dialog should appear on first camera use

### Issue: Camera Shows Black Screen
**Solution**:
- Check camera permissions in device settings
- Restart the app
- Try: `flutter clean && flutter run`

### Issue: Barcode Not Detected
**Solution**:
- Ensure good lighting
- Hold device steady
- Try different distance from barcode
- Use flashlight toggle
- Try a different barcode

### Issue: iOS Pods Error
**Solution**:
```bash
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod install --repo-update
cd ..
flutter clean
flutter run
```

### Issue: Android Build Fails
**Solution**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

## 📊 Expected Behavior

### On Success
1. Camera opens with live preview
2. Scanning frame visible with blue borders
3. When barcode is in frame:
   - Border turns **green**
   - Device **vibrates**
   - Scanned code appears below
4. After 2 seconds: Dialog closes automatically
5. Order is added to pickup list

### On Error
1. If permission denied:
   - Error message shows
   - Dialog closes
   - Can retry from settings
2. If camera unavailable:
   - Error message with details
   - Dialog closes gracefully

## 🎯 Performance Checks

### Response Time
- Permission dialog: < 1 second
- Camera start: 1-2 seconds
- Barcode detection: < 0.5 seconds
- Dialog close: Instant

### Resource Usage
- Camera should not overheat device
- App should not lag during scanning
- Memory usage should stay stable

## 📝 Test Report Template

```
Test Date: ___________
Device: ___________
OS Version: ___________
Flutter Version: ___________

✅ Camera Permission: PASS / FAIL
✅ Camera Preview: PASS / FAIL
✅ Barcode Detection: PASS / FAIL
✅ Flashlight Toggle: PASS / FAIL
✅ Auto-close: PASS / FAIL
✅ Error Handling: PASS / FAIL

Notes:
_________________________________
_________________________________
```

## 🔄 Reset Testing Environment

If you need to start fresh:

```bash
# Complete clean
flutter clean
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

# Reinstall
flutter pub get
flutter run
```

## 📸 Screenshot Test Cases

Take screenshots for documentation:
1. Scanner dialog initial state
2. Camera preview with scanning frame
3. Successful scan with green border
4. Scanned barcode displayed
5. Error state (permission denied)

## 🚦 Status Indicators

### Green (Working)
- Camera opens immediately
- Barcodes detected quickly
- No errors in console
- Smooth performance

### Yellow (Needs Attention)
- Slow camera start (>3 seconds)
- Detection delays (>2 seconds)
- Occasional errors in console
- Minor UI glitches

### Red (Not Working)
- Camera doesn't open
- No barcode detection
- Crashes or freezes
- Permission issues

## 📞 Getting Help

If tests fail:
1. Check console logs: `flutter logs`
2. Review PLATFORM_SETUP_GUIDE.md
3. Check BARCODE_SCANNER_GUIDE.md
4. Verify all dependencies installed
5. Test on different device if available

---

**Quick Test Duration**: 5-10 minutes  
**Full Test Duration**: 20-30 minutes  
**Platforms**: iOS 12.0+, Android 5.0+

