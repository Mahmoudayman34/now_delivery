# iOS Testing Guide - Camera Fix Verification

## Purpose
This guide helps verify that the camera crash fix works correctly before resubmitting to Apple App Store.

## Prerequisites
- Mac with Xcode installed
- iOS device (iPhone or iPad) with iOS 14.0+
- Flutter SDK installed
- Physical device connected (camera testing requires real device)

## Setup Instructions

### 1. Clean and Rebuild
```bash
# Navigate to project directory
cd "d:/flutter projects/now_delivery"

# Clean previous builds
flutter clean
rm -rf ios/Pods ios/Podfile.lock

# Get dependencies
flutter pub get

# Install iOS pods (if on Mac)
cd ios
pod install
cd ..
```

### 2. Build for Testing
```bash
# Build for iOS (release mode recommended)
flutter build ios --release

# Or run directly on connected device
flutter run --release
```

## Test Cases

### Test 1: Fresh Install - Camera Permission
**Objective:** Verify app doesn't crash on first camera access

**Steps:**
1. Delete app from device completely
2. Install fresh build from Xcode or Flutter
3. Launch app and log in
4. Navigate to: Profile → Edit Profile
5. Tap on profile picture area
6. Select "Camera" option
7. **Expected:** Permission dialog appears with message: "Now Delivery needs access to your camera to take profile pictures..."
8. Tap "Allow"
9. **Expected:** Camera opens successfully (no crash)
10. Take a photo
11. **Expected:** Photo is captured and displayed as profile picture

**Result:** ✅ PASS / ❌ FAIL

---

### Test 2: Fresh Install - Photo Library Permission
**Objective:** Verify photo library access works

**Steps:**
1. Delete app (if continuing from Test 1)
2. Install fresh build
3. Launch app and log in
4. Navigate to: Profile → Edit Profile
5. Tap on profile picture area
6. Select "Gallery" option
7. **Expected:** Permission dialog appears with message: "Now Delivery needs access to your photo library..."
8. Tap "Allow" or "Select Photos..."
9. **Expected:** Photo picker opens successfully (no crash)
10. Select a photo
11. **Expected:** Photo is displayed as profile picture

**Result:** ✅ PASS / ❌ FAIL

---

### Test 3: Permission Denied - Camera
**Objective:** Verify graceful handling when permission denied

**Steps:**
1. Go to iOS Settings → Now Delivery → Camera
2. Set to "Don't Allow" (or deny during permission prompt)
3. Open app → Profile → Edit Profile
4. Tap profile picture → Select "Camera"
5. **Expected:** Orange SnackBar message appears: "Camera access was denied or cancelled..."
6. **Expected:** SnackBar has "Settings" button
7. Tap "Settings" button
8. **Expected:** Opens iOS Settings for Now Delivery app
9. Grant camera permission
10. Return to app and retry camera access
11. **Expected:** Camera opens successfully

**Result:** ✅ PASS / ❌ FAIL

---

### Test 4: Permission Denied - Photo Library
**Objective:** Verify graceful handling for photo library denial

**Steps:**
1. Go to iOS Settings → Now Delivery → Photos
2. Set to "None"
3. Open app → Profile → Edit Profile
4. Tap profile picture → Select "Gallery"
5. **Expected:** Orange SnackBar message appears: "Photo library access was denied or cancelled..."
6. **Expected:** SnackBar has "Settings" button
7. Tap "Settings" button
8. **Expected:** Opens iOS Settings for Now Delivery app
9. Set Photos to "All Photos" or "Selected Photos"
10. Return to app and retry gallery access
11. **Expected:** Photo picker opens successfully

**Result:** ✅ PASS / ❌ FAIL

---

### Test 5: iPad Specific Test (CRITICAL - Apple's crash scenario)
**Objective:** Verify iPad camera works (Apple's crash occurred on iPad Air 5th gen)

**Device Required:** iPad Air (5th gen) or similar iPad

**Steps:**
1. Delete app from iPad
2. Install fresh build
3. Launch app and complete onboarding/login
4. Navigate to Profile → Edit Profile
5. Tap profile picture
6. Select "Camera"
7. **Expected:** Permission prompt appears
8. Tap "Allow"
9. **Expected:** Camera opens WITHOUT CRASH
10. Take photo (both portrait and landscape orientation)
11. **Expected:** Photo captures and saves successfully

**Result:** ✅ PASS / ❌ FAIL

---

### Test 6: Limited Photo Access (iOS 14+)
**Objective:** Verify "Limited Photos" permission works

**Steps:**
1. Go to iOS Settings → Now Delivery → Photos
2. Select "Selected Photos..."
3. Choose only 2-3 photos
4. Open app → Profile → Edit Profile
5. Tap profile picture → Select "Gallery"
6. **Expected:** Only selected photos are visible
7. Select one of the visible photos
8. **Expected:** Photo is set as profile picture successfully

**Result:** ✅ PASS / ❌ FAIL

---

### Test 7: Cancel Image Picker
**Objective:** Verify app handles cancellation gracefully

**Steps:**
1. Open app → Profile → Edit Profile
2. Tap profile picture → Select "Camera"
3. When camera opens, tap "Cancel" (X button)
4. **Expected:** Returns to edit profile screen without crash
5. Tap profile picture → Select "Gallery"
6. When photo picker opens, tap "Cancel"
7. **Expected:** Returns to edit profile screen without crash

**Result:** ✅ PASS / ❌ FAIL

---

### Test 8: Stress Test - Multiple Attempts
**Objective:** Verify stability with repeated use

**Steps:**
1. Open app → Profile → Edit Profile
2. Tap profile picture → Select "Camera"
3. Take photo → Save
4. Immediately tap profile picture again → Select "Gallery"
5. Choose photo → Save
6. Repeat steps 2-5 five times
7. **Expected:** No crashes, no memory issues, smooth operation

**Result:** ✅ PASS / ❌ FAIL

---

## Console Log Verification

### Expected Debug Messages (check Xcode console)
When testing, you should see these debug messages:

**Success:**
```
flutter: User cancelled image picking
flutter: Camera permission denied
flutter: Photo library permission denied
```

**No Error Messages:**
- Should NOT see: "Error picking image"
- Should NOT see: Stack traces related to camera
- Should NOT see: Permission-related crashes

### Crash Log Analysis
If any crashes occur:
1. Open Xcode → Window → Devices and Simulators
2. Select your device → View Device Logs
3. Find crash log for "Now Delivery" / "Runner"
4. Look for stack trace mentioning camera/photo library
5. Check if Info.plist keys are properly loaded

## Success Criteria

All tests must PASS for successful fix verification:

- ✅ Test 1: Camera permission works
- ✅ Test 2: Photo library permission works
- ✅ Test 3: Camera denial handled gracefully
- ✅ Test 4: Photo library denial handled gracefully
- ✅ Test 5: iPad camera works (CRITICAL)
- ✅ Test 6: Limited photos works
- ✅ Test 7: Cancellation handled
- ✅ Test 8: Stress test passes

## Failure Troubleshooting

### If camera still crashes:

1. **Verify Info.plist:**
   ```bash
   # Check if keys are present
   grep -A 1 "NSCameraUsageDescription" ios/Runner/Info.plist
   grep -A 1 "NSPhotoLibraryUsageDescription" ios/Runner/Info.plist
   ```

2. **Check permissions in Xcode:**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select Runner → Info tab
   - Verify "Privacy - Camera Usage Description" exists
   - Verify "Privacy - Photo Library Usage Description" exists

3. **Clean build:**
   ```bash
   flutter clean
   rm -rf ios/Pods ios/Podfile.lock build
   flutter pub get
   cd ios && pod install && cd ..
   flutter build ios
   ```

4. **Check device settings:**
   - Settings → Privacy & Security → Camera
   - Verify "Now Delivery" appears in list
   - Settings → Privacy & Security → Photos
   - Verify "Now Delivery" appears in list

### If permission prompt doesn't appear:

1. Reset permissions:
   - Settings → General → Transfer or Reset iPhone
   - Reset Location & Privacy
   - Reinstall app

2. Check Xcode console for permission errors

3. Verify Info.plist is included in build

## Testing Devices Recommended

### Minimum Test Devices:
1. **iPhone** (any model, iOS 14+)
2. **iPad Air** (5th gen or similar) - REQUIRED for Apple's crash scenario
3. **iPad** (any other model for broader compatibility)

### iOS Versions to Test:
- iOS 14.0+ (minimum supported)
- iOS 15.x
- iOS 16.x
- iOS 17.x
- Latest iOS version

## Reporting Results

After completing all tests, document results:

```
Test Date: [DATE]
Tester: [NAME]
Device(s): [MODEL - iOS VERSION]

Test 1: ✅/❌
Test 2: ✅/❌
Test 3: ✅/❌
Test 4: ✅/❌
Test 5: ✅/❌ (iPad Air)
Test 6: ✅/❌
Test 7: ✅/❌
Test 8: ✅/❌

Overall: PASS/FAIL

Notes:
[Any additional observations]
```

## Automated Testing (Optional)

For integration testing:

```dart
// test/integration_test/camera_test.dart
testWidgets('Camera permission and access test', (tester) async {
  // Test camera permission flow
  // Note: Requires integration_test package
});
```

## Final Checklist Before App Store Submission

- [ ] All 8 manual tests passed
- [ ] Tested on iPad Air (Apple's crash device)
- [ ] Tested on multiple iOS versions
- [ ] No crashes in Xcode console
- [ ] Info.plist keys verified in build
- [ ] Version number incremented (1.0.5+6)
- [ ] Build created: `flutter build ios --release`
- [ ] Archive created in Xcode
- [ ] APPLE_REVIEW_RESPONSE.md prepared
- [ ] Screenshots/videos of working camera ready for Apple

---

## Contact for Issues

If tests fail or unexpected behavior occurs:
- Review: CAMERA_FIX_DOCUMENTATION.md
- Check: lib/core/services/image_service.dart implementation
- Verify: ios/Runner/Info.plist permissions

---

*Complete this testing before resubmitting to Apple App Store*
*All tests should PASS to ensure crash fix is successful*

