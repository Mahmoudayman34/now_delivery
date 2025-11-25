import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// StreamProvider that monitors network connectivity status
/// 
/// Returns true if device is connected (WiFi, Mobile Data, or Ethernet)
/// Returns false if device is offline
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();

  // Check initial connectivity status
  final initialResult = await connectivity.checkConnectivity();
  yield initialResult.contains(ConnectivityResult.mobile) ||
         initialResult.contains(ConnectivityResult.wifi) ||
         initialResult.contains(ConnectivityResult.ethernet);

  // Listen to connectivity changes
  yield* connectivity.onConnectivityChanged.map((result) {
    return result.contains(ConnectivityResult.mobile) ||
           result.contains(ConnectivityResult.wifi) ||
           result.contains(ConnectivityResult.ethernet);
  });
});

/// Provider that provides current connectivity status as a boolean
/// 
/// Returns true if connected, false if offline
/// Assumes connected while loading, disconnected on error
final isConnectedProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityProvider);

  return connectivityAsync.when(
    data: (isConnected) => isConnected,
    loading: () => true, // Assume connected while loading
    error: (_, __) => false, // Assume disconnected on error
  );
});

