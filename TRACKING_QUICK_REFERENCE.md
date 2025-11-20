# Courier Tracking - Quick Reference

## 📁 File Structure

```
lib/
├── core/
│   └── services/
│       ├── tracking_api_config.dart         ⚙️ Configuration
│       ├── socket_service.dart              🔌 Socket.IO
│       ├── location_tracking_api_service.dart  🌐 REST API
│       ├── location_tracking_manager.dart   🎯 Core Manager
│       ├── background_location_service.dart 📱 Background
│       └── location_service.dart            📍 GPS (existing)
│
└── features/
    └── business/
        ├── tracking/
        │   ├── models/
        │   │   └── location_tracking_state.dart  📦 State Model
        │   ├── providers/
        │   │   └── location_tracking_provider.dart  🔄 Provider
        │   └── screens/
        │       └── tracking_screen.dart      🖥️ UI Screen
        │
        └── dashboard/
            └── providers/
                └── driver_status_provider.dart  🚦 (Updated)
```

---

## 🔑 Key Components

### 1. Configuration
**File:** `tracking_api_config.dart`
```dart
baseUrl: 'https://nowshipping.co'
updateInterval: 25 seconds
distanceFilter: 10 meters
backgroundUpdate: 5 minutes
```

### 2. Socket.IO Service
**File:** `socket_service.dart`
- Real-time connection
- Auto-reconnect
- Location updates
- Status updates

### 3. Location Tracking Manager
**File:** `location_tracking_manager.dart`
- Coordinates all services
- Dual-update strategy
- Location filtering
- Status management

### 4. Background Service
**File:** `background_location_service.dart`
- WorkManager integration
- 5-minute intervals
- Independent of app state

### 5. Provider (State Management)
**File:** `location_tracking_provider.dart`
- Riverpod state notifier
- UI state management
- Error handling

### 6. Tracking Screen
**File:** `tracking_screen.dart`
- Status display
- Location display
- Controls
- Error messages

---

## 🚀 Quick Start

### Auto-Tracking (Already Integrated)

```dart
// When courier goes online, tracking starts automatically
await ref.read(driverStatusProvider.notifier).setOnline(true, context: context);
```

### Manual Control

```dart
// Initialize
final tracking = ref.read(locationTrackingProvider.notifier);
await tracking.initialize();

// Start
await tracking.startTracking(context: context);

// Stop
await tracking.stopTracking();
```

### Navigate to Tracking Screen

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const TrackingScreen()),
);
```

---

## 📡 Data Flow

```
User Goes Online
    ↓
Driver Status Provider
    ↓
Location Tracking Manager
    ↓
    ├─→ GPS Location Service
    ├─→ Socket.IO (Real-time)
    └─→ REST API (Backup)
    ↓
Server (MongoDB)
    ↓
Admin Panel (Live Updates)
```

---

## 🔧 Common Tasks

### Change Server URL
**File:** `lib/core/services/tracking_api_config.dart`
```dart
static const String baseUrl = 'https://your-server.com';
```

### Adjust Update Frequency
**File:** `lib/core/services/tracking_api_config.dart`
```dart
static const int updateIntervalSeconds = 30; // Change from 25
```

### Adjust Distance Filter
**File:** `lib/core/services/tracking_api_config.dart`
```dart
static const int distanceFilterMeters = 20; // Change from 10
```

---

## 🎯 Key Features

✅ **Real-time tracking** via Socket.IO  
✅ **Reliable backup** via REST API  
✅ **Background updates** every 5 minutes  
✅ **Distance filtering** (10m minimum)  
✅ **Battery optimized**  
✅ **Auto-reconnect**  
✅ **Status synchronization**  
✅ **Comprehensive UI**  

---

## 🧪 Testing Checklist

- [ ] Install dependencies (`flutter pub get`)
- [ ] Test login
- [ ] Go online (tracking starts)
- [ ] Check console for location updates
- [ ] Test Socket.IO connection
- [ ] Put app in background (5 min test)
- [ ] Check admin panel for updates
- [ ] Test going offline
- [ ] Test tracking screen UI

---

## 📱 Permissions

### Android
✅ Fine Location  
✅ Coarse Location  
✅ Background Location  
✅ Foreground Service  
✅ Internet  

### iOS
✅ When In Use  
✅ Always (Background)  
✅ Background Mode: Location  

---

## 🐛 Quick Fixes

| Problem | Solution |
|---------|----------|
| No updates | Check permissions & GPS |
| Socket disconnected | Check internet & server URL |
| Background not working | Check battery optimization |
| Permission denied | Show disclosure & guide to settings |

---

## 📚 Documentation

- **Full Guide**: `TRACKING_IMPLEMENTATION_GUIDE.md`
- **Original Docs**: `COURIER_TRACKING_DOCUMENTATION.md`
- **API Docs**: Backend documentation

---

## 💡 Pro Tips

1. **Test on real device** - Background tracking needs physical device
2. **Check battery settings** - Disable optimization for testing
3. **Monitor console** - All tracking events are logged
4. **Use tracking screen** - Best for debugging
5. **Server logs** - Check backend for received updates

---

## 🔗 Important Files

| File | Purpose |
|------|---------|
| `tracking_api_config.dart` | All configuration |
| `location_tracking_manager.dart` | Main logic |
| `socket_service.dart` | Real-time connection |
| `driver_status_provider.dart` | Integration point |
| `tracking_screen.dart` | UI for debugging |

---

**Ready to track! 🚀**


