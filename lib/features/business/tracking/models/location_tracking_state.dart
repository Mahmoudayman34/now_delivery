import 'package:geolocator/geolocator.dart';

class LocationTrackingState {
  final bool isTracking;
  final bool isLocationTrackingEnabled;
  final bool isSocketConnected;
  final bool isLoading;
  final Position? currentPosition;
  final String? errorMessage;
  
  const LocationTrackingState({
    this.isTracking = false,
    this.isLocationTrackingEnabled = false,
    this.isSocketConnected = false,
    this.isLoading = false,
    this.currentPosition,
    this.errorMessage,
  });
  
  LocationTrackingState copyWith({
    bool? isTracking,
    bool? isLocationTrackingEnabled,
    bool? isSocketConnected,
    bool? isLoading,
    Position? currentPosition,
    String? errorMessage,
  }) {
    return LocationTrackingState(
      isTracking: isTracking ?? this.isTracking,
      isLocationTrackingEnabled: isLocationTrackingEnabled ?? this.isLocationTrackingEnabled,
      isSocketConnected: isSocketConnected ?? this.isSocketConnected,
      isLoading: isLoading ?? this.isLoading,
      currentPosition: currentPosition ?? this.currentPosition,
      errorMessage: errorMessage,
    );
  }
}


