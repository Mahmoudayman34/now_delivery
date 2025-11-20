import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/location_tracking_manager.dart';
import '../../../../core/services/background_location_service.dart';
import '../models/location_tracking_state.dart';
import 'package:flutter_riverpod/legacy.dart';

// State notifier for location tracking
class LocationTrackingNotifier extends StateNotifier<LocationTrackingState> {
  final LocationTrackingManager _trackingManager;
  
  LocationTrackingNotifier(this._trackingManager)
      : super(const LocationTrackingState());
  
  // Initialize
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      await _trackingManager.initialize();
      await checkLocationStatus();
      state = state.copyWith(
        isLoading: false,
        isSocketConnected: _trackingManager.isSocketConnected,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initialize: $e',
      );
    }
  }
  
  // Check location status
  Future<void> checkLocationStatus() async {
    await _trackingManager.checkLocationStatus();
    state = state.copyWith(
      isLocationTrackingEnabled: _trackingManager.isLocationTrackingEnabled,
    );
  }
  
  // Start tracking
  Future<void> startTracking({BuildContext? context}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final success = await _trackingManager.startTracking(context: context);
      if (success) {
        // Start background location updates
        await BackgroundLocationService.startPeriodicLocationUpdates();
        
        state = state.copyWith(
          isTracking: true,
          isLoading: false,
          currentPosition: _trackingManager.lastPosition,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to start tracking. Please check permissions.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to start tracking: $e',
      );
    }
  }
  
  // Stop tracking
  Future<void> stopTracking() async {
    _trackingManager.stopTracking();
    await BackgroundLocationService.stopPeriodicLocationUpdates();
    
    state = state.copyWith(
      isTracking: false,
      currentPosition: null,
    );
  }
  
  // Toggle location tracking
  Future<void> toggleLocationTracking(bool enabled, {BuildContext? context}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final success = await _trackingManager.setLocationTrackingEnabled(enabled);
      if (success) {
        state = state.copyWith(
          isLocationTrackingEnabled: enabled,
          isLoading: false,
        );
        
        if (enabled) {
          await startTracking(context: context);
        } else {
          await stopTracking();
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to update location tracking preferences',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update preferences: $e',
      );
    }
  }
  
  // Update status
  void updateStatus(bool isAvailable) {
    _trackingManager.sendStatusUpdate(isAvailable);
  }
  
  // Refresh socket connection status
  void refreshSocketStatus() {
    state = state.copyWith(
      isSocketConnected: _trackingManager.isSocketConnected,
    );
  }
  
  // Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider for location tracking
final locationTrackingProvider = StateNotifierProvider<LocationTrackingNotifier, LocationTrackingState>((ref) {
  final trackingManager = ref.read(locationTrackingManagerProvider);
  return LocationTrackingNotifier(trackingManager);
});

