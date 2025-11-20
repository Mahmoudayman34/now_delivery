import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'tracking_api_config.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == 'locationUpdate') {
        print('🔄 Background location update task started');
        
        // Get current location
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        
        // Get stored token
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        final isTrackingEnabled = prefs.getBool('is_location_tracking_enabled') ?? false;
        
        if (token == null) {
          print('⚠️ No token found in background task');
          return Future.value(false);
        }
        
        if (!isTrackingEnabled) {
          print('⚠️ Location tracking disabled in background task');
          return Future.value(false);
        }
        
        // Send location update
        final response = await http.post(
          Uri.parse(TrackingApiConfig.updateLocation),
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
          print('✅ Background location update sent: ${position.latitude}, ${position.longitude}');
          return Future.value(true);
        } else {
          print('❌ Background location update failed: ${response.statusCode}');
          return Future.value(false);
        }
      }
      return Future.value(false);
    } catch (e) {
      print('❌ Background task error: $e');
      return Future.value(false);
    }
  });
}

class BackgroundLocationService {
  static const String _taskName = 'locationUpdate';
  
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    print('✅ WorkManager initialized for background location');
  }
  
  static Future<void> startPeriodicLocationUpdates() async {
    // Note: WorkManager minimum interval is 15 minutes for periodic tasks
    // For 25-second updates, we rely on foreground tracking
    // Background service serves as a fallback only
    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: const Duration(minutes: 15), // Minimum allowed by Android
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
    
    // Store tracking state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_location_tracking_enabled', true);
    
    print('✅ Background location updates started (every 15 minutes - minimum allowed)');
    print('💡 For 25-second updates, keep app in foreground');
  }
  
  static Future<void> stopPeriodicLocationUpdates() async {
    await Workmanager().cancelByUniqueName(_taskName);
    
    // Update tracking state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_location_tracking_enabled', false);
    
    print('🛑 Background location updates stopped');
  }
  
  static Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
    print('🗑️ All background tasks cancelled');
  }
}


