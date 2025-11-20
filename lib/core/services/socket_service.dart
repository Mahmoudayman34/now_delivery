import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tracking_api_config.dart';

// Provider for socket service
final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});

class SocketService {
  IO.Socket? _socket;
  
  // Callbacks
  Function()? onConnected;
  Function()? onDisconnected;
  Function(String)? onError;
  
  // Initialize socket connection
  Future<void> initializeSocket() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        print('⚠️ No token found, cannot connect to socket');
        return;
      }
      
      _socket = IO.io(
        TrackingApiConfig.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .setAuth({'token': token})
            .build(),
      );
      
      // Connection events
      _socket!.onConnect((_) {
        print('✅ Socket connected');
        onConnected?.call();
      });
      
      _socket!.onDisconnect((_) {
        print('❌ Socket disconnected');
        onDisconnected?.call();
      });
      
      _socket!.onConnectError((error) {
        print('⚠️ Socket connection error: $error');
        onError?.call(error.toString());
      });
      
      _socket!.onError((error) {
        print('⚠️ Socket error: $error');
        onError?.call(error.toString());
      });
      
    } catch (e) {
      print('❌ Error initializing socket: $e');
    }
  }
  
  // Send location update via socket
  void sendLocationUpdate({
    required double latitude,
    required double longitude,
  }) {
    if (_socket?.connected ?? false) {
      _socket!.emit('location_update', {
        'latitude': latitude,
        'longitude': longitude,
      });
      print('📡 Location update sent via socket: $latitude, $longitude');
    } else {
      print('⚠️ Socket not connected, cannot send location update');
    }
  }
  
  // Send status update
  void sendStatusUpdate({required bool isAvailable}) {
    if (_socket?.connected ?? false) {
      _socket!.emit('status_update', {
        'isAvailable': isAvailable,
      });
      print('📡 Status update sent: $isAvailable');
    }
  }
  
  // Reconnect socket with new token
  Future<void> reconnect() async {
    disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    await initializeSocket();
  }
  
  // Disconnect socket
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    print('🔌 Socket disconnected and disposed');
  }
  
  // Check if socket is connected
  bool get isConnected => _socket?.connected ?? false;
  
  // Get socket instance for custom events
  IO.Socket? get socket => _socket;
}


