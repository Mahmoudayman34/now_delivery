import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/location_permission_dialog.dart';

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
  /// [showDialogCallback] is an optional callback that shows a dialog before requesting permission
  /// [context] is required for showing background location disclosure dialog
  /// Should return true if user accepts, false if they decline
  Future<bool> requestLocationPermission({
    Future<bool> Function()? showDialogCallback,
    BuildContext? context,
  }) async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check current permission status
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      // Show dialog before requesting permission if callback is provided
      if (showDialogCallback != null) {
        final userAccepted = await showDialogCallback();
        if (!userAccepted) {
          return false;
        }
      }
      
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      return false;
    }

    // Request background location permission ONLY after showing prominent disclosure
    // This is required by Google Play Store policy
    if (permission == LocationPermission.whileInUse) {
      // User has foreground permission, now request background permission with disclosure
      if (context != null && context.mounted) {
        // Show prominent disclosure dialog before requesting background location
        final userConsented = await showBackgroundLocationDisclosureDialog(context);
        if (!userConsented) {
          // User denied background location, but we can still use foreground permission
          return true; // Return true because foreground permission is sufficient
        }
      }
      
      // Only request background location if user consented
      try {
        await Permission.locationAlways.request();
        // Return true even if background permission denied, as long as foreground works
        return true;
      } catch (e) {
        // If background permission fails, still allow foreground tracking
        return true;
      }
    }

    // Already has "always" permission (includes background)
    return true;
  }

  /// Get current location once
  Future<Position?> getCurrentLocation({
    Future<bool> Function()? showDialogCallback,
    BuildContext? context,
  }) async {
    try {
      final hasPermission = await requestLocationPermission(
        showDialogCallback: showDialogCallback,
        context: context,
      );
      if (!hasPermission) return _lastKnownPosition;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          // Return last known position if timeout
          if (_lastKnownPosition != null) return _lastKnownPosition!;
          throw TimeoutException('Location request timed out');
        },
      );

      _lastKnownPosition = position;
      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return _lastKnownPosition; // Return last known position on error
    }
  }

  /// Start continuous location tracking
  /// [showDialogCallback] is an optional callback that shows a dialog before requesting permission
  /// [context] is required for showing background location disclosure dialog
  Future<bool> startLocationTracking({
    Future<bool> Function()? showDialogCallback,
    BuildContext? context,
  }) async {
    if (_isTracking) return true;

    try {
      final hasPermission = await requestLocationPermission(
        showDialogCallback: showDialogCallback,
        context: context,
      );
      if (!hasPermission) return false;

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0, // No distance filter - rely on timer
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
      print('📡 Location tracking started - updates every 25 seconds');
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

