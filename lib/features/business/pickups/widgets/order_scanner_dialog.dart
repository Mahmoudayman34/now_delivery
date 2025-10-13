import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrderScannerDialog extends StatefulWidget {
  final Function(String) onOrderScanned;

  const OrderScannerDialog({
    super.key,
    required this.onOrderScanned,
  });

  @override
  State<OrderScannerDialog> createState() => _OrderScannerDialogState();
}

class _OrderScannerDialogState extends State<OrderScannerDialog> {
  bool _isScanning = false;
  String? _scannedCode;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 16,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.orange[700],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scan Order Barcode',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue[900],
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Position barcode in the frame',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _isScanning
                    ? _buildScannerView()
                    : _buildInitialView(),
              ),
            ),
            
            // Actions
            if (_scannedCode != null)
              Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).pop();
                          widget.onOrderScanned(_scannedCode!);
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Order'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Icon(
            Icons.qr_code_scanner_rounded,
            size: 48,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Ready to Scan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.grey[800],
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Position the barcode within the camera frame to scan automatically',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[400]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                _startScanning();
              },
              borderRadius: BorderRadius.circular(14),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Start Scanning',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScannerView() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Enhanced Camera View
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Enhanced camera simulation
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[800]!,
                        Colors.grey[900]!,
                        Colors.black,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white.withOpacity(0.7),
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Camera View\n(Simulated)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Enhanced scanning frame
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue[400]!,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        // Corner indicators
                        ...List.generate(4, (index) {
                          return Positioned(
                            top: index < 2 ? 8 : null,
                            bottom: index >= 2 ? 8 : null,
                            left: index % 2 == 0 ? 8 : null,
                            right: index % 2 == 1 ? 8 : null,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.blue[400]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          );
                        }),
                        Center(
                          child: Text(
                            'Position barcode here',
                            style: TextStyle(
                              color: Colors.blue[300],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Enhanced scanning animation
                Positioned.fill(
                  child: Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: const _ScanningAnimation(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Enhanced action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _stopScanning,
                  icon: const Icon(Icons.stop_rounded),
                  label: const Text('Stop'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.orange[200]!),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange[400]!, Colors.orange[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _simulateScan,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.qr_code_scanner_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Simulate Scan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_scannedCode != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green[600],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Barcode Scanned',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _scannedCode!,
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _startScanning() async {
    // For now, simulate camera permission check
    // In a real app, you would check camera permission here
    
    setState(() {
      _isScanning = true;
      _scannedCode = null;
    });
    
    // Show a simulated permission message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Camera permission granted - Scanning ready'),
          backgroundColor: Colors.green[600],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
      _scannedCode = null;
    });
  }

  void _simulateScan() {
    // Simulate scanning a barcode
    final mockCodes = ['ORD123', 'ORD456', 'ORD789', 'ORD101', 'ORD202'];
    final randomCode = mockCodes[DateTime.now().millisecond % mockCodes.length];
    
    // Add haptic feedback
    HapticFeedback.lightImpact();
    
    setState(() {
      _scannedCode = randomCode;
    });
    
    // Auto-close after a short delay if user doesn't interact
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _scannedCode != null) {
        Navigator.of(context).pop();
        widget.onOrderScanned(_scannedCode!);
      }
    });
  }
}

class _ScanningAnimation extends StatefulWidget {
  const _ScanningAnimation();

  @override
  State<_ScanningAnimation> createState() => _ScanningAnimationState();
}

class _ScanningAnimationState extends State<_ScanningAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ScanLinePainter(_animation.value),
          size: const Size(200, 200),
        );
      },
    );
  }
}

class _ScanLinePainter extends CustomPainter {
  final double animationValue;

  _ScanLinePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0;

    final y = size.height * animationValue;
    canvas.drawLine(
      Offset(10, y),
      Offset(size.width - 10, y),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
