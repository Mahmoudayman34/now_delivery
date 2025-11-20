# Courier Location Tracking - Implementation Guide

## ✅ Implementation Complete!

The courier location tracking system has been successfully implemented following the documentation in `COURIER_TRACKING_DOCUMENTATION.md`.

---

## 📋 What Was Implemented

### 1. **Dependencies Added** ✅
- `socket_io_client: ^2.0.3+1` - Real-time Socket.IO communication
- `workmanager: ^0.5.2` - Background location updates
- `geocoding: ^2.1.1` - Geocoding support
- `dio: ^5.4.0` - HTTP client (optional, http already available)

### 2. **Core Services Created** ✅

#### Location Tracking Services
- **`tracking_api_config.dart`** - API configuration and constants
  - Base URL: `https://nowshipping.co`
  - Update interval: 25 seconds
  - Distance filter: 10 meters
  - Background updates: Every 5 minutes

- **`socket_service.dart`** - Socket.IO client service
  - Real-time WebSocket connection
  - Auto-reconnection support
  - Location and status updates via Socket.IO
  - Connection state management

- **`location_tracking_api_service.dart`** - REST API service
  - Update location endpoint
  - Location preferences endpoint
  - Location status endpoint
  - Token-based authentication

- **`location_tracking_manager.dart`** - Core tracking logic
  - Coordinates all tracking components
  - Dual-update strategy (Socket.IO + REST API)
  - Automatic status synchronization
  - Location filtering (10m minimum movement)

- **`background_location_service.dart`** - Background updates
  - WorkManager integration
  - Periodic location updates (every 5 minutes)
  - Background task management

### 3. **State Management** ✅

#### Riverpod Providers
- **`location_tracking_provider.dart`** - Main tracking state provider
  - Initialize tracking
  - Start/stop tracking
  - Toggle tracking preferences
  - Status updates
  - Error handling

- **`location_tracking_state.dart`** - State model
  - Tracking status
  - Socket connection status
  - Current position
  - Error messages
  - Loading states

### 4. **UI Implementation** ✅

#### Tracking Screen
- **`tracking_screen.dart`** - Comprehensive tracking UI
  - Real-time status display
  - Current location display
  - Connection status indicators
  - Tracking controls
  - Error messages
  - Tracking information

### 5. **Integration with Existing System** ✅

#### Driver Status Provider
- Updated to integrate with location tracking manager
- Automatic tracking start when going online
- Automatic tracking stop when going offline
- Server-side status synchronization

### 6. **Permissions Configuration** ✅

#### Android (`AndroidManifest.xml`)
- ✅ `ACCESS_FINE_LOCATION`
- ✅ `ACCESS_COARSE_LOCATION`
- ✅ `ACCESS_BACKGROUND_LOCATION`
- ✅ `FOREGROUND_SERVICE`
- ✅ `FOREGROUND_SERVICE_LOCATION`
- ✅ `INTERNET`
- ✅ `ACCESS_NETWORK_STATE`

#### iOS (`Info.plist`)
- ✅ `NSLocationWhenInUseUsageDescription`
- ✅ `NSLocationAlwaysAndWhenInUseUsageDescription`
- ✅ `NSLocationAlwaysUsageDescription`
- ✅ Background mode: `location`

### 7. **App Initialization** ✅

#### main.dart
- ✅ Background location service initialization
- ✅ WorkManager setup
- ✅ Integration with existing Firebase setup

---

## 🚀 How to Use

### 1. **Install Dependencies**

Run the following command to install all new dependencies:

```bash
flutter pub get
```

### 2. **Configure Server URL** (Optional)

If you need to change the server URL, edit:

**File:** `lib/core/services/tracking_api_config.dart`

```dart
class TrackingApiConfig {
  static const String baseUrl = 'https://your-server.com'; // Change this
  // ...
}
```

### 3. **Using the Tracking System**

#### Option A: Automatic Tracking (Already Integrated)

The tracking system is **already integrated** with the driver status provider. When a courier goes online, tracking starts automatically:

```dart
// In your dashboard or home screen
await ref.read(driverStatusProvider.notifier).setOnline(
  true,
  context: context,
);
// This will automatically:
// 1. Start location tracking
// 2. Initialize Socket.IO connection
// 3. Start background location updates
// 4. Send status update to server
```

#### Option B: Dedicated Tracking Screen

You can also use the dedicated tracking screen for more control:

```dart
// Navigate to tracking screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const TrackingScreen(),
  ),
);
```

#### Option C: Manual Control via Provider

```dart
// Access the tracking provider
final trackingNotifier = ref.read(locationTrackingProvider.notifier);

// Initialize
await trackingNotifier.initialize();

// Enable tracking on server
await trackingNotifier.toggleLocationTracking(true, context: context);

// Start tracking
await trackingNotifier.startTracking(context: context);

// Stop tracking
await trackingNotifier.stopTracking();
```

### 4. **Add Tracking Screen to Navigation**

To add the tracking screen to your app's navigation, you can:

#### Add to Main Layout Navigation

**File:** `lib/features/main/widgets/main_layout.dart` or similar

```dart
import '../../../features/business/tracking/screens/tracking_screen.dart';

// Add a navigation item
ListTile(
  leading: const Icon(Icons.location_on),
  title: const Text('Location Tracking'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TrackingScreen(),
      ),
    );
  },
)
```

---

## 📊 System Architecture

### Data Flow

```
┌─────────────────┐
│  Driver Goes    │
│     Online      │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  Driver Status Provider             │
│  - Start Location Service           │
│  - Initialize Tracking Manager      │
│  - Start Background Service         │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  Location Tracking Manager          │
│  - Get location from GPS            │
│  - Filter by distance (10m)         │
│  - Update every 25 seconds          │
└────┬────────────────────────────────┘
     │
     ├──────────────┬─────────────────┐
     ▼              ▼                 ▼
┌──────────┐  ┌──────────┐  ┌────────────────┐
│ Socket.IO│  │ REST API │  │ Background     │
│ (Real-   │  │ (Backup) │  │ (Every 5 min)  │
│  time)   │  │          │  │                │
└────┬─────┘  └────┬─────┘  └────┬───────────┘
     │             │              │
     └──────┬──────┴──────────────┘
            ▼
    ┌───────────────┐
    │    Server     │
    │  (MongoDB)    │
    └───────┬───────┘
            ▼
    ┌───────────────┐
    │  Admin Panel  │
    │ (Real-time    │
    │   Updates)    │
    └───────────────┘
```

---

## 🔧 Configuration

### Update Intervals

**File:** `lib/core/services/tracking_api_config.dart`

```dart
class TrackingApiConfig {
  static const int updateIntervalSeconds = 25;     // Timer backup
  static const int backgroundUpdateMinutes = 5;    // Background updates
  static const int distanceFilterMeters = 10;      // Minimum movement
}
```

### Location Accuracy

**File:** `lib/core/services/location_service.dart` (already configured)

```dart
const LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,  // High accuracy GPS
  distanceFilter: 10,                // Update every 10 meters
);
```

---

## 🧪 Testing

### Test Location Tracking

1. **Start the app** and log in as a courier
2. **Go online** - tracking should start automatically
3. **Check console output** for location updates:
   ```
   ✅ Background location service initialized successfully
   📡 Location tracking manager initialized
   📍 Location tracking enabled: true
   ✅ Location tracking started successfully
   📍 Updating location: 30.0444, 31.2357
   📡 Location update sent via socket
   ✅ Location updated successfully via REST API
   ```

### Test Background Tracking

1. Put app in background
2. Wait 5 minutes
3. Check logs for background updates:
   ```
   🔄 Background location update task started
   ✅ Background location update sent: 30.0444, 31.2357
   ```

### Test Socket.IO Connection

1. Open the tracking screen
2. Check the cloud icon in app bar
3. Green = connected, Grey = disconnected

---

## 🐛 Troubleshooting

### Issue: Location not updating

**Solution:**
1. Check location permissions
2. Verify GPS is enabled
3. Check internet connection
4. Verify `isLocationTrackingEnabled` is true on server

### Issue: Socket.IO not connecting

**Solution:**
1. Check server URL in `tracking_api_config.dart`
2. Verify authentication token is valid
3. Check network connectivity
4. Check server logs

### Issue: Background updates not working

**Solution:**
1. Check background location permission
2. Verify WorkManager is initialized
3. Check battery optimization settings
4. Test on physical device (not emulator)

### Issue: Permission denied

**Solution:**
1. Request permissions at appropriate time
2. Show prominent disclosure for background location
3. Guide user to app settings if permanently denied

---

## 📝 Important Notes

### Battery Optimization

The tracking system is optimized for battery life:
- **Foreground**: Updates only when moving 10+ meters
- **Background**: Updates every 5 minutes
- **Distance filtering**: Reduces unnecessary updates

### Data Usage

The system uses minimal data:
- **Socket.IO**: Very low bandwidth (WebSocket)
- **REST API**: Small JSON payloads
- **Compression**: Enabled on HTTP requests

### Privacy

- Tracking only works when courier is online
- Can be disabled via toggle in tracking screen
- Background location requires prominent disclosure
- Complies with Google Play Store policies

---

## 🔗 API Endpoints

All endpoints are configured in `tracking_api_config.dart`:

- **Base URL**: `https://nowshipping.co`
- **Update Location**: `POST /api/v1/courier/location`
- **Location Preferences**: `POST /api/v1/courier/location/preferences`
- **Location Status**: `GET /api/v1/courier/location/status`
- **Socket.IO**: `wss://nowshipping.co`

---

## 📚 Additional Resources

- **Full Documentation**: See `COURIER_TRACKING_DOCUMENTATION.md`
- **Backend API**: Refer to backend documentation
- **Socket.IO Events**: See documentation section "Socket.IO Real-time Communication"

---

## ✅ Next Steps

1. **Test the implementation** on a physical device
2. **Verify server connection** with the backend team
3. **Test background tracking** thoroughly
4. **Monitor battery usage** and optimize if needed
5. **Add tracking screen to navigation** menu
6. **Test permissions flow** on different Android/iOS versions

---

## 📞 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review `COURIER_TRACKING_DOCUMENTATION.md`
3. Check server logs
4. Contact development team

---

**Implementation completed successfully! 🎉**

The courier tracking system is now fully integrated and ready to use. The system will automatically track courier locations when they go online and send updates to the server in real-time.


