import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/location_service.dart';

final driverStatusProvider = StateNotifierProvider<DriverStatusNotifier, DriverStatus>((ref) {
  return DriverStatusNotifier(ref);
});

class DriverStatusNotifier extends StateNotifier<DriverStatus> {
  final Ref _ref;
  
  DriverStatusNotifier(this._ref) : super(const DriverStatus());

  /// Toggle driver online/offline status
  /// [showDialogCallback] is an optional callback that shows a dialog before requesting permission
  /// [context] is required for showing background location disclosure dialog
  Future<void> toggleStatus({
    Future<bool> Function()? showDialogCallback,
    BuildContext? context,
  }) async {
    final locationService = _ref.read(locationServiceProvider);
    
    if (state.isOnline) {
      // Going offline - stop location tracking
      locationService.stopLocationTracking();
      state = state.copyWith(isOnline: false);
    } else {
      // Going online - start location tracking
      final success = await locationService.startLocationTracking(
        showDialogCallback: showDialogCallback,
        context: context,
      );
      if (success) {
        state = state.copyWith(isOnline: true);
      } else {
        // Handle permission denied or location services disabled
        state = state.copyWith(
          isOnline: false,
          errorMessage: 'Location permission required to go online',
        );
      }
    }
  }

  /// Set online status directly
  /// [showDialogCallback] is an optional callback that shows a dialog before requesting permission
  /// [context] is required for showing background location disclosure dialog
  Future<void> setOnline(
    bool isOnline, {
    Future<bool> Function()? showDialogCallback,
    BuildContext? context,
  }) async {
    if (state.isOnline == isOnline) return;
    
    final locationService = _ref.read(locationServiceProvider);
    
    if (isOnline) {
      final success = await locationService.startLocationTracking(
        showDialogCallback: showDialogCallback,
        context: context,
      );
      if (success) {
        state = state.copyWith(isOnline: true, errorMessage: null);
      } else {
        state = state.copyWith(
          isOnline: false,
          errorMessage: 'Failed to start location tracking',
        );
      }
    } else {
      locationService.stopLocationTracking();
      state = state.copyWith(isOnline: false, errorMessage: null);
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

class DriverStatus {
  final bool isOnline;
  final String? errorMessage;

  const DriverStatus({
    this.isOnline = false,
    this.errorMessage,
  });

  DriverStatus copyWith({
    bool? isOnline,
    String? errorMessage,
  }) {
    return DriverStatus(
      isOnline: isOnline ?? this.isOnline,
      errorMessage: errorMessage,
    );
  }

  String get statusText => isOnline ? 'Online' : 'Offline';
}

