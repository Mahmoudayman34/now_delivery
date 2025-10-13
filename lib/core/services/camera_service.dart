import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  static Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      
      switch (status) {
        case PermissionStatus.granted:
          return true;
        case PermissionStatus.denied:
          return false;
        case PermissionStatus.permanentlyDenied:
          // Open app settings for user to manually enable permission
          await openAppSettings();
          return false;
        case PermissionStatus.restricted:
          return false;
        default:
          return false;
      }
    } catch (e) {
      print('Error requesting camera permission: $e');
      return false;
    }
  }

  static Future<bool> checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      print('Error checking camera permission: $e');
      return false;
    }
  }

  static Future<void> showPermissionDialog({
    required Function() onPermissionGranted,
    required Function() onPermissionDenied,
  }) async {
    final hasPermission = await checkCameraPermission();
    
    if (hasPermission) {
      onPermissionGranted();
    } else {
      final granted = await requestCameraPermission();
      if (granted) {
        onPermissionGranted();
      } else {
        onPermissionDenied();
      }
    }
  }
}

class CameraPermissionWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onPermissionGranted;
  final VoidCallback? onPermissionDenied;

  const CameraPermissionWidget({
    super.key,
    required this.child,
    required this.onPermissionGranted,
    this.onPermissionDenied,
  });

  @override
  State<CameraPermissionWidget> createState() => _CameraPermissionWidgetState();
}

class _CameraPermissionWidgetState extends State<CameraPermissionWidget> {
  bool _hasPermission = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await CameraService.checkCameraPermission();
    if (mounted) {
      setState(() {
        _hasPermission = hasPermission;
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    setState(() {
      _isLoading = true;
    });

    final granted = await CameraService.requestCameraPermission();
    
    if (mounted) {
      setState(() {
        _hasPermission = granted;
        _isLoading = false;
      });

      if (granted) {
        widget.onPermissionGranted();
      } else {
        widget.onPermissionDenied?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasPermission) {
      return widget.child;
    }

    return _buildPermissionRequest();
  }

  Widget _buildPermissionRequest() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.camera_alt_rounded,
              size: 48,
              color: Colors.orange[600],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Camera Permission Required',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'To scan barcodes, we need access to your camera. This allows you to quickly add orders by scanning their barcodes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _requestPermission,
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('Allow Camera Access'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              widget.onPermissionDenied?.call();
            },
            child: Text(
              'Skip for now',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
