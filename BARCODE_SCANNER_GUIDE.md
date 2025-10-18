# Barcode Scanner Implementation Guide

## Overview

The barcode scanner functionality has been updated to use **real camera scanning** instead of simulation. The scanner now uses the `mobile_scanner` package (v5.2.3) which provides native barcode/QR code scanning capabilities for both Android and iOS.

## Features

- ✅ **Real-time barcode scanning** using device camera
- ✅ **Auto-detection** - automatically scans when barcode is in view
- ✅ **Flashlight toggle** - turn on/off torch for low-light conditions
- ✅ **Multiple barcode format support** - QR codes, barcodes (EAN, UPC, Code128, etc.)
- ✅ **Visual feedback** - scanning frame with corner indicators
- ✅ **Haptic feedback** - vibration when barcode is detected
- ✅ **Auto-close** - dialog closes automatically after successful scan
- ✅ **Error handling** - gracefully handles camera permission issues

## How It Works

### User Flow

1. User taps "Scan Barcode" button in the pickup details screen
2. Scanner dialog opens with initial "Ready to Scan" view
3. User taps "Start Scanning" button
4. Camera initializes and shows live preview
5. User positions barcode within the scanning frame
6. Scanner automatically detects and reads the barcode
7. Success feedback is shown with the scanned code
8. Dialog auto-closes after 2 seconds and returns the code

### Technical Implementation

The scanner is implemented in `lib/features/business/pickups/widgets/order_scanner_dialog.dart`:

```dart
// Scanner initialization
_scannerController = MobileScannerController(
  detectionSpeed: DetectionSpeed.normal,
  facing: CameraFacing.back,
  torchEnabled: false,
);

// Barcode detection
MobileScanner(
  controller: _scannerController!,
  onDetect: (capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && _scannedCode == null) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) {
        _handleScannedCode(barcode.rawValue!);
      }
    }
  },
)
```

## Permissions

### Android

Camera permission is already configured in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
```

### iOS

Camera usage description is configured in `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Now Delivery needs access to your camera to scan barcodes, take profile pictures and capture delivery documentation photos.</string>
```

## Supported Barcode Formats

The `mobile_scanner` package supports all standard barcode formats:

- **1D Barcodes**: EAN-8, EAN-13, UPC-A, UPC-E, Code-39, Code-93, Code-128, ITF, Codabar
- **2D Barcodes**: QR Code, Data Matrix, PDF-417, Aztec

## Usage in Code

```dart
// Show the scanner dialog
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => OrderScannerDialog(
    onOrderScanned: (scannedCode) {
      // Handle the scanned code
      print('Scanned: $scannedCode');
    },
  ),
);
```

## UI Components

### Scanning Frame
- 200x200px scanning area with blue borders
- Four corner indicators for visual guidance
- Animated scanning line that moves vertically
- Changes to green when barcode is detected

### Action Buttons
- **Start Scanning**: Initializes camera and begins scanning
- **Stop**: Stops scanning and returns to initial view
- **Scanning...**: Shows active scanning status
- **Flashlight Toggle**: Icon button to control device torch

### Feedback
- **Visual**: Color changes (blue → green) when code detected
- **Haptic**: Medium impact vibration on successful scan
- **Audio**: System beep (if device supports it)
- **Message**: Shows scanned code value in green success box

## Error Handling

The scanner handles various error scenarios:

1. **Camera Permission Denied**
   - Shows error message
   - Automatically closes dialog
   - User can grant permission and try again

2. **Camera Not Available**
   - Shows error message with details
   - Gracefully closes dialog

3. **No Barcode Detected**
   - Continues scanning
   - User can manually stop and retry

## Testing

### On Android Device/Emulator
```bash
flutter run -d <device-id>
```

### On iOS Device/Simulator
```bash
flutter run -d <device-id>
```

**Note**: iOS Simulator doesn't support camera, so you must test on a real device.

## Troubleshooting

### Camera not starting
1. Check that camera permission is granted in device settings
2. Ensure no other app is using the camera
3. Restart the app
4. Check console for error messages

### Barcode not detected
1. Ensure good lighting conditions
2. Hold device steady and at appropriate distance
3. Make sure barcode is within the scanning frame
4. Try using the flashlight toggle for better visibility
5. Check that barcode format is supported

### Performance issues
1. Close other camera-intensive apps
2. Reduce detection speed if needed
3. Ensure device has sufficient memory

## Dependencies

```yaml
dependencies:
  mobile_scanner: ^5.2.3
```

Install with:
```bash
flutter pub get
```

## Platform Requirements

- **Android**: Minimum SDK 21 (Android 5.0)
- **iOS**: Minimum iOS 11.0
- **Camera**: Required hardware feature

## Future Enhancements

Possible improvements for future versions:

1. **Manual input fallback** - Allow typing barcode if camera fails
2. **Scan history** - Keep track of recently scanned codes
3. **Batch scanning** - Scan multiple barcodes at once
4. **Custom barcode formats** - Filter specific formats only
5. **Beep sound** - Audible confirmation on scan
6. **Gallery import** - Scan barcodes from saved images
7. **Auto-focus control** - Manual focus adjustment

## Related Files

- `lib/features/business/pickups/widgets/order_scanner_dialog.dart` - Scanner dialog widget
- `lib/features/business/pickups/screens/pickup_details_screen.dart` - Usage example
- `android/app/src/main/AndroidManifest.xml` - Android permissions
- `ios/Runner/Info.plist` - iOS permissions
- `pubspec.yaml` - Package dependencies

## Support

For issues related to:
- **mobile_scanner package**: https://pub.dev/packages/mobile_scanner
- **Camera permissions**: Check device settings
- **App functionality**: Contact development team

---

**Last Updated**: October 2025
**Package Version**: mobile_scanner ^5.2.3
**Flutter Version**: 3.7.2+

