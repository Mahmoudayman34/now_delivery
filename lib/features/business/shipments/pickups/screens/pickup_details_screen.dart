import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../theme/app_theme.dart';
import '../../orders/models/order.dart';
import '../models/pickup.dart';
import '../services/pickups_api_service.dart';

class PickupDetailsScreen extends StatefulWidget {
  final Pickup pickup;

  const PickupDetailsScreen({
    super.key,
    required this.pickup,
  });

  @override
  State<PickupDetailsScreen> createState() => _PickupDetailsScreenState();
}

class _PickupDetailsScreenState extends State<PickupDetailsScreen> {
  Pickup? _detailedPickup;
  bool _isLoading = true;
  String? _errorMessage;
  final List<Order> _scannedOrders = [];
  MobileScannerController? _scannerController;

  @override
  void initState() {
    super.initState();
    _fetchPickupDetails();
    _loadPickedUpOrders();
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  Future<void> _fetchPickupDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pickup = await PickupsApiService.fetchPickupDetails(widget.pickup.pickupNumber);
      setState(() {
        _detailedPickup = pickup;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPickedUpOrders() async {
    try {
      print('📦 Loading picked up orders for pickup: ${widget.pickup.pickupNumber}');
      final ordersData = await PickupsApiService.getPickedUpOrders(widget.pickup.pickupNumber);
      
      final orders = ordersData.map((orderData) => Order.fromJson(orderData)).toList();
      
      setState(() {
        _scannedOrders.clear();
        _scannedOrders.addAll(orders);
      });
      
      print('✅ Loaded ${orders.length} picked up orders');
    } catch (e) {
      print('❌ Error loading picked up orders: $e');
      // Don't show error if no orders yet, it's normal
    }
  }

  Future<void> _scanBarcode(String barcode) async {
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
    
    try {
      // Call the scan barcode API
      final response = await PickupsApiService.scanOrderBarcode(
        pickupNumber: widget.pickup.pickupNumber,
        orderNumber: barcode,
      );
      
      // Parse the orders from response
      final List<dynamic> ordersData = response['orders'] as List<dynamic>;
      if (ordersData.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No order found'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      // Get the first order from response
      final orderData = ordersData.first as Map<String, dynamic>;
      
      // Check if order already scanned
      final orderNumber = orderData['orderNumber'] as String;
      if (_scannedOrders.any((o) => o.orderNumber == orderNumber)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order already scanned'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      // Parse order from API response
      final scannedOrder = Order.fromJson(orderData);
      
      setState(() {
        _scannedOrders.add(scannedOrder);
      });

      if (mounted) {
        final message = response['message'] as String? ?? 'Order added successfully';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scanning barcode: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _removeOrder(Order order) async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Remove Order'),
            ],
          ),
          content: Text(
            'Are you sure you want to remove order #${order.orderNumber} from this pickup?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Remove'),
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
              Text('Removing order...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }

    try {
      // Call the delete API
      final response = await PickupsApiService.deleteOrderFromPickup(
        pickupNumber: widget.pickup.pickupNumber,
        orderNumber: order.orderNumber,
      );

      // Remove from local list
      setState(() {
        _scannedOrders.remove(order);
      });

      if (mounted) {
        final message = response['message'] as String? ?? 'Order removed successfully';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing order: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppTheme.spacing(context);
    final pickup = _detailedPickup ?? widget.pickup;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Pickup #${pickup.pickupNumber}',
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
          : _errorMessage != null && _detailedPickup == null
              ? _buildErrorState(spacing)
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Status Banner
                      _buildStatusBanner(pickup.status, spacing),

                      SizedBox(height: spacing.md),

                      // 1. Pickup Information Section
                      _buildSection(
                        title: 'Pickup Information',
                        icon: Icons.info_outline,
                        child: Column(
                          children: [
                            _buildInfoRow('Pickup Number', '#${pickup.pickupNumber}', spacing),
                            _buildDivider(spacing),
                            _buildInfoRow('Business Name', pickup.merchantName, spacing),
                            _buildDivider(spacing),
                            _buildInfoRow('Contact Person', pickup.merchantName, spacing),
                            _buildDivider(spacing),
                            _buildInfoRow('Contact Phone', pickup.merchantPhone, spacing),
                            _buildDivider(spacing),
                            _buildInfoRow('Pickup Date', _formatPickupDate(pickup.pickupDate), spacing),
                            _buildDivider(spacing),
                            _buildInfoRow('Pickup Address', '${pickup.merchantAddress}, ${pickup.merchantCity}', spacing, isMultiline: true),
                            _buildDivider(spacing),
                            _buildInfoRow('Nearby Location', pickup.nearbyLandmark ?? '-', spacing, isMultiline: true),
                            _buildDivider(spacing),
                            _buildInfoRow('Notes', pickup.pickupNotes?.isNotEmpty == true ? pickup.pickupNotes! : '-', spacing, isMultiline: true),
                          ],
                        ),
                        spacing: spacing,
                      ),

                      SizedBox(height: spacing.md),

                      // Pickup Summary
                      _buildPickupSummary(pickup, spacing),

                      SizedBox(height: spacing.md),

                      // 2. Pickup Orders Section with Scanner
                      _buildSection(
                        title: 'Pickup Orders',
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
                                  'Scan Order Barcode',
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
                                'Scanned Orders (${_scannedOrders.length})',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.darkGray,
                                ),
                              ),
                              SizedBox(height: spacing.sm),
                              
                              // List of scanned orders
                              ..._scannedOrders.map((order) => _buildScannedOrderCard(order, spacing)),
                            ],
                          ],
                        ),
                        spacing: spacing,
                      ),

                      SizedBox(height: spacing.md),

                      // Action Buttons (only show if status is driverAssigned)
                      if (pickup.status == PickupStatus.driverAssigned)
                        Padding(
                          padding: EdgeInsets.all(spacing.md),
                          child: Column(
                            children: [
                              // Complete Pickup Button - disabled until scanned orders match expected
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton.icon(
                                  onPressed: _scannedOrders.length >= pickup.numberOfOrders
                                      ? () => _showCompletePickupDialog(context, pickup)
                                      : null,
                                  icon: const Icon(Icons.check_circle, size: 20),
                                  label: Text(
                                    'Complete Pickup',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.grey.shade300,
                                    disabledForegroundColor: Colors.grey.shade600,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                ),
                              ),

                              SizedBox(height: spacing.sm),

                              // Business Closed Button
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showBusinessClosedDialog(context, pickup),
                                  icon: const Icon(Icons.store_mall_directory_outlined, size: 20),
                                  label: Text(
                                    'Business Closed',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                ),
                              ),

                              SizedBox(height: spacing.sm),

                              // Reject Pickup Button
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: OutlinedButton.icon(
                                  onPressed: () => _showRejectPickupDialog(context, pickup),
                                  icon: const Icon(Icons.cancel, size: 20),
                                  label: Text(
                                    'Reject Pickup',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red, width: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
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

  Widget _buildStatusBanner(
    PickupStatus status,
    ResponsiveSpacing spacing,
  ) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case PickupStatus.newPickup:
        statusColor = Colors.blue;
        statusIcon = Icons.fiber_new;
        break;
      case PickupStatus.driverAssigned:
        statusColor = Colors.indigo;
        statusIcon = Icons.local_shipping;
        break;
      case PickupStatus.pickedUp:
        statusColor = AppTheme.primaryOrange;
        statusIcon = Icons.check_box;
        break;
      case PickupStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case PickupStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.15),
            statusColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          left: BorderSide(
            color: statusColor,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(spacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor, statusColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              statusIcon,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pickup Status',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.mediumGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status.label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                SizedBox(width: spacing.sm),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkGray,
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

  Widget _buildPickupSummary(
    Pickup pickup,
    ResponsiveSpacing spacing,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: spacing.md),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryOrange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pickup Summary',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryOrange,
            ),
          ),
          SizedBox(height: spacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Number of Orders',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.mediumGray,
                ),
              ),
              Text(
                '${pickup.numberOfOrders}',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.darkGray,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Picked Up Items',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.mediumGray,
                ),
              ),
              Text(
                '${_scannedOrders.length}',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScannedOrderCard(
    Order order,
    ResponsiveSpacing spacing,
  ) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
              Icons.inventory_2,
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
                  'Order #${order.orderNumber}',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkGray,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  'Customer: ${order.customerName}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.mediumGray,
                  ),
                ),
                Text(
                  'Address: ${order.customerAddress}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.mediumGray,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing.xs),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.xs,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getStatusColor(order.status).withOpacity(0.15),
                        _getStatusColor(order.status).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _getStatusColor(order.status).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    order.statusLabel,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(order.status),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeOrder(order),
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
            tooltip: 'Remove order',
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return Colors.blue;
      case OrderStatus.inProgress:
      case OrderStatus.outForDelivery:
      case OrderStatus.headingToCustomer:
        return Colors.indigo;
      case OrderStatus.delivered:
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.canceled:
        return Colors.red;
      default:
        return Colors.grey;
    }
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
              onPressed: _fetchPickupDetails,
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

  String _formatPickupDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }

  void _showScannerDialog() {
    _scannerController = MobileScannerController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            height: 400,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Scan Order Barcode',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _scannerController?.dispose();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: MobileScanner(
                    controller: _scannerController,
                    onDetect: (BarcodeCapture capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty) {
                        final String? code = barcodes.first.rawValue;
                        if (code != null && code.isNotEmpty) {
                          _scannerController?.dispose();
                          Navigator.of(context).pop();
                          _scanBarcode(code);
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Position the barcode within the frame',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      _scannerController?.dispose();
      _scannerController = null;
    });
  }

  Future<void> _showCompletePickupDialog(BuildContext context, Pickup pickup) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Complete Pickup'),
            ],
          ),
          content: Text(
            'Are you sure you want to mark this pickup as completed?\n\nScanned Orders: ${_scannedOrders.length}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Complete'),
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
              Text('Completing pickup...'),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }

    try {
      // Call the complete pickup API
      final response = await PickupsApiService.completePickup(pickup.pickupNumber);

      if (mounted) {
        final message = response['message'] as String? ?? 'Pickup completed successfully';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
        // Return to pickups screen with refresh
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing pickup: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showBusinessClosedDialog(BuildContext context, Pickup pickup) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.store_mall_directory_outlined, color: Colors.orange),
              SizedBox(width: 8),
              Text('Business Closed'),
            ],
          ),
          content: const Text(
            'Are you sure the business is closed and pickup cannot be completed?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSnackBar(context, 'Pickup marked as business closed');
                Navigator.of(context).pop(true); // Return to pickups screen with refresh
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showRejectPickupDialog(BuildContext context, Pickup pickup) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cancel, color: Colors.red),
              SizedBox(width: 8),
              Text('Reject Pickup'),
            ],
          ),
          content: const Text(
            'Are you sure you want to reject this pickup? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSnackBar(context, 'Pickup rejected');
                Navigator.of(context).pop(true); // Return to pickups screen with refresh
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }
}
