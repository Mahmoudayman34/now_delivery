# Courier Tracking System - Complete Documentation

## Table of Contents
1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [Flutter App File Structure](#flutter-app-file-structure)
4. [Implementation Details](#implementation-details)
5. [Admin Panel Features](#admin-panel-features)
6. [Backend APIs](#backend-apis)
7. [Socket.IO Real-time Communication](#socketio-real-time-communication)
8. [Data Models](#data-models)
9. [Authentication](#authentication)
10. [Flutter Mobile App Implementation Guide](#flutter-mobile-app-implementation-guide)
11. [Code Flow & Execution](#code-flow--execution)
12. [Testing & Troubleshooting](#testing--troubleshooting)

---

## Overview

The Courier Tracking System is a real-time location tracking solution that allows:
- **Couriers** to send their location updates from mobile devices
- **Admins** to view all courier locations on an interactive map in real-time
- **Real-time updates** via WebSocket (Socket.IO) connections
- **Location history** and status tracking
- **Disconnected courier detection** (stale location data)

### Key Technologies
- **Backend**: Node.js, Express.js, MongoDB
- **Real-time**: Socket.IO
- **Frontend**: EJS templates, Google Maps API
- **Mobile**: Flutter (Fully Implemented)
- **Database**: MongoDB with Geospatial Indexing

### Production Server
- **Base URL**: `https://nowshipping.co`
- **API Base**: `https://nowshipping.co/api/v1/courier`
- **Socket.IO**: `https://nowshipping.co`

### Quick Reference

#### Key Implementation Values
- **Update Interval**: 25 seconds (foreground timer)
- **Distance Filter**: 10 meters (minimum movement)
- **Background Updates**: Every 5 minutes
- **Location Accuracy**: High (GPS)
- **Update Strategy**: Dual (Socket.IO + REST API)

#### Main Components
- **LocationTrackingManager**: Core tracking logic
- **LocationService**: GPS and permissions
- **SocketService**: Real-time WebSocket communication
- **ApiService**: REST API calls
- **LocationProvider**: State management (Provider pattern)
- **BackgroundLocationService**: Background updates (WorkManager)

---

## System Architecture

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│   Flutter App   │─────────▶│   REST API       │─────────▶│    MongoDB      │
│   (Courier)     │  HTTP    │   (Express)      │          │   (Database)    │
└─────────────────┘         └──────────────────┘          └─────────────────┘
       │                              │                            │
       │                              │                            │
       │ Socket.IO                    │ Socket.IO                  │
       │                              │                            │
       ▼                              ▼                            ▼
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│  Socket.IO      │◀────────│  Socket.IO       │         │   Admin Panel   │
│  Client         │         │  Server          │────────▶│   (Web)         │
└─────────────────┘         └──────────────────┘          └─────────────────┘
```

### Data Flow

1. **Location Update Flow**:
   - Courier app sends location via REST API (`POST /api/v1/courier/location`)
   - Server updates MongoDB
   - Server broadcasts update via Socket.IO to admin panel
   - Admin panel receives update and updates map markers

2. **Real-time Update Flow**:
   - Courier app sends location via Socket.IO (`location_update` event)
   - Server processes and broadcasts to admin room
   - Admin panel receives `courier-location-update` event
   - Map markers update in real-time

---

## Flutter App File Structure

### Project Structure
```
lib/
├── main.dart                          # App entry point, initialization
├── providers/
│   └── location_provider.dart         # State management (Provider pattern)
├── screens/
│   ├── home_screen.dart               # Main tracking screen UI
│   └── login_screen.dart              # Authentication screen
└── services/
    ├── api_config.dart                # API endpoints configuration
    ├── api_service.dart                # REST API service layer
    ├── auth_service.dart               # Authentication service
    ├── location_service.dart           # Location permissions & GPS
    ├── location_tracking_manager.dart   # Core tracking logic
    ├── socket_service.dart             # Socket.IO client service
    └── background_location_service.dart # Background location updates
```

### Key Files Explained

#### 1. `lib/main.dart`
- Initializes background location service
- Sets up Provider for state management
- Handles authentication routing
- Entry point of the application

#### 2. `lib/services/api_config.dart`
- Centralized API configuration
- Base URL: `https://nowshipping.co`
- All endpoint definitions

#### 3. `lib/services/location_tracking_manager.dart`
- Core tracking logic
- Manages location stream subscriptions
- Handles dual updates (REST + Socket.IO)
- Update interval: **25 seconds** (configurable)
- Distance filter: **10 meters**

#### 4. `lib/services/socket_service.dart`
- Socket.IO client initialization
- Connection management with auto-reconnect
- Location update emission
- Status update emission

#### 5. `lib/providers/location_provider.dart`
- State management using Provider pattern
- Exposes tracking state to UI
- Handles user interactions
- Integrates background service

---

## Implementation Details

### Location Update Strategy

The app uses a **dual-update strategy** for reliability:

1. **Primary**: Socket.IO (real-time, low latency)
2. **Backup**: REST API (reliable, persistent)

Both methods are used simultaneously to ensure location updates are never lost.

### Update Frequency

- **Foreground**: 
  - Stream-based: Updates when device moves **10+ meters**
  - Timer-based: Updates every **25 seconds** (backup)
  
- **Background**: 
  - WorkManager: Updates every **5 minutes**
  - Requires background location permission

### Location Accuracy Settings

```dart
LocationSettings(
  accuracy: LocationAccuracy.high,      // High accuracy GPS
  distanceFilter: 10,                    // 10 meters minimum movement
  timeLimit: Duration(seconds: 30),      // 30 second timeout
)
```

### Authentication Flow

1. User logs in via `AuthService.login()`
2. JWT token stored in `SharedPreferences`
3. Token used for all API requests
4. Token passed to Socket.IO connection
5. Token validated on backend

### State Management Flow

```
User Action (UI)
    ↓
LocationProvider (State Management)
    ↓
LocationTrackingManager (Business Logic)
    ↓
├── LocationService (GPS)
├── ApiService (REST API)
└── SocketService (WebSocket)
```

### Background Tracking Implementation

1. **WorkManager** initialized in `main()`
2. Periodic task registered when tracking starts
3. Task runs independently of app state
4. Uses stored token from SharedPreferences
5. Sends location via REST API (Socket.IO not available in background)

### Error Handling

- **Network errors**: Caught and logged, retry on next update
- **Permission errors**: User-friendly messages, settings redirect
- **Socket errors**: Auto-reconnect with exponential backoff
- **API errors**: Error messages displayed to user

---

## Admin Panel Features

### File: `views/admin/courier-tracking.ejs`

### Features Overview

#### 1. **Interactive Google Maps**
- Real-time courier location markers
- Custom vehicle icons (motorcycle, car, van/truck)
- Info windows with courier details
- Fullscreen mode support
- "Show All" button to fit all markers in view

#### 2. **Courier List Sidebar**
- List of all active couriers with location tracking enabled
- Visual status indicators:
  - 🟢 Green: Available
  - 🔴 Red: Unavailable
  - 🟡 Yellow: Disconnected (stale location > 5 minutes)
- Courier details:
  - Name and Courier ID
  - Vehicle type
  - Last update time
  - Connection status

#### 3. **Courier Details Panel**
- Selected courier information:
  - Profile photo
  - Contact information (phone, email)
  - Vehicle type
  - Current location coordinates
  - Last updated timestamp
  - Status badge
- "Get Directions" button (opens Google Maps)

#### 4. **Real-time Updates**
- Automatic marker position updates
- Status change notifications
- Disconnected courier detection
- Overlay showing active/disconnected counts

#### 5. **Map Controls**
- Fullscreen toggle
- Fit all markers button
- Refresh courier list
- Map overlay with statistics

### Key JavaScript Functions

```javascript
// Main functions in courier-tracking.ejs
- initMap()                    // Initialize Google Maps
- fetchCouriers()              // Fetch all courier locations
- updateMarkers()              // Update map markers
- selectCourier()              // Select and display courier details
- setupSocketIO()              // Initialize Socket.IO connection
- fitAllMarkers()              // Fit all markers in view
- isLocationStale()            // Check if location is > 5 minutes old
- getVehicleIcon()             // Get appropriate icon for vehicle type
```

---

## Backend APIs

### Base URL
```
Production: https://nowshipping.co
Development: http://localhost:6098
```

**Note**: The Flutter app is configured to use `https://nowshipping.co` by default. Update `lib/services/api_config.dart` to change the server URL.

### API Endpoints

#### 1. Update Courier Location

**Endpoint**: `POST /api/v1/courier/location`

**Authentication**: Required (Bearer Token)

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body**:
```json
{
  "latitude": 30.0444,
  "longitude": 31.2357
}
```

**Response** (Success - 200):
```json
{
  "success": true,
  "message": "Location updated successfully"
}
```

**Response** (Error - 400):
```json
{
  "success": false,
  "message": "Latitude and longitude are required"
}
```

**Response** (Error - 403):
```json
{
  "success": false,
  "message": "Location tracking is not enabled for this courier"
}
```

**Response** (Error - 404):
```json
{
  "success": false,
  "message": "Courier not found"
}
```

**Implementation Notes**:
- Coordinates are stored in GeoJSON format: `[longitude, latitude]`
- Location tracking must be enabled (`isLocationTrackingEnabled: true`)
- Updates `lastUpdated` timestamp automatically

---

#### 2. Update Location Tracking Preferences

**Endpoint**: `POST /api/v1/courier/location/preferences`

**Authentication**: Required (Bearer Token)

**Request Body**:
```json
{
  "isEnabled": true
}
```

**Response** (Success - 200):
```json
{
  "success": true,
  "message": "Location tracking enabled successfully"
}
```

**Use Cases**:
- Enable/disable location tracking
- Privacy controls for couriers
- Battery optimization

---

#### 3. Get Location Status

**Endpoint**: `GET /api/v1/courier/location/status`

**Authentication**: Required (Bearer Token)

**Response** (Success - 200):
```json
{
  "success": true,
  "isLocationTrackingEnabled": true,
  "currentLocation": {
    "type": "Point",
    "coordinates": [31.2357, 30.0444],
    "lastUpdated": "2024-01-15T10:30:00.000Z"
  }
}
```

**Use Cases**:
- Check if tracking is enabled
- Get current location
- Verify last update time

---

#### 4. Get All Courier Locations (Admin)

**Endpoint**: `GET /admin/courier-locations`

**Authentication**: Required (Admin Cookie/Token)

**Response** (Success - 200):
```json
{
  "success": true,
  "couriers": [
    {
      "_id": "courier_id_123",
      "name": "Ahmed Mohamed",
      "courierID": "COU001",
      "vehicleType": "Motorcycle",
      "isAvailable": true,
      "isLocationTrackingEnabled": true,
      "personalPhoto": "photo.jpg",
      "photoUrl": "/uploads/couriers/photo.jpg",
      "currentLocation": {
        "type": "Point",
        "coordinates": [31.2357, 30.0444],
        "lastUpdated": "2024-01-15T10:30:00.000Z"
      }
    }
  ]
}
```

**Filters**:
- Only returns couriers with `isLocationTrackingEnabled: true`
- Excludes couriers with invalid coordinates (0, 0)

---

#### 5. Get Specific Courier Location (Admin)

**Endpoint**: `GET /admin/courier-location/:id`

**Authentication**: Required (Admin Cookie/Token)

**Response** (Success - 200):
```json
{
  "success": true,
  "courier": {
    "_id": "courier_id_123",
    "name": "Ahmed Mohamed",
    "courierID": "COU001",
    "vehicleType": "Motorcycle",
    "isAvailable": true,
    "phoneNumber": "+201234567890",
    "email": "ahmed@example.com",
    "isLocationTrackingEnabled": true,
    "personalPhoto": "photo.jpg",
    "photoUrl": "/uploads/couriers/photo.jpg",
    "currentLocation": {
      "type": "Point",
      "coordinates": [31.2357, 30.0444],
      "lastUpdated": "2024-01-15T10:30:00.000Z"
    }
  }
}
```

---

## Socket.IO Real-time Communication

### Connection Setup

#### For Mobile App (Courier)

```javascript
// Connect with authentication token
const socket = io('https://your-domain.com', {
  transports: ['websocket', 'polling'],
  reconnection: true,
  reconnectionAttempts: 5,
  reconnectionDelay: 1000,
  auth: {
    token: 'YOUR_JWT_TOKEN'
  }
});
```

#### For Admin Panel

```javascript
// Connect with admin panel flag
const socket = io(window.location.origin, {
  transports: ['websocket', 'polling'],
  reconnection: true,
  reconnectionAttempts: 5,
  reconnectionDelay: 1000,
  auth: {
    adminPanel: true
  }
});
```

### Socket Events

#### 1. Send Location Update (Courier → Server)

**Event**: `location_update`

**Emitted By**: Courier mobile app

**Data**:
```json
{
  "latitude": 30.0444,
  "longitude": 31.2357
}
```

**Server Response**:
- Updates database
- Broadcasts `courier-location-update` to admin room

**Example**:
```javascript
socket.emit('location_update', {
  latitude: 30.0444,
  longitude: 31.2357
});
```

---

#### 2. Receive Location Update (Server → Admin)

**Event**: `courier-location-update`

**Received By**: Admin panel

**Data**:
```json
{
  "courierId": "courier_id_123",
  "location": {
    "latitude": 30.0444,
    "longitude": 31.2357,
    "timestamp": "2024-01-15T10:30:00.000Z"
  },
  "isAvailable": true,
  "name": "Ahmed Mohamed",
  "courierID": "COU001",
  "vehicleType": "Motorcycle",
  "phoneNumber": "+201234567890",
  "email": "ahmed@example.com",
  "photoUrl": "/uploads/couriers/photo.jpg"
}
```

**Example**:
```javascript
socket.on('courier-location-update', function(data) {
  console.log('Location update:', data);
  // Update map marker
  updateMarker(data.courierId, data.location);
});
```

---

#### 3. Send Status Update (Courier → Server)

**Event**: `status_update`

**Emitted By**: Courier mobile app

**Data**:
```json
{
  "isAvailable": true
}
```

**Example**:
```javascript
socket.emit('status_update', {
  isAvailable: true
});
```

---

#### 4. Receive Status Update (Server → Admin)

**Event**: `courier-status-update`

**Received By**: Admin panel

**Data**:
```json
{
  "courierId": "courier_id_123",
  "isAvailable": true,
  "name": "Ahmed Mohamed",
  "courierID": "COU001",
  "vehicleType": "Motorcycle",
  "phoneNumber": "+201234567890",
  "email": "ahmed@example.com",
  "currentLocation": {
    "type": "Point",
    "coordinates": [31.2357, 30.0444],
    "lastUpdated": "2024-01-15T10:30:00.000Z"
  }
}
```

---

#### 5. Connection Events

**Event**: `connect`

**Description**: Fired when socket connects successfully

```javascript
socket.on('connect', function() {
  console.log('Connected to server');
});
```

**Event**: `connect_error`

**Description**: Fired when connection fails

```javascript
socket.on('connect_error', function(error) {
  console.error('Connection error:', error);
});
```

**Event**: `disconnect`

**Description**: Fired when socket disconnects

```javascript
socket.on('disconnect', function(reason) {
  console.log('Disconnected:', reason);
});
```

---

## Data Models

### Courier Model

```javascript
{
  _id: ObjectId,
  courierID: String,              // Unique courier identifier
  name: String,                    // Courier name
  vehicleType: String,              // "Motorcycle", "Car", "Van", "Truck"
  isAvailable: Boolean,            // Availability status
  isLocationTrackingEnabled: Boolean, // Location tracking toggle
  currentLocation: {
    type: String,                  // "Point"
    coordinates: [Number, Number], // [longitude, latitude]
    lastUpdated: Date              // Last location update timestamp
  },
  personalPhoto: String,           // Photo filename
  phoneNumber: String,
  email: String,
  deviceToken: String,              // For push notifications
  fcmToken: String,                // Firebase Cloud Messaging token
  createdAt: Date,
  updatedAt: Date
}
```

### Location Data Format

**GeoJSON Format**:
```json
{
  "type": "Point",
  "coordinates": [longitude, latitude]
}
```

**Important**: MongoDB uses `[longitude, latitude]` order, not `[latitude, longitude]`!

### Geospatial Index

The courier model includes a 2dsphere index for efficient location queries:
```javascript
courierSchema.index({ currentLocation: '2dsphere' });
```

---

## Authentication

### JWT Token Structure

```json
{
  "id": "courier_id_123",
  "userType": "courier",
  "iat": 1234567890,
  "exp": 1234654290
}
```

### Authentication Flow

#### 1. Login (Get Token)

**Endpoint**: `POST /api/v1/auth/courier-login`

**Request**:
```json
{
  "email": "courier@example.com",
  "password": "password123"
}
```

**Response** (Success - 200):
```json
{
  "status": "success",
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "courier_id_123",
    "name": "Ahmed Mohamed",
    "email": "courier@example.com",
    "role": "courier"
  }
}
```

**Response** (Error - 400):
```json
{
  "status": "error",
  "message": "Email or password is incorrect"
}
```

**Token Details**:
- Token expires in **365 days**
- Token contains: `{ id: courier._id, userType: 'courier' }`
- Token is also set as HTTP-only cookie (for web)
- For mobile apps, use the `token` field from response

#### 2. Using Token in API Requests

**REST API**:
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Socket.IO**:
```javascript
const socket = io('https://your-domain.com', {
  auth: {
    token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
  }
});
```

### Token Validation

- Tokens expire after a set time (check your JWT configuration)
- Invalid/expired tokens return `401 Unauthorized`
- Refresh token mechanism may be implemented (check your auth system)

---

## Flutter Mobile App Implementation Guide

### Step 1: Project Setup

#### 1.1 Create Flutter Project

```bash
flutter create courier_tracking_app
cd courier_tracking_app
```

#### 1.2 Add Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HTTP requests
  http: ^1.1.0
  dio: ^5.4.0
  
  # Socket.IO
  socket_io_client: ^2.0.3+1
  
  # Location services
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  
  # State management
  provider: ^6.1.1
  # OR
  # riverpod: ^2.4.9
  
  # Local storage
  shared_preferences: ^2.2.2
  
  # Permissions
  permission_handler: ^11.1.0
  
  # Background tasks
  workmanager: ^0.5.2
  
  # Maps
  google_maps_flutter: ^2.5.0
  
  # UI
  flutter_map: ^6.1.0
  
  # Utils
  intl: ^0.18.1
  uuid: ^4.2.1
```

Run:
```bash
flutter pub get
```

---

### Step 2: Configuration Files

#### 2.1 Android Permissions

**File**: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Location permissions -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
    
    <!-- Internet permission -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <!-- Foreground service for background location -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    
    <application
        android:label="Courier Tracking"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Google Maps API Key -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="AIzaSyCyIdhgj9Rn2S30XfyYv9SCflp7-qJD6As"/>
            
        <activity>
            ...
        </activity>
    </application>
</manifest>
```

#### 2.2 iOS Permissions

**File**: `ios/Runner/Info.plist`

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to track deliveries</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to track deliveries even when the app is in the background</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to track deliveries in the background</string>
```

---

### Step 3: API Service Layer

#### 3.1 Create API Configuration

**File**: `lib/services/api_config.dart`

**Current Implementation**:

```dart
class ApiConfig {
  // Production server URL
  static const String baseUrl = 'https://nowshipping.co';
  static const String apiBaseUrl = '$baseUrl/api/v1/courier';
  
  // Endpoints
  static const String updateLocation = '$apiBaseUrl/location';
  static const String locationPreferences = '$apiBaseUrl/location/preferences';
  static const String locationStatus = '$apiBaseUrl/location/status';
  
  // Socket.IO URL
  static String get socketUrl => baseUrl;
}
```

**Configuration**: Update `baseUrl` in this file to point to your server.

#### 3.2 Create Auth Service

**File**: `lib/services/auth_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class AuthService {
  // Login courier
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/courier-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['status'] == 'success') {
        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('courier_id', data['user']['id']);
        await prefs.setString('courier_name', data['user']['name']);
        await prefs.setString('courier_email', data['user']['email']);
        
        return {
          'success': true,
          'token': data['token'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
  
  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('courier_id');
    await prefs.remove('courier_name');
    await prefs.remove('courier_email');
  }
  
  // Check if logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }
  
  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
```

#### 3.3 Create API Service

**File**: `lib/services/api_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ApiService {
  // Get stored token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  // Get headers with authentication
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  // Update location
  Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.updateLocation),
        headers: headers,
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update location',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // Update location tracking preferences
  Future<Map<String, dynamic>> updateLocationPreferences({
    required bool isEnabled,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.locationPreferences),
        headers: headers,
        body: jsonEncode({
          'isEnabled': isEnabled,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update preferences',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // Get location status
  Future<Map<String, dynamic>> getLocationStatus() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.locationStatus),
        headers: headers,
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'isLocationTrackingEnabled': data['isLocationTrackingEnabled'],
          'currentLocation': data['currentLocation'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get status',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
```

---

### Step 4: Location Service

#### 4.1 Create Location Service

**File**: `lib/services/location_service.dart`

```dart
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Check and request location permissions
  Future<bool> requestLocationPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled
      return false;
    }
    
    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever
      return false;
    }
    
    return true;
  }
  
  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }
  
  // Listen to location updates
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
        timeLimit: Duration(seconds: 30),
      ),
    );
  }
  
  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}
```

---

### Step 5: Socket.IO Service

#### 5.1 Create Socket Service

**File**: `lib/services/socket_service.dart`

```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class SocketService {
  IO.Socket? _socket;
  
  // Initialize socket connection
  Future<void> initializeSocket() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        print('No token found, cannot connect to socket');
        return;
      }
      
      _socket = IO.io(
        ApiConfig.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .setAuth({'token': token})
            .build(),
      );
      
      // Connection events
      _socket!.onConnect((_) {
        print('Socket connected');
        onConnected?.call();
      });
      
      _socket!.onDisconnect((_) {
        print('Socket disconnected');
        onDisconnected?.call();
      });
      
      _socket!.onConnectError((error) {
        print('Socket connection error: $error');
        onError?.call(error.toString());
      });
      
      _socket!.onError((error) {
        print('Socket error: $error');
        onError?.call(error.toString());
      });
      
    } catch (e) {
      print('Error initializing socket: $e');
    }
  }
  
  // Send location update via socket
  void sendLocationUpdate({
    required double latitude,
    required double longitude,
  }) {
    if (_socket?.connected ?? false) {
      _socket!.emit('location_update', {
        'latitude': latitude,
        'longitude': longitude,
      });
      print('Location update sent via socket: $latitude, $longitude');
    } else {
      print('Socket not connected, cannot send location update');
    }
  }
  
  // Send status update
  void sendStatusUpdate({required bool isAvailable}) {
    if (_socket?.connected ?? false) {
      _socket!.emit('status_update', {
        'isAvailable': isAvailable,
      });
      print('Status update sent: $isAvailable');
    }
  }
  
  // Disconnect socket
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
  
  // Callbacks
  Function()? onConnected;
  Function()? onDisconnected;
  Function(String)? onError;
  
  // Check if socket is connected
  bool get isConnected => _socket?.connected ?? false;
}
```

---

### Step 6: Location Tracking Manager

#### 6.1 Create Location Tracking Manager

**File**: `lib/services/location_tracking_manager.dart`

**Current Implementation** (Key Features):
- Update interval: **25 seconds**
- Distance filter: **10 meters**
- Dual update strategy (Socket.IO + REST API)
- Automatic permission handling
- Status checking from server

```dart
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';
import 'api_service.dart';
import 'socket_service.dart';

class LocationTrackingManager {
  final LocationService _locationService = LocationService();
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();
  
  StreamSubscription<Position>? _locationSubscription;
  Timer? _locationUpdateTimer;
  
  bool _isTracking = false;
  bool _isLocationTrackingEnabled = false;
  
  // Update interval (in seconds)
  static const int updateIntervalSeconds = 25; // Update every 25 seconds
  
  // Initialize tracking
  Future<void> initialize() async {
    // Initialize socket
    await _socketService.initializeSocket();
    
    // Check location status from server
    await checkLocationStatus();
  }
  
  // Check location tracking status from server
  Future<void> checkLocationStatus() async {
    final result = await _apiService.getLocationStatus();
    if (result['success'] == true) {
      _isLocationTrackingEnabled = result['isLocationTrackingEnabled'] ?? false;
    }
  }
  
  // Start location tracking
  Future<void> startTracking() async {
    if (_isTracking) {
      print('Location tracking already started');
      return;
    }
    
    // Check if location tracking is enabled
    if (!_isLocationTrackingEnabled) {
      print('Location tracking is not enabled');
      return;
    }
    
    // Request permissions
    bool hasPermission = await _locationService.requestLocationPermission();
    if (!hasPermission) {
      print('Location permission denied');
      return;
    }
    
    _isTracking = true;
    
    // Listen to location stream
    _locationSubscription = _locationService.getLocationStream().listen(
      (Position position) {
        _updateLocation(position.latitude, position.longitude);
      },
      onError: (error) {
        print('Location stream error: $error');
      },
    );
    
    // Also send periodic updates via REST API as backup
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: updateIntervalSeconds),
      (_) async {
        final position = await _locationService.getCurrentLocation();
        if (position != null) {
          await _updateLocation(position.latitude, position.longitude);
        }
      },
    );
    
    print('Location tracking started');
  }
  
  // Stop location tracking
  void stopTracking() {
    _isTracking = false;
    _locationSubscription?.cancel();
    _locationUpdateTimer?.cancel();
    print('Location tracking stopped');
  }
  
  // Update location (send via both REST API and Socket.IO)
  Future<void> _updateLocation(double latitude, double longitude) async {
    if (!_isLocationTrackingEnabled) {
      return;
    }
    
    print('Updating location: $latitude, $longitude');
    
    // Send via Socket.IO (faster, real-time)
    _socketService.sendLocationUpdate(
      latitude: latitude,
      longitude: longitude,
    );
    
    // Also send via REST API (reliable backup)
    final result = await _apiService.updateLocation(
      latitude: latitude,
      longitude: longitude,
    );
    
    if (result['success'] == true) {
      print('Location updated successfully');
    } else {
      print('Failed to update location: ${result['message']}');
    }
  }
  
  // Enable/disable location tracking
  Future<void> setLocationTrackingEnabled(bool enabled) async {
    final result = await _apiService.updateLocationPreferences(
      isEnabled: enabled,
    );
    
    if (result['success'] == true) {
      _isLocationTrackingEnabled = enabled;
      
      if (enabled) {
        await startTracking();
      } else {
        stopTracking();
      }
    }
  }
  
  // Dispose resources
  void dispose() {
    stopTracking();
    _socketService.disconnect();
  }
  
  // Getters
  bool get isTracking => _isTracking;
  bool get isLocationTrackingEnabled => _isLocationTrackingEnabled;
}
```

---

### Step 7: State Management (Provider)

#### 7.1 Create Location Provider

**File**: `lib/providers/location_provider.dart`

```dart
import 'package:flutter/foundation.dart';
import '../services/location_tracking_manager.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider with ChangeNotifier {
  final LocationTrackingManager _trackingManager = LocationTrackingManager();
  final LocationService _locationService = LocationService();
  
  bool _isTracking = false;
  bool _isLocationTrackingEnabled = false;
  Position? _currentPosition;
  String? _errorMessage;
  
  // Initialize
  Future<void> initialize() async {
    await _trackingManager.initialize();
    await checkLocationStatus();
    notifyListeners();
  }
  
  // Check location status
  Future<void> checkLocationStatus() async {
    await _trackingManager.checkLocationStatus();
    _isLocationTrackingEnabled = _trackingManager.isLocationTrackingEnabled;
    notifyListeners();
  }
  
  // Start tracking
  Future<void> startTracking() async {
    try {
      await _trackingManager.startTracking();
      _isTracking = true;
      _errorMessage = null;
      
      // Get current position
      _currentPosition = await _locationService.getCurrentLocation();
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to start tracking: $e';
      notifyListeners();
    }
  }
  
  // Stop tracking
  void stopTracking() {
    _trackingManager.stopTracking();
    _isTracking = false;
    notifyListeners();
  }
  
  // Toggle location tracking
  Future<void> toggleLocationTracking(bool enabled) async {
    try {
      await _trackingManager.setLocationTrackingEnabled(enabled);
      _isLocationTrackingEnabled = enabled;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update preferences: $e';
      notifyListeners();
    }
  }
  
  // Get current location
  Future<void> getCurrentLocation() async {
    try {
      _currentPosition = await _locationService.getCurrentLocation();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to get location: $e';
      notifyListeners();
    }
  }
  
  // Dispose
  @override
  void dispose() {
    _trackingManager.dispose();
    super.dispose();
  }
  
  // Getters
  bool get isTracking => _isTracking;
  bool get isLocationTrackingEnabled => _isLocationTrackingEnabled;
  Position? get currentPosition => _currentPosition;
  String? get errorMessage => _errorMessage;
}
```

---

### Step 8: UI Implementation

#### 8.1 Main Screen with Location Tracking

**File**: `lib/screens/home_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().initialize();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courier Tracking'),
      ),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Location Tracking Toggle
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location Tracking',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              locationProvider.isLocationTrackingEnabled
                                  ? 'Enabled'
                                  : 'Disabled',
                              style: TextStyle(
                                fontSize: 16,
                                color: locationProvider.isLocationTrackingEnabled
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                            Switch(
                              value: locationProvider.isLocationTrackingEnabled,
                              onChanged: (value) {
                                locationProvider.toggleLocationTracking(value);
                              },
                            ),
                          ],
                        ),
                        if (locationProvider.isTracking)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.green, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Tracking active',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Current Location Info
                if (locationProvider.currentPosition != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Location',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Latitude: ${locationProvider.currentPosition!.latitude.toStringAsFixed(6)}',
                          ),
                          Text(
                            'Longitude: ${locationProvider.currentPosition!.longitude.toStringAsFixed(6)}',
                          ),
                          Text(
                            'Accuracy: ${locationProvider.currentPosition!.accuracy.toStringAsFixed(2)} meters',
                          ),
                        ],
                      ),
                    ),
                  ),
                
                SizedBox(height: 16),
                
                // Error Message
                if (locationProvider.errorMessage != null)
                  Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              locationProvider.errorMessage!,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                Spacer(),
                
                // Action Buttons
                ElevatedButton(
                  onPressed: () {
                    if (locationProvider.isTracking) {
                      locationProvider.stopTracking();
                    } else {
                      locationProvider.startTracking();
                    }
                  },
                  child: Text(
                    locationProvider.isTracking
                        ? 'Stop Tracking'
                        : 'Start Tracking',
                  ),
                ),
                
                SizedBox(height: 8),
                
                ElevatedButton(
                  onPressed: () {
                    locationProvider.getCurrentLocation();
                  },
                  child: Text('Get Current Location'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

---

### Step 9: Background Location Tracking

#### 9.1 Background Task Setup

**File**: `lib/services/background_location_service.dart`

```dart
import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == 'locationUpdate') {
        // Get current location
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        
        // Get stored token
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        final isTrackingEnabled = prefs.getBool('is_location_tracking_enabled') ?? false;
        
        if (token == null || !isTrackingEnabled) {
          return Future.value(false);
        }
        
        // Send location update
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/v1/courier/location'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'latitude': position.latitude,
            'longitude': position.longitude,
          }),
        );
        
        if (response.statusCode == 200) {
          print('Background location update sent: ${position.latitude}, ${position.longitude}');
          return Future.value(true);
        } else {
          return Future.value(false);
        }
      }
      return Future.value(false);
    } catch (e) {
      print('Background task error: $e');
      return Future.value(false);
    }
  });
}

class BackgroundLocationService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }
  
  static Future<void> startPeriodicLocationUpdates() async {
    await Workmanager().registerPeriodicTask(
      'locationUpdate',
      'locationUpdate',
      frequency: Duration(minutes: 5), // Update every 5 minutes
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
  
  static Future<void> stopPeriodicLocationUpdates() async {
    await Workmanager().cancelByUniqueName('locationUpdate');
  }
}
```

#### 9.2 Update main.dart

**File**: `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/location_provider.dart';
import 'services/background_location_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize background location service
  await BackgroundLocationService.initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MaterialApp(
        title: 'Courier Tracking',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
```

---

### Step 10: Complete Integration

#### 10.1 Update Location Provider to Use Background Service

Update `lib/providers/location_provider.dart`:

```dart
// Add import
import '../services/background_location_service.dart';

// In startTracking method, add:
await BackgroundLocationService.startPeriodicLocationUpdates();

// In stopTracking method, add:
await BackgroundLocationService.stopPeriodicLocationUpdates();
```

---

## Code Flow & Execution

### Application Startup Flow

```
1. main() called
   ↓
2. WidgetsFlutterBinding.ensureInitialized()
   ↓
3. BackgroundLocationService.initialize()
   ↓
4. MyApp widget created
   ↓
5. AuthWrapper checks authentication status
   ↓
6. If logged in → HomeScreen
   If not → LoginScreen
```

### Location Tracking Initialization Flow

```
1. HomeScreen.initState()
   ↓
2. LocationProvider.initialize()
   ↓
3. LocationTrackingManager.initialize()
   ├── SocketService.initializeSocket()
   │   ├── Get token from SharedPreferences
   │   ├── Connect to Socket.IO server
   │   └── Set up event handlers
   └── checkLocationStatus()
       └── ApiService.getLocationStatus()
```

### Location Update Flow

```
1. LocationService.getLocationStream() emits Position
   ↓
2. LocationTrackingManager receives Position
   ↓
3. _updateLocation() called
   ├── Send via Socket.IO (real-time)
   │   └── SocketService.sendLocationUpdate()
   └── Send via REST API (backup)
       └── ApiService.updateLocation()
   ↓
4. Backend receives update
   ├── Updates MongoDB
   └── Broadcasts to admin panel via Socket.IO
```

### User Toggle Tracking Flow

```
1. User toggles switch in UI
   ↓
2. LocationProvider.toggleLocationTracking(enabled)
   ↓
3. LocationTrackingManager.setLocationTrackingEnabled(enabled)
   ├── ApiService.updateLocationPreferences()
   └── If enabled:
       └── startTracking()
   If disabled:
       └── stopTracking()
```

### Background Location Update Flow

```
1. WorkManager triggers periodic task
   ↓
2. callbackDispatcher() executed
   ↓
3. Get location from Geolocator
   ↓
4. Get token from SharedPreferences
   ↓
5. Check if tracking enabled
   ↓
6. Send location via REST API
   ↓
7. Backend updates database
```

### Complete Code Execution Example

```dart
// 1. App starts
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundLocationService.initialize();
  runApp(MyApp());
}

// 2. User logs in
final result = await AuthService.login(
  email: 'courier@example.com',
  password: 'password123'
);
// Token saved to SharedPreferences

// 3. HomeScreen loads
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<LocationProvider>().initialize();
  });
}

// 4. Location tracking starts
await locationProvider.startTracking();
// → LocationTrackingManager.startTracking()
// → LocationService.getLocationStream().listen()
// → Updates sent every 10 meters or 25 seconds

// 5. Location updates sent
// Socket.IO: Real-time (low latency)
socket.emit('location_update', {
  'latitude': 30.0444,
  'longitude': 31.2357
});

// REST API: Reliable backup
POST /api/v1/courier/location
{
  "latitude": 30.0444,
  "longitude": 31.2357
}
```

### Key Implementation Constants

```dart
// Location Tracking Manager
static const int updateIntervalSeconds = 25;  // Timer interval

// Location Service
distanceFilter: 10,                           // Meters
timeLimit: Duration(seconds: 30),             // Timeout
accuracy: LocationAccuracy.high,              // GPS accuracy

// Background Service
frequency: Duration(minutes: 5),             // Background updates
```

---

## Testing & Troubleshooting

### Testing Checklist

#### 1. Location Permissions
- [ ] Test on Android device
- [ ] Test on iOS device
- [ ] Test permission denial flow
- [ ] Test permission request flow

#### 2. API Integration
- [ ] Test location update API
- [ ] Test with valid token
- [ ] Test with invalid token
- [ ] Test with expired token
- [ ] Test network error handling

#### 3. Socket.IO
- [ ] Test socket connection
- [ ] Test location update via socket
- [ ] Test reconnection
- [ ] Test disconnection handling

#### 4. Background Tracking
- [ ] Test background location updates
- [ ] Test app in background
- [ ] Test battery optimization

### Common Issues & Solutions

#### Issue 1: Location Permission Denied

**Solution**:
```dart
// Check if permission is permanently denied
if (permission == LocationPermission.deniedForever) {
  // Open app settings
  await openAppSettings();
}
```

#### Issue 2: Socket.IO Connection Failed

**Solution**:
- Verify token is valid
- Check server URL
- Check network connectivity
- Verify CORS settings on server

#### Issue 3: Location Not Updating

**Solution**:
- Check if `isLocationTrackingEnabled` is true
- Verify location permissions
- Check location services are enabled
- Verify API endpoint is correct

#### Issue 4: Background Location Not Working

**Solution**:
- Check background location permission
- Verify WorkManager is initialized
- Check battery optimization settings
- Test on physical device (not emulator)

---

## Best Practices

### 1. Location Update Frequency
- **Foreground**: Update every 10-30 seconds
- **Background**: Update every 2-5 minutes
- Adjust based on battery life requirements

### 2. Error Handling
- Always handle network errors
- Implement retry logic
- Cache location updates if offline
- Show user-friendly error messages

### 3. Battery Optimization
- Use appropriate location accuracy
- Implement distance-based updates
- Stop tracking when not needed
- Use background tasks efficiently

### 4. Security
- Never expose API keys in code
- Use environment variables
- Validate location data
- Implement rate limiting

### 5. User Experience
- Request permissions at appropriate times
- Show clear status indicators
- Provide settings to enable/disable tracking
- Show location accuracy information

---

## API Error Codes Reference

| Status Code | Meaning | Solution |
|------------|--------|----------|
| 200 | Success | - |
| 400 | Bad Request | Check request body format |
| 401 | Unauthorized | Check/refresh token |
| 403 | Forbidden | Location tracking not enabled |
| 404 | Not Found | Courier not found |
| 500 | Server Error | Contact support |

---

## Socket.IO Event Reference

### Events Emitted by Mobile App

| Event | Data | Description |
|-------|------|-------------|
| `location_update` | `{latitude, longitude}` | Send location update |
| `status_update` | `{isAvailable}` | Update availability status |

### Events Received by Mobile App

| Event | Data | Description |
|-------|------|-------------|
| `connect` | - | Socket connected |
| `disconnect` | - | Socket disconnected |
| `connect_error` | `error` | Connection error |

---

## Additional Resources

### Flutter Packages Documentation
- [geolocator](https://pub.dev/packages/geolocator)
- [socket_io_client](https://pub.dev/packages/socket_io_client)
- [workmanager](https://pub.dev/packages/workmanager)
- [permission_handler](https://pub.dev/packages/permission_handler)

### Google Maps API
- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
- [Google Maps API Documentation](https://developers.google.com/maps/documentation)

### Socket.IO Documentation
- [Socket.IO Client Documentation](https://socket.io/docs/v4/client-api/)

---

## Support & Contact

For issues or questions:
1. Check the troubleshooting section
2. Review API documentation
3. Check server logs
4. Contact development team

---

## Version History

- **v1.0.0** (2024-01-15): Initial documentation
  - Complete API documentation
  - Flutter implementation guide
  - Socket.IO integration
  - Background location tracking

- **v1.1.0** (Current): Enhanced Implementation Documentation
  - Added file structure overview
  - Added code flow diagrams
  - Added implementation details
  - Added actual code examples from codebase
  - Added configuration details
  - Added execution flow documentation

---

## License

This documentation is part of the Courier Tracking System.

---

**End of Documentation**

