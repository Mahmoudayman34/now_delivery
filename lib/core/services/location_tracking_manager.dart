import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'location_service.dart';
import 'socket_service.dart';
import 'location_tracking_api_service.dart';
import 'tracking_api_config.dart';

// Provider for location tracking manager
final locationTrackingManagerProvider = Provider<LocationTrackingManager>((ref) {
  final locationService = ref.read(locationServiceProvider);
  final socketService = ref.read(socketServiceProvider);
  final apiService = ref.read(locationTrackingApiServiceProvider);
  return LocationTrackingManager(
    locationService: locationService,
    socketService: socketService,
    apiService: apiService,
  );
});

class LocationTrackingManager {
  final LocationService locationService;
  final SocketService socketService;
  final LocationTrackingApiService apiService;
  
  StreamSubscription<Position?>? _locationSubscription;
  Timer? _locationUpdateTimer;
  
  bool _isTracking = false;
  bool _isLocationTrackingEnabled = false;
  Position? _lastPosition;
  
  LocationTrackingManager({
    required this.locationService,
    required this.socketService,
    required this.apiService,
  });
  
  // Initialize tracking
  Future<void> initialize() async {
    // Initialize socket
    await socketService.initializeSocket();
    
    // Check location status from server
    await checkLocationStatus();
    
    print('📡 Location tracking manager initialized');
  }
  
  // Check location tracking status from server
  Future<void> checkLocationStatus() async {
    final result = await apiService.getLocationStatus();
    if (result['success'] == true) {
      _isLocationTrackingEnabled = result['isLocationTrackingEnabled'] ?? false;
      print('📍 Location tracking enabled: $_isLocationTrackingEnabled');
    }
  }
  
  // Start location tracking
  Future<bool> startTracking({BuildContext? context}) async {
    if (_isTracking) {
      print('⚠️ Location tracking already started');
      return true;
    }
    
    // Check if location tracking is enabled on server
    if (!_isLocationTrackingEnabled) {
      print('⚠️ Location tracking is not enabled on server');
      // Try to enable it
      final result = await setLocationTrackingEnabled(true);
      if (!result) {
        return false;
      }
    }
    
    // Start location tracking using existing location service
    final started = await locationService.startLocationTracking(context: context);
    if (!started) {
      print('❌ Failed to start location tracking');
      return false;
    }
    
    _isTracking = true;
    
    // Use ONLY timer-based updates (every 25 seconds)
    // This ensures consistent 25-second interval regardless of movement
    _locationUpdateTimer = Timer.periodic(
      Duration(seconds: TrackingApiConfig.updateIntervalSeconds),
      (_) async {
        final position = await locationService.getCurrentLocation();
        if (position != null) {
          await _updateLocation(position.latitude, position.longitude);
        }
      },
    );
    
    // Send initial location immediately
    final initialPosition = await locationService.getCurrentLocation();
    if (initialPosition != null) {
      await _updateLocation(initialPosition.latitude, initialPosition.longitude);
    }
    
    print('✅ Location tracking started successfully (updates every 25 seconds)');
    return true;
  }
  
  // Stop location tracking
  void stopTracking() {
    _isTracking = false;
    _locationSubscription?.cancel();
    _locationUpdateTimer?.cancel();
    locationService.stopLocationTracking();
    print('🛑 Location tracking stopped');
  }
  
  // Update location (send via both REST API and Socket.IO)
  Future<void> _updateLocation(double latitude, double longitude) async {
    if (!_isLocationTrackingEnabled) {
      return;
    }
    
    // Update last position without distance filtering
    _lastPosition = Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
    
    print('📍 Updating location: $latitude, $longitude');
    
    // Send via Socket.IO (faster, real-time)
    socketService.sendLocationUpdate(
      latitude: latitude,
      longitude: longitude,
    );
    
    // Also send via REST API (reliable backup)
    final result = await apiService.updateLocation(
      latitude: latitude,
      longitude: longitude,
    );
    
    if (result['success'] == true) {
      print('✅ Location updated successfully via REST API');
    } else {
      print('⚠️ Failed to update location via REST API: ${result['message']}');
    }
  }
  
  // Enable/disable location tracking
  Future<bool> setLocationTrackingEnabled(bool enabled) async {
    final result = await apiService.updateLocationPreferences(
      isEnabled: enabled,
    );
    
    if (result['success'] == true) {
      _isLocationTrackingEnabled = enabled;
      print('✅ Location tracking ${enabled ? 'enabled' : 'disabled'}');
      return true;
    } else {
      print('❌ Failed to update location tracking preference: ${result['message']}');
      return false;
    }
  }
  
  // Send status update
  void sendStatusUpdate(bool isAvailable) {
    socketService.sendStatusUpdate(isAvailable: isAvailable);
  }
  
  // Dispose resources
  void dispose() {
    stopTracking();
    socketService.disconnect();
    print('🗑️ Location tracking manager disposed');
  }
  
  // Getters
  bool get isTracking => _isTracking;
  bool get isLocationTrackingEnabled => _isLocationTrackingEnabled;
  bool get isSocketConnected => socketService.isConnected;
  Position? get lastPosition => _lastPosition;
}


