import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../../theme/app_theme.dart';
import '../models/order.dart';
import '../services/orders_api_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Order details screen showing comprehensive order information
class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Order? _detailedOrder;
  bool _isLoading = true;
  String? _errorMessage;
  MobileScannerController? _scannerController;
  final bool _isScanning = false;
  bool _isOrderScanned = false;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detailedOrder = await OrdersApiService.fetchOrderDetails(widget.order.orderNumber);
      setState(() {
        _detailedOrder = detailedOrder;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        // Fallback to the order passed from the list
        _detailedOrder = widget.order;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppTheme.spacing(context);
    final order = _detailedOrder ?? widget.order;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Order #${order.orderNumber}',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryOrange,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading && _detailedOrder == null
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
              ),
            )
          : _errorMessage != null && _detailedOrder == null
              ? _buildErrorState(spacing)
              : SingleChildScrollView(
        child: Builder(
          builder: (context) {
            // Debug logging for status
            print('🔍 Order Details Screen - Status Check:');
            print('   - Order Number: ${order.orderNumber}');
            print('   - Status Enum: ${order.status}');
            print('   - Status Label: ${order.statusLabel}');
            print('   - Status Label (lowercase): ${order.statusLabel.toLowerCase()}');
            print('   - Is headingToCustomer? ${order.status == OrderStatus.headingToCustomer}');
            print('   - Label contains "heading to customer"? ${order.statusLabel.toLowerCase().contains('heading to customer')}');
            
            return Column(
          children: [
            // Status Banner
            _buildStatusBanner(order.status, order.statusLabel, spacing),

            SizedBox(height: spacing.md),

            // Business Location Section - Show for fast shipping with inProgress status
            if (order.isExpressShipping && order.status == OrderStatus.inProgress) ...[
              _buildBusinessLocationSection(order, spacing),
              SizedBox(height: spacing.md),
            ],

            // Fast Shipping Scan Order Section - Show for fast shipping with inProgress status
            if (order.isExpressShipping && order.status == OrderStatus.inProgress) ...[
              _buildFastShippingScanSection(order, spacing),
              SizedBox(height: spacing.md),
            ],

            // Show customer/order/payment sections only if NOT (fast shipping AND inProgress)
            if (!(order.isExpressShipping && order.status == OrderStatus.inProgress)) ...[
              // 1. Customer & Order Information Section
              _buildSection(
                title: 'Customer & Order Information',
                icon: Icons.person_outline,
                child: Column(
                  children: [
                    _buildInfoRow('Customer Name', order.customerName, spacing),
                    _buildDivider(spacing),
                    _buildInfoRow('Phone Number', order.customerPhone, spacing),
                    _buildDivider(spacing),
                    _buildInfoRow('Order Date', _formatOrderDate(order.orderDate), spacing),
                    _buildDivider(spacing),
                    _buildInfoRow('Delivery Address', '${order.customerAddress}, ${order.zone}', spacing, isMultiline: true),
                  ],
                ),
                spacing: spacing,
              ),

              SizedBox(height: spacing.md),

              // 2. Order Items Section
              _buildSection(
                title: 'Order Items',
                icon: Icons.inventory_2_outlined,
                child: Column(
                  children: [
                    _buildInfoRow('Product Description', order.productDescription, spacing),
                    _buildDivider(spacing),
                    _buildInfoRow('Number of Items', '${order.numberOfItems}', spacing),
                    if (order.specialInstructions != null && order.specialInstructions!.isNotEmpty) ...[
                      _buildDivider(spacing),
                      _buildInfoRow('Special Instructions', order.specialInstructions!, spacing, isMultiline: true),
                    ],
                  ],
                ),
                spacing: spacing,
              ),

              SizedBox(height: spacing.md),

              // 3. Payment Information Section
              _buildSection(
                title: 'Payment Information',
                icon: Icons.payments_outlined,
                child: Column(
                  children: [
                    _buildInfoRow('Payment Type', order.amountType, spacing),
                    _buildDivider(spacing),
                    _buildInfoRow('Amount to Collect', '${order.totalAmount.toStringAsFixed(2)} EGP', spacing, valueColor: Colors.green),
                    _buildDivider(spacing),
                    _buildInfoRow('Order Type', _formatOrderType(order.orderType), spacing),
                    _buildDivider(spacing),
                    _buildInfoRow(
                      'Shipping',
                      order.isExpressShipping
                          ? 'Express Shipping Priority (Requires same-day delivery and prioritization)'
                          : 'Standard Shipping',
                      spacing,
                      isMultiline: true,
                      valueColor: order.isExpressShipping ? Colors.purple : null,
                    ),
                    if (order.orderFees > 0) ...[
                      _buildDivider(spacing),
                      _buildInfoRow('Delivery Fee', '${order.orderFees.toStringAsFixed(2)} EGP', spacing),
                    ],
                  ],
                ),
                spacing: spacing,
              ),

              SizedBox(height: spacing.md),
            ],

            // Additional Information (if available)
            if (order.smartFlyerBarcode != null) ...[
              _buildSection(
                title: 'Additional Information',
                icon: Icons.info_outline,
                child: Column(
                  children: [
                    _buildInfoRow('Barcode', order.smartFlyerBarcode!, spacing),
                    _buildDivider(spacing),
                    _buildInfoRow('Merchant', order.merchantName, spacing),
                  ],
                ),
                spacing: spacing,
              ),
              SizedBox(height: spacing.md),
            ],

            // Action Buttons Section - Hide for fast shipping with inProgress status
            if (!(order.isExpressShipping && order.status == OrderStatus.inProgress)) ...[
              Padding(
                padding: EdgeInsets.all(spacing.md),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement call customer
                          _showSnackBar(context, 'Calling ${order.customerName}...');
                        },
                        icon: const Icon(Icons.phone, size: 20),
                        label: Text(
                          'Call Customer',
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
                    SizedBox(height: spacing.sm),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement navigation
                          _showSnackBar(context, 'Opening navigation to customer address...');
                        },
                        icon: const Icon(Icons.navigation_outlined, size: 20),
                        label: Text(
                          'Navigate to Address',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryOrange,
                          side: const BorderSide(color: AppTheme.primaryOrange, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    // Action buttons for "heading to customer" status
                    if (order.status == OrderStatus.headingToCustomer) ...[
                    SizedBox(height: spacing.md),
                    Divider(thickness: 1, color: AppTheme.lightGray),
                    SizedBox(height: spacing.sm),
                    
                    // Complete Order Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () => _showCompleteOrderDialog(context, order),
                        icon: const Icon(Icons.check_circle, size: 20),
                        label: Text(
                          'Complete Order',
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
                    
                    SizedBox(height: spacing.sm),
                    
                    // Customer Unavailable Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () => _showRejectDialog(context, order, isCustomerUnavailable: true),
                        icon: const Icon(Icons.person_off, size: 20),
                        label: Text(
                          'Customer Unavailable',
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
                    
                    // Reject Delivery Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: () => _showRejectDialog(context, order, isCustomerUnavailable: false),
                        icon: const Icon(Icons.cancel, size: 20),
                        label: Text(
                          'Reject Delivery',
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
                ],
              ),
            ),
            ],
          ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildStatusBanner(
    OrderStatus status,
    String statusLabel,
    ResponsiveSpacing spacing,
  ) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case OrderStatus.newOrder:
        statusColor = Colors.blue;
        statusIcon = Icons.fiber_new;
        break;
      case OrderStatus.pendingPickup:
        statusColor = Colors.orange;
        statusIcon = Icons.pending_actions;
        break;
      case OrderStatus.pickedUp:
      case OrderStatus.packed:
      case OrderStatus.shipping:
        statusColor = Colors.purple;
        statusIcon = Icons.local_shipping;
        break;
      case OrderStatus.inProgress:
      case OrderStatus.outForDelivery:
      case OrderStatus.headingToCustomer:
        statusColor = Colors.indigo;
        statusIcon = Icons.delivery_dining;
        break;
      case OrderStatus.delivered:
      case OrderStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case OrderStatus.canceled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case OrderStatus.returned:
      case OrderStatus.returnInitiated:
      case OrderStatus.returnAssigned:
      case OrderStatus.returnPickedUp:
      case OrderStatus.inReturnStock:
      case OrderStatus.returnAtWarehouse:
      case OrderStatus.returnInspection:
      case OrderStatus.returnProcessing:
      case OrderStatus.returnToBusiness:
      case OrderStatus.returnCompleted:
        statusColor = Colors.orange;
        statusIcon = Icons.assignment_return;
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
                  'Order Status',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.mediumGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusLabel,
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

  Widget _buildInfoRow(
    String label,
    String value,
    ResponsiveSpacing spacing, {
    bool isMultiline = false,
    Color? valueColor,
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
                color: valueColor ?? AppTheme.darkGray,
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

  Widget _buildClickablePhoneRow(
    String label,
    String phone,
    ResponsiveSpacing spacing,
  ) {
    final canCall = phone != 'N/A' && phone.isNotEmpty;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
            child: canCall
                ? InkWell(
                    onTap: () => _callBusiness(phone),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          phone,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryOrange,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        SizedBox(width: spacing.xs),
                        Icon(
                          Icons.phone,
                          size: 16,
                          color: AppTheme.primaryOrange,
                        ),
                      ],
                    ),
                  )
                : Text(
                    phone,
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

  void _callBusiness(String phone) async {
    final phoneUrl = Uri.parse('tel:$phone');
    try {
      if (await canLaunchUrl(phoneUrl)) {
        await launchUrl(phoneUrl);
      } else {
        if (mounted) {
          _showSnackBar(context, 'Could not open phone dialer');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(context, 'Error calling: $e');
      }
    }
  }

  String _formatOrderDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  String _formatOrderType(String orderType) {
    switch (orderType.toLowerCase()) {
      case 'delivery':
        return 'Delivery';
      case 'pickup':
        return 'Pickup';
      case 'return':
        return 'Return';
      default:
        return orderType.split('_').map((word) => 
          word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase()
        ).join(' ');
    }
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
              onPressed: _loadOrderDetails,
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

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Build Business Location Section
  Widget _buildBusinessLocationSection(Order order, ResponsiveSpacing spacing) {
    // Extract business info
    final businessName = order.businessName ?? order.merchantName;
    final businessPhone = order.businessPhone ?? 'N/A';
    final businessAddress = order.businessAddress ?? 'N/A';
    final businessCity = order.businessCity ?? 'N/A';
    final businessZone = order.businessZone ?? '';
    final nearbyLandmark = order.businessNearbyLandmark ?? 'N/A';
    
    // Format address: addressDetails, City, Zone
    // Nearby: landmark
    String fullAddress = businessAddress;
    if (businessCity != 'N/A' || businessZone.isNotEmpty) {
      final cityZone = businessZone.isNotEmpty 
          ? '$businessCity, $businessZone'
          : businessCity;
      fullAddress = '$businessAddress\n$cityZone';
    }
    if (nearbyLandmark != 'N/A') {
      fullAddress = '$fullAddress\nNearby: $nearbyLandmark';
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: spacing.md),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryOrange.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryOrange.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(spacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryOrange,
                  AppTheme.primaryOrange.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.store,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    'Business Location - Pickup Required',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Warning Banner
          Container(
            padding: EdgeInsets.all(spacing.sm),
            color: Colors.orange.shade100,
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                SizedBox(width: spacing.xs),
                Expanded(
                  child: Text(
                    'Go to business location first to pickup this fast shipping order',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Column(
              children: [
                _buildInfoRow('Business Name', businessName, spacing),
                _buildDivider(spacing),
                _buildClickablePhoneRow('Contact Phone', businessPhone, spacing),
                _buildDivider(spacing),
                _buildInfoRow('Business Address', fullAddress, spacing, isMultiline: true),
                
                SizedBox(height: spacing.md),
                
                // Navigate Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToBusiness(order),
                    icon: const Icon(Icons.navigation, size: 20),
                    label: Text(
                      'Navigate to Business',
                      style: GoogleFonts.inter(
                        fontSize: 15,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build Fast Shipping Scan Section
  Widget _buildFastShippingScanSection(Order order, ResponsiveSpacing spacing) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: spacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(spacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple,
                  Colors.purple.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    'Fast Shipping - Scan Order',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Column(
              children: [
                // Info Text
                Container(
                  padding: EdgeInsets.all(spacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.purple, size: 20),
                      SizedBox(width: spacing.sm),
                      Expanded(
                        child: Text(
                          'Scan this order to mark stages as completed and proceed to delivery',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.purple.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: spacing.md),
                
                // Order Number Display
                Container(
                  padding: EdgeInsets.all(spacing.md),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.mediumGray.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        order.orderNumber,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkGray,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: spacing.md),
                
                // Scan Button or Success Message
                if (_isOrderScanned)
                  Container(
                    padding: EdgeInsets.all(spacing.md),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 24),
                        SizedBox(width: spacing.sm),
                        Text(
                          'Order Scanned Successfully',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isScanning ? null : () => _startScanning(order),
                      icon: _isScanning
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.qr_code_scanner, size: 20),
                      label: Text(
                        _isScanning ? 'Processing...' : 'Scan & Process',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
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
    );
  }

  // Navigate to business location
  void _navigateToBusiness(Order order) async {
    if (order.businessLatitude != null && order.businessLongitude != null) {
      final lat = order.businessLatitude!;
      final lng = order.businessLongitude!;
      
      // Try Google Maps first, then fall back to other options
      final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      
      try {
        if (await canLaunchUrl(googleMapsUrl)) {
          await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            _showSnackBar(context, 'Could not open maps application');
          }
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar(context, 'Error opening maps: $e');
        }
      }
    } else {
      _showSnackBar(context, 'Business location coordinates not available');
    }
  }

  // Start scanning for fast shipping order
  void _startScanning(Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _FastShippingScanDialog(
          order: order,
          onScanSuccess: () {
            setState(() {
              _isOrderScanned = true;
            });
            _loadOrderDetails(); // Reload order details after successful scan
          },
        );
      },
    );
  }

  // Complete Order Dialog with OTP
  void _showCompleteOrderDialog(BuildContext context, Order order) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return _CompleteOrderDialog(
          order: order,
          onSubmit: (String otp) {
            // Success message is already shown in the dialog
            // This callback is just for any additional actions if needed
          },
        );
      },
    );
    
    // Only navigate back if dialog returned true (successful submission)
    if (result == true && context.mounted) {
      Navigator.of(context).pop(true); // Pop order details screen with refresh signal
    }
  }

  // Reject Dialog with Dropdown and Optional Text Field
  void _showRejectDialog(BuildContext context, Order order, {required bool isCustomerUnavailable}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return _RejectDialog(
          order: order,
          isCustomerUnavailable: isCustomerUnavailable,
          onSubmit: (String reason) {
            final action = isCustomerUnavailable ? 'marked as unavailable' : 'rejected';
            _showSnackBar(context, 'Order $action: $reason');
          },
        );
      },
    );
    
    // Only navigate back if dialog returned true (successful submission)
    if (result == true && context.mounted) {
      Navigator.of(context).pop(true); // Pop order details screen with refresh signal
    }
  }
}

// Separate StatefulWidget for Complete Order Dialog
class _CompleteOrderDialog extends StatefulWidget {
  final Order order;
  final Function(String) onSubmit;

  const _CompleteOrderDialog({
    required this.order,
    required this.onSubmit,
  });

  @override
  State<_CompleteOrderDialog> createState() => _CompleteOrderDialogState();
}

class _CompleteOrderDialogState extends State<_CompleteOrderDialog> {
  late final TextEditingController otpController;
  final formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    otpController = TextEditingController();
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    
    if (!formKey.currentState!.validate()) {
      return;
    }

    final otp = otpController.text.trim();

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Call API to complete order with OTP
      final message = await OrdersApiService.completeOrder(
        orderNumber: widget.order.orderNumber,
        otp: otp,
      );

      if (!context.mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      
      Navigator.of(context).pop(true); // Return true on success
      widget.onSubmit(otp);
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      
      if (!context.mounted) return;
      
      // Extract error message from exception
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text('Complete Order'),
        ],
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the OTP provided by the customer to complete this delivery.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'OTP Code',
                hintText: 'Enter 6-digit OTP',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
                counterText: '',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the OTP';
                }
                if (value.length != 6) {
                  return 'OTP must be 6 digits';
                }
                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                  return 'OTP must contain only numbers';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Confirm'),
        ),
      ],
    );
  }
}

// Separate StatefulWidget for Reject Dialog
class _RejectDialog extends StatefulWidget {
  final Order order;
  final bool isCustomerUnavailable;
  final Function(String) onSubmit;

  const _RejectDialog({
    required this.order,
    required this.isCustomerUnavailable,
    required this.onSubmit,
  });

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  String? selectedReason;
  late final TextEditingController otherReasonController;
  bool _isSubmitting = false;
  
  final List<String> rejectReasons = [
    'Customer not available',
    'Wrong address',
    'Package damaged',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    selectedReason = widget.isCustomerUnavailable ? 'Customer not available' : null;
    otherReasonController = TextEditingController();
  }

  @override
  void dispose() {
    otherReasonController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (_isSubmitting) return;
    
    if (selectedReason == null || selectedReason!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason')),
      );
      return;
    }
    
    if (selectedReason == 'Other' && otherReasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please specify the reason')),
      );
      return;
    }

    final reason = selectedReason == 'Other' 
        ? otherReasonController.text.trim() 
        : selectedReason!;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Call API to update order status
      final status = widget.isCustomerUnavailable ? 'Unavailable' : 'rejected';
      
      await OrdersApiService.updateOrderStatus(
        orderNumber: widget.order.orderNumber,
        status: status,
        reason: reason,
      );

      if (!context.mounted) return;
      Navigator.of(context).pop(true); // Return true on success
      widget.onSubmit(reason);
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            widget.isCustomerUnavailable ? Icons.person_off : Icons.cancel,
            color: widget.isCustomerUnavailable ? Colors.orange : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.isCustomerUnavailable ? 'Customer Unavailable' : 'Reject Delivery',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isCustomerUnavailable
                    ? 'Please select the reason why the customer is unavailable.'
                    : 'Please select the reason for rejecting this delivery.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedReason,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Reason',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info_outline),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      items: rejectReasons.map((String reason) {
                        return DropdownMenuItem<String>(
                          value: reason,
                          child: Text(
                            reason,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedReason = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a reason';
                        }
                        return null;
                      },
                    ),
                    if (selectedReason == 'Other') ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: otherReasonController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Please specify the reason',
                          hintText: 'Enter the reason here...',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (selectedReason == 'Other' && (value == null || value.trim().isEmpty)) {
                            return 'Please specify the reason';
                          }
                          return null;
                        },
                      ),
            ],
          ],
        ),
      ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : () => _handleSubmit(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isCustomerUnavailable ? Colors.orange : Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}

// Fast Shipping Scan Dialog
class _FastShippingScanDialog extends StatefulWidget {
  final Order order;
  final VoidCallback onScanSuccess;

  const _FastShippingScanDialog({
    required this.order,
    required this.onScanSuccess,
  });

  @override
  State<_FastShippingScanDialog> createState() => _FastShippingScanDialogState();
}

class _FastShippingScanDialogState extends State<_FastShippingScanDialog> {
  MobileScannerController? _scannerController;
  bool _isProcessing = false;
  
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

  Future<void> _handleBarcode(String barcode) async {
    if (_isProcessing) return;
    
    // Trim whitespace from barcode
    final trimmedBarcode = barcode.trim();
    if (trimmedBarcode.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid order number or barcode'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    
    setState(() {
      _isProcessing = true;
    });

    try {
      // Call API to scan and process the order
      // API accepts both order number and Smart Flyer barcode
      final response = await OrdersApiService.scanFastShippingOrder(
        orderNumber: trimmedBarcode,
      );

      if (mounted) {
        // Check if the response indicates success
        final success = response['success'] as bool? ?? true;
        final message = response['message'] as String? ?? 'Order scanned successfully';
        
        if (success) {
          Navigator.of(context).pop(); // Close the scanner dialog
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          
          widget.onScanSuccess();
        } else {
          // API returned success: false
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
          setState(() {
            _isProcessing = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        // Extract error message from exception
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        height: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Scan Order Barcode',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.purple, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Scan order #${widget.order.orderNumber} or Smart Flyer barcode',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Scanner
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _isProcessing
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Processing...',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.darkGray,
                              ),
                            ),
                          ],
                        ),
                      )
                    : MobileScanner(
                        controller: _scannerController,
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            if (barcode.rawValue != null) {
                              _handleBarcode(barcode.rawValue!);
                              break;
                            }
                          }
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
