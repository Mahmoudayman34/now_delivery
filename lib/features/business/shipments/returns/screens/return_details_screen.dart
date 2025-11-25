import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../theme/app_theme.dart';
import '../../orders/models/order.dart';
import '../services/returns_api_service.dart';

class ReturnDetailsScreen extends StatefulWidget {
  final String orderNumber;

  const ReturnDetailsScreen({
    super.key,
    required this.orderNumber,
  });

  @override
  State<ReturnDetailsScreen> createState() => _ReturnDetailsScreenState();
}

class _ReturnDetailsScreenState extends State<ReturnDetailsScreen> {
  Map<String, dynamic>? _returnDetails;
  bool _isLoading = true;
  String? _errorMessage;
  final List<Order> _scannedOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchReturnDetails();
  }

  Future<void> _fetchReturnDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final details = await ReturnsApiService.fetchReturnDetails(widget.orderNumber);
      setState(() {
        _returnDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppTheme.spacing(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Return #${widget.orderNumber}',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryOrange,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
              ),
            )
          : _errorMessage != null || _returnDetails == null
              ? _buildErrorState(spacing)
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: spacing.md),
                      _buildReturnContent(spacing),
                    ],
                  ),
                ),
    );
  }

  Widget _buildReturnContent(ResponsiveSpacing spacing) {
    final order = _returnDetails!['order'] as Map<String, dynamic>;

    final orderCustomer = order['orderCustomer'] as Map<String, dynamic>? ?? {};
    final orderShipping = order['orderShipping'] as Map<String, dynamic>? ?? {};
    final orderStatus = order['orderStatus']?.toString() ?? '';

    return Column(
      children: [
        // Return Information
          _buildSection(
            title: 'Return Information',
            icon: Icons.info_outline,
            child: Column(
              children: [
                _buildInfoRow('Order Number', order['orderNumber']?.toString() ?? 'N/A', spacing),
                _buildDivider(spacing),
                _buildInfoRow('Status', _formatStatus(orderStatus), spacing),
                _buildDivider(spacing),
                _buildInfoRow('Return Reason', orderShipping['returnReason']?.toString() ?? 'N/A', spacing),
                if (orderShipping['returnNotes'] != null) ...[
                  _buildDivider(spacing),
                  _buildInfoRow('Return Notes', orderShipping['returnNotes'].toString(), spacing, isMultiline: true),
                ],
                _buildDivider(spacing),
                _buildInfoRow('Return Type', orderShipping['isPartialReturn'] == true ? 'Partial Return' : 'Full Return', spacing),
                _buildDivider(spacing),
                _buildInfoRow('Order Date', _formatDate(order['orderDate']), spacing),
              ],
            ),
            spacing: spacing,
          ),

          SizedBox(height: spacing.md),

          // Customer Information
          _buildSection(
            title: 'Customer Information',
            icon: Icons.person,
            child: Column(
              children: [
                _buildInfoRow('Name', orderCustomer['fullName']?.toString() ?? 'N/A', spacing),
                _buildDivider(spacing),
                _buildInfoRow('Phone', orderCustomer['phoneNumber']?.toString() ?? 'N/A', spacing),
                _buildDivider(spacing),
                _buildInfoRow('Address', orderCustomer['address']?.toString() ?? 'N/A', spacing, isMultiline: true),
                _buildDivider(spacing),
                _buildInfoRow('Zone', orderCustomer['zone']?.toString() ?? 'N/A', spacing),
                _buildDivider(spacing),
                _buildInfoRow('Government', orderCustomer['government']?.toString() ?? 'N/A', spacing),
              ],
            ),
            spacing: spacing,
          ),

          SizedBox(height: spacing.md),

          // Shipping Information
          _buildSection(
            title: 'Shipping Information',
            icon: Icons.local_shipping,
            child: Column(
              children: [
                _buildInfoRow('Product Description', orderShipping['productDescription']?.toString() ?? 'N/A', spacing, isMultiline: true),
                _buildDivider(spacing),
                _buildInfoRow('Number of Items', orderShipping['numberOfItems']?.toString() ?? '0', spacing),
                _buildDivider(spacing),
                _buildInfoRow('Order Type', orderShipping['orderType']?.toString() ?? 'N/A', spacing),
                _buildDivider(spacing),
                _buildInfoRow('Express Shipping', orderShipping['isExpressShipping'] == true ? 'Yes' : 'No', spacing),
                if (orderShipping['returnValue'] != null) ...[
                  _buildDivider(spacing),
                  _buildInfoRow('Return Value', 'EGP ${orderShipping['returnValue']}', spacing),
                ],
                if (orderShipping['refundAmount'] != null) ...[
                  _buildDivider(spacing),
                  _buildInfoRow('Refund Amount', 'EGP ${orderShipping['refundAmount']}', spacing),
                ],
              ],
            ),
            spacing: spacing,
          ),

          SizedBox(height: spacing.md),

          // Scanner Section - Only show when status is returnAssigned
          if (orderStatus == 'returnAssigned') ...[
            _buildSection(
              title: 'Scan Return Items',
              icon: Icons.qr_code_scanner,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Scanner Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _showScannerDialog,
                      icon: const Icon(Icons.qr_code_scanner, size: 20),
                      label: Text(
                        'Scan Item Barcode',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),

                  if (_scannedOrders.isNotEmpty) ...[
                    SizedBox(height: spacing.md),
                    Text(
                      'Scanned Items (${_scannedOrders.length})',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.darkGray,
                      ),
                    ),
                    SizedBox(height: spacing.sm),
                    
                    // List of scanned items
                    ..._scannedOrders.map((order) => _buildScannedOrderCard(order, spacing)),
                  ],
                ],
              ),
              spacing: spacing,
            ),
            SizedBox(height: spacing.md),
          ],

          // Original Order Card - Only show when status is returnPickedUp
          if (orderStatus == 'returnPickedUp' && orderShipping['originalOrderNumber'] != null) ...[
            _buildOriginalOrderCard(
              orderShipping['originalOrderNumber'].toString(),
              spacing,
            ),
            SizedBox(height: spacing.md),
          ],

          // Complete Return Button - Only show when status is returnToBusiness
          if (orderStatus == 'returnToBusiness') ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.md),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => _showCompleteReturnDialog(context),
                  icon: const Icon(Icons.check_circle, size: 20),
                  label: Text(
                    'Complete Return',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ),
            SizedBox(height: spacing.md),
          ],

          SizedBox(height: spacing.xl),
        ],
      );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
    required ResponsiveSpacing spacing,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: spacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryOrange.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header with Gradient
          Container(
            padding: EdgeInsets.all(spacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryOrange.withOpacity(0.15),
                  AppTheme.primaryOrange.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryOrange,
                        AppTheme.primaryOrange.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryOrange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: spacing.md),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryOrange,
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          Padding(
            padding: EdgeInsets.all(spacing.md),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    ResponsiveSpacing spacing, {
    bool isMultiline = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.mediumGray,
              ),
            ),
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ResponsiveSpacing spacing) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: const Divider(
        color: AppTheme.lightGray,
        height: 1,
      ),
    );
  }

  Widget _buildErrorState(ResponsiveSpacing spacing) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withOpacity(0.2),
                    Colors.red.withOpacity(0.05),
                  ],
                ),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),
            ),
            SizedBox(height: spacing.xl),
            Text(
              'Failed to Load Details',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkGray,
              ),
            ),
            SizedBox(height: spacing.md),
            Text(
              _errorMessage ?? 'An error occurred',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.xl),
            ElevatedButton.icon(
              onPressed: _fetchReturnDetails,
              icon: const Icon(Icons.refresh),
              label: Text(
                'Try Again',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.xl,
                  vertical: spacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(date.toString());
      return DateFormat('MMM d, yyyy • h:mm a').format(dateTime);
    } catch (e) {
      return date.toString();
    }
  }

  String _formatStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Widget _buildScannedOrderCard(Order order, ResponsiveSpacing spacing) {
    return Container(
      margin: EdgeInsets.only(bottom: spacing.sm),
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryOrange.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryOrange, AppTheme.primaryOrange.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryOrange.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.orderNumber,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkGray,
                  ),
                ),
                SizedBox(height: spacing.xs / 2),
                Text(
                  order.customerName,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.mediumGray,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () => _removeScannedOrder(order),
          ),
        ],
      ),
    );
  }

  Widget _buildOriginalOrderCard(String orderNumber, ResponsiveSpacing spacing) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: spacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryOrange.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header with Gradient
          Container(
            padding: EdgeInsets.all(spacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryOrange.withOpacity(0.15),
                  AppTheme.primaryOrange.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryOrange, AppTheme.primaryOrange.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryOrange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: spacing.sm),
                Text(
                  'Original Order',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkGray,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(spacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryOrange.withOpacity(0.12),
                    AppTheme.primaryOrange.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryOrange.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryOrange, AppTheme.primaryOrange.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryOrange.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_shipping,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #$orderNumber',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.darkGray,
                          ),
                        ),
                        SizedBox(height: spacing.xs / 2),
                        Text(
                          'This is the original delivery order',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _removeScannedOrder(Order order) {
    setState(() {
      _scannedOrders.remove(order);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${order.orderNumber}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showScannerDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return _ReturnScanScreen(
            onScan: (String barcode) {
              Navigator.of(context).pop();
              _scanBarcode(barcode);
            },
          );
        },
      ),
    );
  }

  Future<void> _scanBarcode(String barcode) async {
    print('🔍 [RETURN SCAN] Starting barcode scan process');
    print('📦 [RETURN SCAN] Scanned barcode: $barcode');
    
    // Show loading
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Scanning barcode...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
    
    // Check if already scanned
    print('🔍 [RETURN SCAN] Checking if already scanned...');
    print('📋 [RETURN SCAN] Current scanned orders count: ${_scannedOrders.length}');
    if (_scannedOrders.any((o) => o.orderNumber == barcode)) {
      print('⚠️ [RETURN SCAN] Item already scanned: $barcode');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item already scanned'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    try {
      print('🌐 [RETURN SCAN] Calling pickup-return API...');
      print('📍 [RETURN SCAN] API Endpoint: POST /courier/orders/$barcode/pickup-return');
      
      // Call the pickup-return API
      final response = await ReturnsApiService.pickupReturn(barcode);
      
      print('✅ [RETURN SCAN] API call successful');
      print('📦 [RETURN SCAN] Response keys: ${response.keys.toList()}');
      
      // Parse the order from response
      final orderData = response['order'] as Map<String, dynamic>;
      final message = response['message'] as String? ?? 'Return picked up successfully';
      final nextAction = response['nextAction'] as String? ?? '';
      
      print('📋 [RETURN SCAN] Message: $message');
      print('➡️ [RETURN SCAN] Next Action: $nextAction');
      print('📦 [RETURN SCAN] Order ID: ${orderData['_id']}');
      print('📦 [RETURN SCAN] Order Number: ${orderData['orderNumber']}');
      print('📦 [RETURN SCAN] Order Status: ${orderData['orderStatus']}');
      print('🔍 [RETURN SCAN] Order Data Keys: ${orderData.keys.toList()}');
      print('🔍 [RETURN SCAN] Business field type: ${orderData['business']?.runtimeType}');
      print('🔍 [RETURN SCAN] Business field value: ${orderData['business']}');
      
      // Parse order from API response
      print('🔄 [RETURN SCAN] Parsing order from JSON...');
      
      final scannedOrder = Order.fromJson(orderData);
      
      print('✅ [RETURN SCAN] Order parsed successfully');
      print('📦 [RETURN SCAN] Parsed Order Number: ${scannedOrder.orderNumber}');
      print('📦 [RETURN SCAN] Parsed Customer: ${scannedOrder.customerName}');
      
      setState(() {
        _scannedOrders.add(scannedOrder);
      });

      print('✅ [RETURN SCAN] Order added to scanned list');
      print('📋 [RETURN SCAN] Total scanned orders: ${_scannedOrders.length}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (nextAction.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Next: $nextAction', style: const TextStyle(fontSize: 12)),
                ],
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      print('🎉 [RETURN SCAN] Scan completed successfully!');
    } catch (e) {
      print('❌ [RETURN SCAN] Error occurred: $e');
      print('💥 [RETURN SCAN] Error type: ${e.runtimeType}');
      print('📍 [RETURN SCAN] Stack trace: ${StackTrace.current}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to scan return: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _showCompleteReturnDialog(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Complete Return',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to mark this return as completed?\n\nThis confirms that the return has been successfully delivered back to the business.',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Complete',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    // Show loading
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Completing return...'),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }

    try {
      print('✅ [RETURN] Completing return to business: ${widget.orderNumber}');
      
      // Call the complete return to business API
      final response = await ReturnsApiService.completeReturnToBusiness(widget.orderNumber);

      if (mounted) {
        final message = response['message'] as String? ?? 'Return completed successfully';
        
        print('✅ [RETURN] Return completed: $message');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Refresh the return details
        await _fetchReturnDetails();
        
        // Optionally navigate back after a short delay
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.of(context).pop(true); // Return to returns list with refresh flag
        }
      }
    } catch (e) {
      print('❌ [RETURN] Error completing return: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Failed to complete return: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}

// Full Screen Return Scan Screen
class _ReturnScanScreen extends StatefulWidget {
  final Function(String) onScan;

  const _ReturnScanScreen({
    required this.onScan,
  });

  @override
  State<_ReturnScanScreen> createState() => _ReturnScanScreenState();
}

class _ReturnScanScreenState extends State<_ReturnScanScreen> {
  MobileScannerController? _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppTheme.spacing(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Scan Item Barcode',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryOrange,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Full Screen Scanner
          MobileScanner(
            controller: _scannerController,
            onDetect: (BarcodeCapture capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null && code.isNotEmpty) {
                  widget.onScan(code);
                }
              }
            },
          ),

          // Info Banner at Bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(spacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                    Colors.black,
                  ],
                ),
              ),
              child: SafeArea(
                child: Container(
                  padding: EdgeInsets.all(spacing.md),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryOrange,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white, size: 24),
                      SizedBox(width: spacing.sm),
                      Expanded(
                        child: Text(
                          'Position the barcode within the frame',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
