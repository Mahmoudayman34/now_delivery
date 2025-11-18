# Now Shipping Notification System - Complete Implementation Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architecture & Components](#architecture--components)
3. [Implementation Details](#implementation-details)
4. [Code Structure](#code-structure)
5. [API Endpoints](#api-endpoints)
6. [Configuration Files](#configuration-files)
7. [Flow Diagrams](#flow-diagrams)
8. [UI Components](#ui-components)
9. [Testing Guide](#testing-guide)
10. [Troubleshooting](#troubleshooting)
11. [Integration Guide](#integration-guide)

---

## Overview

The **Now Shipping Notification System** is a complete Firebase Cloud Messaging (FCM) implementation integrated into a Flutter application. It provides real-time push notifications, notification history management, and seamless multi-device login support.

### Key Features
- ✅ **Firebase Cloud Messaging (FCM)**: Real-time push notifications
- ✅ **Notification History**: View all notifications with read/unread status
- ✅ **Multi-Device Support**: FCM token automatically updates on login
- ✅ **Foreground Notifications**: Local notifications displayed when app is active
- ✅ **Background Notifications**: Handles notifications when app is in background
- ✅ **Permission Management**: Smart notification permission requests
- ✅ **Cross-Platform**: Fully functional on Android and iOS
- ✅ **Badge Support**: Unread notification count displayed in UI
- ✅ **Mark as Read**: Individual and bulk mark-as-read functionality

### Technology Stack
- **Framework**: Flutter 3.0+
- **Backend API**: Node.js (https://nowshipping.co/api/v1)
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **Local Notifications**: flutter_local_notifications
- **State Management**: Riverpod
- **Local Storage**: SharedPreferences
- **Time Formatting**: timeago

### Dependencies
```yaml
firebase_core: ^3.8.1
firebase_messaging: ^15.1.5
flutter_local_notifications: ^18.0.1
timeago: ^3.7.0
permission_handler: ^11.3.1
shared_preferences: ^2.2.2
flutter_riverpod: ^3.0.1
http: ^1.1.2
```

---

## Architecture & Components

### System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Application                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────┐         ┌──────────────────┐        │
│  │   Main.dart      │────────▶│ Firebase Init    │        │
│  │  (Entry Point)   │         │                  │        │
│  └──────────────────┘         └──────────────────┘        │
│         │                              │                    │
│         │                              ▼                    │
│         │                    ┌──────────────────┐           │
│         │                    │ FirebaseMessaging│           │
│         │                    │    Service       │           │
│         │                    │  (Singleton)     │           │
│         │                    └──────────────────┘           │
│         │                              │                    │
│         │                              │                    │
│         ▼                              ▼                    │
│  ┌──────────────────┐         ┌──────────────────┐        │
│  │  Auth Service    │────────▶│  Token Update    │        │
│  │  (Login Flow)    │         │  on Login        │        │
│  └──────────────────┘         └──────────────────┘        │
│         │                              │                    │
│         │                              ▼                    │
│         │                    ┌──────────────────┐           │
│         │                    │   API Service    │           │
│         │                    │  (Backend Sync)  │           │
│         │                    └──────────────────┘           │
│         │                              │                    │
│         │                              ▼                    │
│         │                    ┌──────────────────┐           │
│         │                    │  Notification    │           │
│         │                    │    Service       │           │
│         │                    └──────────────────┘           │
│         │                              │                    │
│         ▼                              ▼                    │
│  ┌──────────────────┐         ┌──────────────────┐        │
│  │ Notifications    │         │  Notifications   │        │
│  │   Screen         │◀────────│    Screen        │        │
│  │  (UI Layer)      │         │   (UI Layer)     │        │
│  └──────────────────┘         └──────────────────┘        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
         │                              │
         │                              │
         ▼                              ▼
┌──────────────────┐         ┌──────────────────┐
│  Firebase Cloud  │         │   Backend API    │
│    Messaging     │         │  (Node.js)       │
└──────────────────┘         └──────────────────┘
```

### Component Breakdown

#### 1. FirebaseMessagingService (Singleton)
**Location**: `lib/core/services/firebase_messaging_service.dart`

**Purpose**: Central hub for all FCM operations

**Key Responsibilities**:
- Initialize Firebase Messaging
- Request notification permissions
- Generate and manage FCM tokens
- Handle foreground/background messages
- Display local notifications
- Sync tokens with backend

**Key Methods**:
```dart
Future<void> initialize()                    // Initialize FCM service
Future<String?> getAndSaveToken()            // Get FCM token and save
Future<void> updateTokenOnLogin(String authToken)  // Update token on login
Future<void> _requestPermission()           // Request notification permissions
Future<void> _initializeLocalNotifications() // Setup local notifications
void _setupForegroundMessageHandlers()       // Handle foreground messages
void _setupBackgroundMessageHandlers()      // Handle background messages
Future<void> _showLocalNotification(RemoteMessage message)  // Show local notification
Future<void> _sendTokenToServer(String token, {String? authToken})  // Sync token
```

#### 2. NotificationService
**Location**: `lib/features/business/notifications/services/notification_service.dart`

**Purpose**: Handle notification data operations

**Key Responsibilities**:
- Fetch notifications from backend
- Mark notifications as read
- Get unread count
- Delete notifications

**Key Methods**:
```dart
Future<List<NotificationModel>> getNotifications()  // Fetch all notifications
Future<int> getUnreadCount()                        // Get unread count
Future<void> markAsRead(String notificationId)      // Mark single as read
Future<void> markAllAsRead()                        // Mark all as read
Future<void> deleteNotification(String notificationId)  // Delete notification
```

#### 3. NotificationModel
**Location**: `lib/features/business/notifications/models/notification_model.dart`

**Purpose**: Data model for notifications

**Properties**:
```dart
final String id;              // Notification ID
final String title;           // Notification title
final String body;            // Notification body/message
final String? type;           // Notification type (order, delivery, etc.)
final Map<String, dynamic>? data;  // Additional data
final bool isRead;            // Read status
final DateTime createdAt;     // Creation timestamp
```

#### 4. NotificationPermissionHelper
**Location**: `lib/core/services/notification_permission_helper.dart`

**Purpose**: Manage notification permissions across platforms

**Key Methods**:
```dart
static Future<void> checkPermissions(BuildContext context)  // Check permissions
static Future<PermissionStatus> requestPermission()         // Request permission
static Future<void> showPermissionDialog(BuildContext context)  // Show dialog
static Future<void> openAppSettings()                       // Open settings
```

#### 5. NotificationsScreen
**Location**: `lib/features/business/notifications/screens/notifications_screen.dart`

**Purpose**: UI for displaying notification list

**Features**:
- Pull-to-refresh
- Read/unread visual distinction
- Mark as read functionality
- Empty state handling
- Error state handling
- Time ago formatting

---

## Implementation Details

### 1. Firebase Initialization

**Location**: `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing Firebase: $e');
  }
  
  // Initialize Firebase Messaging
  if (firebaseInitialized) {
    try {
      final firebaseMessagingService = FirebaseMessagingService();
      await firebaseMessagingService.initialize();
      debugPrint('✅ Firebase Messaging initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Firebase Messaging: $e');
    }
  }
  
  runApp(MyApp());
}
```

### 2. FirebaseMessagingService Initialization Flow

```dart
Future<void> initialize() async {
  // 1. Check if already initialized
  if (_isInitialized) return;
  
  // 2. Verify Firebase Core is initialized
  try {
    Firebase.app();
  } catch (e) {
    debugPrint('❌ Firebase Core is not initialized');
    return;
  }
  
  // 3. Request notification permissions
  await _requestPermission();
  
  // 4. Initialize local notifications
  await _initializeLocalNotifications();
  
  // 5. Get and save FCM token
  await getAndSaveToken();
  
  // 6. Setup message handlers
  _setupForegroundMessageHandlers();
  _setupBackgroundMessageHandlers();
  
  // 7. Listen for token refresh
  _firebaseMessaging.onTokenRefresh.listen((newToken) {
    _fcmToken = newToken;
    _saveTokenToPreferences(newToken);
    _sendTokenToServer(newToken);
  });
  
  _isInitialized = true;
}
```

### 3. Permission Request

**Android (API 33+)**:
- Requires `POST_NOTIFICATIONS` permission
- Handled by `permission_handler` package

**iOS**:
- Uses native iOS permission dialog
- Handled by Firebase Messaging SDK

```dart
Future<void> _requestPermission() async {
  NotificationSettings settings = await _firebaseMessaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
  );
  
  debugPrint('📱 Notification permission status: ${settings.authorizationStatus}');
}
```

### 4. Local Notifications Setup

```dart
Future<void> _initializeLocalNotifications() async {
  // Android settings
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  
  // iOS settings
  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  
  const InitializationSettings settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  
  await _localNotifications.initialize(
    settings,
    onDidReceiveNotificationResponse: _onNotificationTapped,
  );
  
  // Create Android notification channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );
  
  await _localNotifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}
```

### 5. Foreground Message Handling

When app is in foreground, FCM messages are received but not automatically displayed. We show local notifications:

```dart
void _setupForegroundMessageHandlers() {
  // Listen for messages when app is in foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('📱 Received foreground message: ${message.messageId}');
    
    if (message.notification != null) {
      _showLocalNotification(message);
    }
  });
  
  // Listen for notification taps that opened the app
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('🔔 Notification opened app: ${message.messageId}');
    // TODO: Navigate to appropriate screen
  });
}
```

### 6. Background Message Handling

Background messages require a top-level function:

```dart
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📱 Handling background message: ${message.messageId}');
  debugPrint('📱 Message data: ${message.data}');
  debugPrint('📱 Message notification: ${message.notification?.title}');
}
```

Registered in `_setupBackgroundMessageHandlers()`:
```dart
void _setupBackgroundMessageHandlers() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}
```

### 7. FCM Token Management

#### Getting Token
```dart
Future<String?> getAndSaveToken() async {
  String? token = await _firebaseMessaging.getToken();
  
  if (token != null) {
    _fcmToken = token;
    await _saveTokenToPreferences(token);
    await _sendTokenToServer(token);
    return token;
  }
  return null;
}
```

#### Updating Token on Login
```dart
Future<void> updateTokenOnLogin(String authToken) async {
  // Delete old token
  await _firebaseMessaging.deleteToken();
  
  // Get new token
  String? newToken = await _firebaseMessaging.getToken();
  
  if (newToken != null) {
    _fcmToken = newToken;
    await _saveTokenToPreferences(newToken);
    await _sendTokenToServer(newToken, authToken: authToken);
  }
}
```

#### Token Refresh Listener
```dart
_firebaseMessaging.onTokenRefresh.listen((newToken) {
  debugPrint('🔄 FCM Token refreshed: $newToken');
  _fcmToken = newToken;
  _saveTokenToPreferences(newToken);
  _sendTokenToServer(newToken);
});
```

### 8. Token Sync with Backend

```dart
Future<void> _sendTokenToServer(String token, {String? authToken}) async {
  final prefs = await SharedPreferences.getInstance();
  final savedAuthToken = authToken ?? prefs.getString('auth_token');
  
  if (savedAuthToken == null) {
    debugPrint('⚠️  No auth token available, skipping token sync');
    return;
  }
  
  final response = await http.post(
    Uri.parse('${ApiConstants.baseUrl}/business/update-fcm-token'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $savedAuthToken',
    },
    body: json.encode({'fcmToken': token}),
  );
  
  if (response.statusCode == 200) {
    debugPrint('✅ FCM token sent to server successfully');
  } else {
    debugPrint('❌ Failed to send FCM token to server: ${response.statusCode}');
  }
}
```

### 9. Login Integration

**Location**: `lib/features/auth/services/auth_service.dart`

```dart
Future<UserModel?> login({required String email, required String password}) async {
  // ... login logic ...
  
  if (response.statusCode == 200) {
    // Save token and user data
    final token = jsonData['token'] as String;
    await _saveAuthData(token, userData);
    
    // Update FCM token on login for multi-device support
    try {
      final firebaseMessaging = FirebaseMessagingService();
      if (firebaseMessaging.isInitialized) {
        await firebaseMessaging.updateTokenOnLogin(token);
      } else {
        await firebaseMessaging.initialize();
        if (firebaseMessaging.isInitialized) {
          await firebaseMessaging.updateTokenOnLogin(token);
        }
      }
    } catch (e) {
      print('⚠️  Failed to update FCM token on login: $e');
      // Continue with login even if FCM update fails
    }
    
    return userModel;
  }
}
```

---

## Code Structure

### File Organization

```
lib/
├── main.dart                                    # App entry point, Firebase init
├── firebase_options.dart                        # Auto-generated Firebase config
│
├── core/
│   ├── constants/
│   │   └── api_constants.dart                   # API base URL and endpoints
│   ├── services/
│   │   ├── firebase_messaging_service.dart      # FCM service (singleton)
│   │   └── notification_permission_helper.dart  # Permission management
│   └── exceptions/
│       └── api_exception.dart                   # API error handling
│
├── data/
│   └── services/
│       └── api_service.dart                     # HTTP client wrapper
│
└── features/
    └── business/
        ├── auth/
        │   └── services/
        │       └── auth_service.dart            # Login with FCM token update
        │
        └── notifications/
            ├── models/
            │   └── notification_model.dart      # Notification data model
            ├── services/
            │   └── notification_service.dart     # Notification CRUD operations
            └── screens/
                └── notifications_screen.dart   # Notification list UI
│
android/
├── app/
│   ├── build.gradle                             # Google Services plugin
│   ├── google-services.json                     # Firebase Android config
│   └── src/main/
│       └── AndroidManifest.xml                  # Permissions and FCM metadata
│
ios/
├── Runner/
│   ├── Info.plist                               # iOS permissions and background modes
│   ├── GoogleService-Info.plist                # Firebase iOS config
│   └── AppDelegate.swift                        # iOS app delegate with FCM setup
└── Podfile                                       # iOS dependencies
```

### Key Classes and Their Responsibilities

| Class | Location | Responsibility |
|-------|----------|----------------|
| `FirebaseMessagingService` | `lib/core/services/firebase_messaging_service.dart` | FCM initialization, token management, message handling |
| `NotificationService` | `lib/features/business/notifications/services/notification_service.dart` | Notification data operations |
| `NotificationModel` | `lib/features/business/notifications/models/notification_model.dart` | Notification data structure |
| `NotificationPermissionHelper` | `lib/core/services/notification_permission_helper.dart` | Permission management UI |
| `NotificationsScreen` | `lib/features/business/notifications/screens/notifications_screen.dart` | Notification list UI |
| `ApiService` | `lib/data/services/api_service.dart` | HTTP requests to backend |
| `AuthService` | `lib/features/auth/services/auth_service.dart` | Login with FCM token update |

---

## API Endpoints

### Base URL
```
https://nowshipping.co/api/v1
```

### Endpoints

#### 1. Update FCM Token
**Endpoint**: `POST /business/update-fcm-token`

**Headers**:
```
Authorization: Bearer {auth_token}
Content-Type: application/json
```

**Request Body**:
```json
{
  "fcmToken": "string"
}
```

**Response**: `200 OK`

**Usage**: Called automatically on login and token refresh

---

#### 2. Get Notifications
**Endpoint**: `GET /business/notifications`

**Headers**:
```
Authorization: Bearer {auth_token}
```

**Response**:
```json
[
  {
    "_id": "string",
    "title": "string",
    "body": "string",
    "type": "string",
    "data": {},
    "isRead": false,
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
]
```

**Alternative Response Formats** (handled by service):
```json
{
  "data": [...],
  "notifications": [...]
}
```

---

#### 3. Mark Notification as Read
**Endpoint**: `PUT /business/notifications/{notificationId}/read`

**Headers**:
```
Authorization: Bearer {auth_token}
Content-Type: application/json
```

**Request Body**:
```json
{}
```

**Response**: `200 OK`

---

#### 4. Mark All Notifications as Read
**Endpoint**: `PUT /business/notifications/mark-all-read`

**Headers**:
```
Authorization: Bearer {auth_token}
Content-Type: application/json
```

**Request Body**:
```json
{}
```

**Response**: `200 OK`

---

#### 5. Delete Notification
**Endpoint**: `DELETE /business/notifications/{notificationId}`

**Headers**:
```
Authorization: Bearer {auth_token}
```

**Response**: `200 OK`

---

## Configuration Files

### Android Configuration

#### 1. `android/build.gradle`
```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        classpath 'com.google.gms:google-services:4.3.15'  // Required
    }
}
```

#### 2. `android/app/build.gradle`
```gradle
apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply plugin: 'com.google.gms.google-services'  // Required

android {
    defaultConfig {
        minSdkVersion 21  // Minimum for FCM
        targetSdkVersion 33
    }
}

dependencies {
    implementation 'com.google.firebase:firebase-messaging:23.0.0'
}
```

#### 3. `android/app/src/main/AndroidManifest.xml`
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Firebase Cloud Messaging Permissions -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    
    <application>
        <!-- Firebase Cloud Messaging Configuration -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="high_importance_channel" />
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@mipmap/ic_launcher" />
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_color"
            android:resource="@android:color/transparent" />
    </application>
</manifest>
```

### iOS Configuration

#### 1. `ios/Runner/Info.plist`
```xml
<dict>
    <!-- Firebase Configuration -->
    <key>FirebaseAppDelegateProxyEnabled</key>
    <false/>
    
    <!-- Background modes for remote notifications -->
    <key>UIBackgroundModes</key>
    <array>
        <string>fetch</string>
        <string>remote-notification</string>
    </array>
</dict>
```

#### 2. `ios/Runner/AppDelegate.swift`
```swift
import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Firebase
    FirebaseApp.configure()
    
    // Request notification permissions
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { granted, error in
          if let error = error {
            print("Error requesting notification authorization: \(error)")
          }
        }
      )
    }
    
    application.registerForRemoteNotifications()
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle FCM token
  override func application(_ application: UIApplication, 
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
}
```

#### 3. `ios/Podfile`
```ruby
platform :ios, '12.0'  # Minimum for FCM

pod 'Firebase/Messaging'
```

---

## Flow Diagrams

### App Initialization Flow

```
App Start
    │
    ▼
WidgetsFlutterBinding.ensureInitialized()
    │
    ▼
Firebase.initializeApp()
    │
    ├─ Success ──▶ FirebaseMessagingService.initialize()
    │                 │
    │                 ├─▶ Request Permissions
    │                 ├─▶ Initialize Local Notifications
    │                 ├─▶ Get FCM Token
    │                 │     ├─▶ Save to SharedPreferences
    │                 │     └─▶ Send to Server (if authenticated)
    │                 ├─▶ Setup Foreground Handlers
    │                 └─▶ Setup Background Handlers
    │
    └─ Failure ──▶ Continue without Firebase features
    │
    ▼
runApp(MyApp())
```

### Login Flow with FCM Token Update

```
User Login
    │
    ▼
AuthService.login()
    │
    ├─ Success ──▶ Save Auth Token
    │                 │
    │                 ▼
    │         FirebaseMessagingService.updateTokenOnLogin()
    │                 │
    │                 ├─▶ Delete Old Token
    │                 ├─▶ Generate New Token
    │                 ├─▶ Save to SharedPreferences
    │                 └─▶ Send to Server
    │                       │
    │                       └─▶ POST /business/update-fcm-token
    │
    └─ Failure ──▶ Show Error Message
```

### Notification Reception Flow

```
FCM Message Received
    │
    ├─ App in Foreground ──▶ FirebaseMessaging.onMessage
    │                           │
    │                           ▼
    │                   Show Local Notification
    │                           │
    │                           └─▶ User sees notification
    │
    ├─ App in Background ──▶ System Notification
    │                           │
    │                           └─▶ User taps notification
    │                                 │
    │                                 ▼
    │                         App opens (onMessageOpenedApp)
    │
    └─ App Terminated ──▶ System Notification
                            │
                            └─▶ User taps notification
                                  │
                                  ▼
                            App launches
                                  │
                                  ▼
                            Check initial message
```

### Notification List Flow

```
NotificationsScreen Load
    │
    ▼
notificationsProvider (Riverpod)
    │
    ▼
NotificationService.getNotifications()
    │
    ▼
ApiService.get('/business/notifications')
    │
    ├─ Success ──▶ Parse Response
    │                 │
    │                 ├─▶ Direct Array
    │                 ├─▶ Nested in 'data'
    │                 └─▶ Nested in 'notifications'
    │                 │
    │                 ▼
    │         Map to NotificationModel List
    │                 │
    │                 ▼
    │         Display in UI
    │
    └─ Error ──▶ Show Error State
```

---

## UI Components

### 1. Notification Badge (Dashboard Header)

**Location**: `lib/features/business/dashboard/widgets/dashboard_header.dart`

**Features**:
- Displays unread count badge
- Navigates to notifications screen on tap
- Auto-refreshes after returning from notifications screen

**Implementation**:
```dart
final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final service = NotificationService();
  return await service.getUnreadCount();
});

Widget _buildNotificationIcon(BuildContext context, WidgetRef ref) {
  final unreadCountAsync = ref.watch(unreadCountProvider);
  
  return InkWell(
    onTap: () async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
      );
      ref.invalidate(unreadCountProvider);
    },
    child: Stack(
      children: [
        Icon(Icons.notifications_outlined),
        unreadCountAsync.when(
          data: (count) {
            if (count == 0) return SizedBox.shrink();
            return Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count > 9 ? '9+' : count.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            );
          },
          loading: () => SizedBox.shrink(),
          error: (_, __) => SizedBox.shrink(),
        ),
      ],
    ),
  );
}
```

### 2. Notifications Screen

**Location**: `lib/features/business/notifications/screens/notifications_screen.dart`

**Features**:
- Pull-to-refresh
- Read/unread visual distinction
- Mark as read (individual and bulk)
- Empty state
- Error state with retry
- Time ago formatting

**UI States**:

**Loading State**:
```dart
Center(
  child: CircularProgressIndicator(
    color: Color(0xfff29620),
  ),
)
```

**Empty State**:
```dart
Column(
  children: [
    Icon(Icons.notifications_none_outlined, size: 80),
    Text('No notifications yet'),
    Text('You\'ll see updates about your orders\nand deliveries here'),
  ],
)
```

**Error State**:
```dart
Column(
  children: [
    Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
    Text('Failed to load notifications'),
    Text(error.toString()),
    ElevatedButton(
      onPressed: _refreshNotifications,
      child: Text('Retry'),
    ),
  ],
)
```

**Notification Card**:
- **Unread**: Blue tint background, bold title, check icon button
- **Read**: White background, normal title, no action button

### 3. Permission Dialog

**Location**: `lib/core/services/notification_permission_helper.dart`

**Features**:
- Explains why notifications are needed
- Lists benefits
- Opens app settings

**Dialog Content**:
- Title: "Enable Notifications"
- Benefits list:
  - Order status updates
  - New order alerts
  - Important announcements
- Actions: "Not Now" and "Open Settings"

---

## Testing Guide

### 1. Testing FCM Token Generation

**Steps**:
1. Launch app
2. Check console for: `✅ Firebase initialized successfully`
3. Check console for: `✅ Firebase Messaging initialized successfully`
4. Check console for: `📱 FCM Token: {token}`
5. Verify token is saved in SharedPreferences

**Expected Output**:
```
I/flutter: ✅ Firebase initialized successfully
I/flutter: ✅ Firebase Messaging initialized successfully
I/flutter: 📱 FCM Token: eK4RyC...xyz123
I/flutter: 💾 FCM token saved to preferences
```

### 2. Testing Token Update on Login

**Steps**:
1. Login with valid credentials
2. Check console for token update messages
3. Verify backend receives token update request

**Expected Output**:
```
I/flutter: Login successful
I/flutter: ✅ FCM token updated on login
I/flutter: 🔄 New FCM token on login: eK4RyC...xyz123
I/flutter: ✅ FCM token sent to server successfully
```

### 3. Testing Foreground Notifications

**Steps**:
1. Keep app open and in foreground
2. Send test notification from Firebase Console
3. Verify local notification appears
4. Check console logs

**Expected Output**:
```
I/flutter: 📱 Received foreground message: 0:1234567890
I/flutter: 📱 Notification: {title: Test, body: Message}
I/flutter: 📱 Data: {}
```

### 4. Testing Background Notifications

**Steps**:
1. Put app in background (home button)
2. Send test notification from Firebase Console
3. Verify system notification appears
4. Tap notification
5. Verify app opens

**Expected Output**:
```
I/flutter: 📱 Handling background message: 0:1234567890
I/flutter: 📱 Message data: {}
```

### 5. Testing Notification List

**Steps**:
1. Navigate to Notifications Screen
2. Verify notifications load
3. Test pull-to-refresh
4. Test mark as read
5. Test mark all as read

**Expected Behavior**:
- Loading indicator while fetching
- Notifications displayed in list
- Unread notifications have blue tint
- Read notifications have white background
- Badge count updates after marking as read

### 6. Testing Permission Flow

**Steps**:
1. Deny notification permission
2. Navigate to home screen
3. Verify permission dialog appears
4. Tap "Open Settings"
5. Grant permission in settings
6. Return to app
7. Verify notifications work

### 7. Testing Multi-Device Login

**Steps**:
1. Login on Device A
2. Note FCM token A
3. Login on Device B
4. Note FCM token B
5. Verify backend receives token B
6. Send notification to token B
7. Verify Device B receives notification
8. Verify Device A does not receive notification

---

## Troubleshooting

### Issue: Firebase Not Initialized

**Symptoms**:
```
❌ Error initializing Firebase: [core/no-app] No Firebase App '[DEFAULT]' has been created
```

**Solutions**:
1. Ensure `Firebase.initializeApp()` is called in `main.dart`
2. Verify `firebase_options.dart` exists and is correct
3. Check `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) exists
4. For hot reload issues, do a full restart (`flutter run`)

### Issue: FCM Token Not Generated

**Symptoms**:
```
❌ Failed to get FCM token
```

**Solutions**:
1. Check internet connection
2. Verify Firebase project is correctly configured
3. Check Google Services plugin is applied in `build.gradle`
4. Verify `google-services.json` is in correct location
5. Check device/emulator has Google Play Services (Android)

### Issue: Token Not Sent to Server

**Symptoms**:
```
⚠️  No auth token available, skipping token sync
```

**Solutions**:
1. Ensure user is logged in before token sync
2. Check auth token is saved in SharedPreferences
3. Verify API endpoint URL is correct
4. Check network connectivity
5. Verify backend endpoint exists and accepts requests

### Issue: Notifications Not Appearing

**Symptoms**:
- No notification received when app is in foreground/background

**Solutions**:
1. Check notification permissions are granted
2. Verify FCM token is registered with backend
3. Check notification channel is created (Android)
4. Verify `flutter_local_notifications` is initialized
5. Check console logs for errors
6. Test with Firebase Console test notification

### Issue: Background Notifications Not Working

**Symptoms**:
- Notifications work in foreground but not in background

**Solutions**:
1. Verify `firebaseMessagingBackgroundHandler` is top-level function
2. Check `@pragma('vm:entry-point')` annotation is present
3. Verify background handler is registered in `initialize()`
4. Check Android notification channel is created
5. Verify iOS background modes are enabled in `Info.plist`

### Issue: Permission Dialog Not Showing

**Symptoms**:
- Permission dialog doesn't appear

**Solutions**:
1. Check `NotificationPermissionHelper.checkPermissions()` is called
2. Verify `permission_handler` package is added
3. Check platform-specific permission handling
4. Verify dialog is shown after widget build (use `addPostFrameCallback`)

### Issue: Notification Badge Not Updating

**Symptoms**:
- Badge count doesn't update after marking as read

**Solutions**:
1. Verify `ref.invalidate(unreadCountProvider)` is called
2. Check `NotificationService.getUnreadCount()` returns correct count
3. Verify backend marks notification as read correctly
4. Check Riverpod provider is properly set up

### Issue: iOS Notifications Not Working

**Symptoms**:
- Notifications work on Android but not iOS

**Solutions**:
1. Verify APNs certificate is configured in Firebase Console
2. Check `AppDelegate.swift` has correct Firebase setup
3. Verify `GoogleService-Info.plist` is in `ios/Runner/`
4. Check iOS background modes in `Info.plist`
5. Verify `Podfile` includes Firebase/Messaging
6. Run `pod install` in `ios/` directory

---

## Integration Guide

### Adding Notifications to a New App

#### Step 1: Add Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^3.8.1
  firebase_messaging: ^15.1.5
  flutter_local_notifications: ^18.0.1
  timeago: ^3.7.0
  permission_handler: ^11.3.1
  shared_preferences: ^2.2.2
```

#### Step 2: Firebase Setup

1. Create Firebase project
2. Add Android app (package name)
3. Add iOS app (bundle ID)
4. Download config files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
5. Run `flutterfire configure`

#### Step 3: Copy Service Files

Copy these files to your project:
- `lib/core/services/firebase_messaging_service.dart`
- `lib/core/services/notification_permission_helper.dart`
- `lib/features/business/notifications/services/notification_service.dart`
- `lib/features/business/notifications/models/notification_model.dart`

#### Step 4: Update Configuration

1. Update `ApiConstants.baseUrl` in `firebase_messaging_service.dart`
2. Update API endpoints in `notification_service.dart`
3. Update backend endpoints to match your API

#### Step 5: Initialize in main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final firebaseMessagingService = FirebaseMessagingService();
  await firebaseMessagingService.initialize();
  
  runApp(MyApp());
}
```

#### Step 6: Update Login Flow

Add FCM token update to your login function:
```dart
final firebaseMessaging = FirebaseMessagingService();
if (firebaseMessaging.isInitialized) {
  await firebaseMessaging.updateTokenOnLogin(authToken);
}
```

#### Step 7: Add UI Components

1. Copy `NotificationsScreen` to your project
2. Add notification badge to your dashboard/header
3. Add navigation to notifications screen

#### Step 8: Configure Backend

Ensure your backend has these endpoints:
- `POST /business/update-fcm-token` - Update FCM token
- `GET /business/notifications` - Get notifications
- `PUT /business/notifications/:id/read` - Mark as read
- `PUT /business/notifications/mark-all-read` - Mark all as read

---

## Best Practices

### 1. Error Handling
- Always wrap FCM operations in try-catch
- Continue app flow even if FCM fails
- Log errors for debugging
- Show user-friendly error messages

### 2. Token Management
- Update token on every login
- Listen for token refresh
- Handle token deletion gracefully
- Sync token with backend asynchronously

### 3. Permission Handling
- Request permissions at appropriate times
- Explain why permissions are needed
- Provide easy way to enable in settings
- Handle denied permissions gracefully

### 4. Notification Display
- Show local notifications in foreground
- Use appropriate notification channels (Android)
- Set proper priority and importance
- Include relevant data in notification payload

### 5. State Management
- Use Riverpod for reactive state
- Invalidate providers after updates
- Handle loading and error states
- Cache notification data appropriately

### 6. Testing
- Test on both Android and iOS
- Test foreground and background scenarios
- Test permission flows
- Test multi-device scenarios
- Use Firebase Console for test notifications

---

## Conclusion

This notification system provides a complete, production-ready implementation of Firebase Cloud Messaging in Flutter. It handles all scenarios including foreground notifications, background notifications, token management, and permission handling.

For questions or issues, refer to the troubleshooting section or check the Firebase documentation.

---

**Last Updated**: 2024
**Version**: 1.0.6+6
**Flutter Version**: 3.0+
**Firebase Messaging**: 15.1.5
