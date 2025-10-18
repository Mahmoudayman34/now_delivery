import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Simple test screen to verify camera and barcode scanner functionality
/// Use this to debug camera issues independently
class CameraTestScreen extends StatefulWidget {
  const CameraTestScreen({super.key});

  @override
  State<CameraTestScreen> createState() => _CameraTestScreenState();
}

class _CameraTestScreenState extends State<CameraTestScreen> {
  MobileScannerController? controller;
  bool isStarted = false;
  String? detectedCode;
  String? errorMessage;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> startCamera() async {
    setState(() {
      errorMessage = null;
      detectedCode = null;
    });

    try {
      controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
      );

      await controller!.start();

      setState(() {
        isStarted = true;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isStarted = false;
      });
    }
  }

  void stopCamera() {
    controller?.stop();
    controller?.dispose();
    controller = null;
    setState(() {
      isStarted = false;
      detectedCode = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Test'),
        actions: [
          if (isStarted)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: stopCamera,
            ),
        ],
      ),
      body: Column(
        children: [
          // Status Panel
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusRow(
                  'Camera Status',
                  isStarted ? 'Running' : 'Stopped',
                  isStarted ? Colors.green : Colors.grey,
                ),
                if (detectedCode != null) ...[
                  const SizedBox(height: 8),
                  _buildStatusRow(
                    'Detected Code',
                    detectedCode!,
                    Colors.blue,
                  ),
                ],
                if (errorMessage != null) ...[
                  const SizedBox(height: 8),
                  _buildStatusRow(
                    'Error',
                    errorMessage!,
                    Colors.red,
                  ),
                ],
              ],
            ),
          ),

          // Camera Preview
          Expanded(
            child: isStarted && controller != null
                ? MobileScanner(
                    controller: controller!,
                    onDetect: (capture) {
                      if (capture.barcodes.isNotEmpty) {
                        final barcode = capture.barcodes.first;
                        if (barcode.rawValue != null) {
                          setState(() {
                            detectedCode = barcode.rawValue;
                          });
                        }
                      }
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Camera not started',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),

          // Control Panel
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (!isStarted)
                  ElevatedButton.icon(
                    onPressed: startCamera,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Camera'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: stopCamera,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      detectedCode = null;
                      errorMessage = null;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Clear Results'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

