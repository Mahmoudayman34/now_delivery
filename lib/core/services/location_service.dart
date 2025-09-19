import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final locationStreamProvider = StreamProvider<Position?>((ref) {
  final locationService = ref.read(locationServiceProvider);
  return locationService.positionStream;
});

final currentLocationProvider = FutureProvider<Position?>((ref) {
  final locationService = ref.read(locationServiceProvider);
  return locationService.getCurrentLocation();
});

class LocationService {
  StreamSubscription<Position>? _positionStreamSubscription;
  final StreamController<Position?> _positionController = 
      StreamController<Position?>.broadcast();
  
  Stream<Position?> get positionStream => _positionController.stream;
  bool _isTracking = false;
  Position? _lastKnownPosition;

  Position? get lastKnownPosition => _lastKnownPosition;
  bool get isTracking => _isTracking;

  /// Check and request location permissions
  Future<bool> requestLocationPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check current permission status
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      return false;
    }

    // Request background location permission for continuous tracking
    final backgroundPermission = await Permission.locationAlways.request();
    return backgroundPermission.isGranted || backgroundPermission.isLimited;
  }

  /// Get current location once
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _lastKnownPosition = position;
      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Start continuous location tracking
  Future<bool> startLocationTracking() async {
    if (_isTracking) return true;

    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return false;

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _lastKnownPosition = position;
          _positionController.add(position);
          
          // Print location to terminal when online
          print('🚛 DRIVER LOCATION UPDATE:');
          print('   📍 Latitude: ${position.latitude}');
          print('   📍 Longitude: ${position.longitude}');
          print('   🎯 Accuracy: ${position.accuracy.toStringAsFixed(2)}m');
          print('   ⏰ Time: ${DateTime.now().toString().substring(11, 19)}');
          print('   🔗 Google Maps: https://www.google.com/maps?q=${position.latitude},${position.longitude}');
          print('   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        },
        onError: (error) {
          print('❌ Location tracking error: $error');
          _positionController.addError(error);
        },
      );

      _isTracking = true;
      
      // Print initial status
      print('🟢 DRIVER STATUS: ONLINE');
      print('📡 Location tracking started - updates every 10 meters');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      return true;
    } catch (e) {
      print('Error starting location tracking: $e');
      return false;
    }
  }

  /// Stop location tracking
  void stopLocationTracking() {
    if (!_isTracking) return;

    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isTracking = false;
    _positionController.add(null);
    
    // Print offline status
    print('🔴 DRIVER STATUS: OFFLINE');
    print('📡 Location tracking stopped');
    print('🔒 Orders are now locked');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  /// Calculate distance between two points
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Open external map app for navigation
  Future<void> openMapNavigation(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    // Note: url_launcher will be used in the widget layer
    print('Navigation URL: $url');
  }

  /// Dispose resources
  void dispose() {
    stopLocationTracking();
    _positionController.close();
  }
}

