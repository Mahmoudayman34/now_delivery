import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';

/// Background message handler must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📱 Handling background message: ${message.messageId}');
  debugPrint('📱 Message data: ${message.data}');
  debugPrint('📱 Message notification: ${message.notification?.title}');
}

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  
  factory FirebaseMessagingService() {
    return _instance;
  }
  
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  String? _fcmToken;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  String? get fcmToken => _fcmToken;

  /// Initialize Firebase Messaging Service
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️  Firebase Messaging already initialized');
      return;
    }

    try {
      // Verify Firebase Core is initialized
      try {
        Firebase.app();
      } catch (e) {
        debugPrint('❌ Firebase Core is not initialized');
        return;
      }

      // Request notification permissions
      await _requestPermission();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get and save FCM token
      await getAndSaveToken();

      // Setup message handlers
      _setupForegroundMessageHandlers();
      _setupBackgroundMessageHandlers();

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('🔄 FCM Token refreshed: $newToken');
        _fcmToken = newToken;
        _saveTokenToPreferences(newToken);
        _sendTokenToServer(newToken);
      });

      _isInitialized = true;
      debugPrint('✅ Firebase Messaging initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Firebase Messaging: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    try {
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
    } catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
    }
  }

  /// Initialize local notifications for foreground messages
  Future<void> _initializeLocalNotifications() async {
    try {
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

      debugPrint('✅ Local notifications initialized');
    } catch (e) {
      debugPrint('❌ Error initializing local notifications: $e');
    }
  }

  /// Setup foreground message handlers
  void _setupForegroundMessageHandlers() {
    // Listen for messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📱 Received foreground message: ${message.messageId}');
      debugPrint('📱 Notification: ${message.notification?.title}');
      debugPrint('📱 Data: ${message.data}');

      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    // Listen for notification taps that opened the app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🔔 Notification opened app: ${message.messageId}');
      // TODO: Navigate to appropriate screen based on notification data
    });
  }

  /// Setup background message handlers
  void _setupBackgroundMessageHandlers() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  /// Show local notification for foreground messages
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null) {
        await _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription: 'This channel is used for important notifications.',
              importance: Importance.high,
              priority: Priority.high,
              icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    } catch (e) {
      debugPrint('❌ Error showing local notification: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate screen based on payload
  }

  /// Get and save FCM token
  Future<String?> getAndSaveToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();

      if (token != null) {
        _fcmToken = token;
        await _saveTokenToPreferences(token);
        await _sendTokenToServer(token);
        debugPrint('📱 FCM Token: $token');
        return token;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Failed to get FCM token: $e');
      return null;
    }
  }

  /// Update FCM token on login (for multi-device support)
  Future<void> updateTokenOnLogin(String authToken) async {
    try {
      // Delete old token
      await _firebaseMessaging.deleteToken();
      debugPrint('🗑️  Old FCM token deleted');

      // Get new token
      String? newToken = await _firebaseMessaging.getToken();

      if (newToken != null) {
        _fcmToken = newToken;
        await _saveTokenToPreferences(newToken);
        await _sendTokenToServer(newToken, authToken: authToken);
        debugPrint('✅ FCM token updated on login');
        debugPrint('🔄 New FCM token on login: $newToken');
      }
    } catch (e) {
      debugPrint('❌ Error updating FCM token on login: $e');
    }
  }

  /// Save token to SharedPreferences
  Future<void> _saveTokenToPreferences(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      debugPrint('💾 FCM token saved to preferences');
    } catch (e) {
      debugPrint('❌ Error saving FCM token to preferences: $e');
    }
  }

  /// Send token to backend server
  Future<void> _sendTokenToServer(String token, {String? authToken}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAuthToken = authToken ?? prefs.getString('auth_token');

      if (savedAuthToken == null) {
        debugPrint('⚠️  No auth token available, skipping token sync');
        return;
      }

      const baseUrl = 'https://nowshipping.co/api/v1';
      final response = await http.post(
        Uri.parse('$baseUrl/courier/update-fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $savedAuthToken',
        },
        body: json.encode({'fcmToken': token}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          debugPrint('✅ FCM token sent to server successfully');
        } else {
          debugPrint('⚠️  Server response: ${responseData['message']}');
        }
      } else {
        debugPrint('❌ Failed to send FCM token to server: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error sending FCM token to server: $e');
    }
  }

  /// Get initial message (for when app is opened from terminated state)
  Future<RemoteMessage?> getInitialMessage() async {
    return await _firebaseMessaging.getInitialMessage();
  }
}

