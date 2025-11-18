import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../theme/app_theme.dart';
import '../../../../../core/utils/responsive.dart';
import '../models/shop_order.dart';
import '../services/shop_orders_api_service.dart';

class ShopOrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const ShopOrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<ShopOrderDetailsScreen> createState() => _ShopOrderDetailsScreenState();
}

class _ShopOrderDetailsScreenState extends State<ShopOrderDetailsScreen> with SingleTickerProviderStateMixin {
  ShopOrder? _order;
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _fetchOrderDetails();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final order = await ShopOrdersApiService.fetchShopOrderDetails(widget.orderId);
      setState(() {
        _order = order;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = AppTheme.getResponsiveTextTheme(context);
    final spacing = AppTheme.spacing(context);

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(
          _order?.orderNumber ?? 'Order Details',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: Responsive.fontSize(context, mobile: 20, tablet: 22, desktop: 24),
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryOrange,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null || _order == null
              ? _buildErrorState(textTheme, spacing)
              : _buildContent(textTheme, spacing),
      bottomNavigationBar: _order != null && _canShowActions()
          ? _buildBottomActions(textTheme, spacing)
          : null,
    );
  }

  bool _canShowActions() {
    if (_order == null) return false;
    // Only show actions for assigned and in_transit statuses
    return _order!.status == ShopOrderStatus.assigned ||
           _order!.status == ShopOrderStatus.inTransit;
  }

  Widget _buildContent(TextTheme textTheme, ResponsiveSpacing spacing) {
    final order = _order!;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Status Banner
          _buildStatusBanner(order, textTheme, spacing),

          SizedBox(height: spacing.md),

          // Business Information
          _buildSection(
            title: 'Business Information',
            icon: Icons.store,
            child: Column(
              children: [
                _buildInfoRow('Business Name', order.business.brandName, textTheme, spacing),
                if (order.business.phone != null) ...[
                  _buildDivider(spacing),
                  _buildInfoRow('Phone', order.business.phone!, textTheme, spacing),
                ],
                if (order.business.email != null) ...[
                  _buildDivider(spacing),
                  _buildInfoRow('Email', order.business.email!, textTheme, spacing),
                ],
              ],
            ),
            textTheme: textTheme,
            spacing: spacing,
          ),

          SizedBox(height: spacing.md),

          // Customer Information
          _buildSection(
            title: 'Customer Information',
            icon: Icons.person,
            child: Column(
              children: [
                _buildInfoRow('Name', order.customer.fullName, textTheme, spacing),
                _buildDivider(spacing),
                _buildInfoRow('Phone', order.customer.phone, textTheme, spacing),
                _buildDivider(spacing),
                _buildInfoRow('Address', order.customer.fullAddress, textTheme, spacing, isMultiline: true),
                if (order.deliveryInfo != null) ...[
                  if (order.deliveryInfo!.estimatedDeliveryTime != null) ...[
                    _buildDivider(spacing),
                    _buildInfoRow('Estimated Time', order.deliveryInfo!.estimatedDeliveryTime!, textTheme, spacing),
                  ],
                  if (order.deliveryInfo!.deliveryInstructions != null) ...[
                    _buildDivider(spacing),
                    _buildInfoRow('Instructions', order.deliveryInfo!.deliveryInstructions!, textTheme, spacing, isMultiline: true),
                  ],
                ],
              ],
            ),
            textTheme: textTheme,
            spacing: spacing,
          ),

          SizedBox(height: spacing.md),

          // Order Items
          _buildSection(
            title: 'Order Items (${order.items.length})',
            icon: Icons.shopping_bag,
            child: Column(
              children: order.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    if (index > 0) _buildDivider(spacing),
                    _buildOrderItem(item, textTheme, spacing),
                  ],
                );
              }).toList(),
            ),
            textTheme: textTheme,
            spacing: spacing,
          ),

          SizedBox(height: spacing.md),

          // Payment Summary
          _buildSection(
            title: 'Payment Summary',
            icon: Icons.payment,
            child: Column(
              children: [
                _buildPriceRow('Subtotal', order.subtotal, textTheme, spacing),
                if (order.discount > 0) ...[
                  _buildDivider(spacing),
                  _buildPriceRow('Discount', -order.discount, textTheme, spacing, color: Colors.green),
                ],
                _buildDivider(spacing),
                _buildPriceRow('Tax', order.tax, textTheme, spacing),
                _buildDivider(spacing),
                _buildPriceRow('Delivery Fee', order.deliveryFee, textTheme, spacing),
                _buildDivider(spacing),
                _buildPriceRow('Total', order.totalAmount, textTheme, spacing, isBold: true, color: AppTheme.primaryOrange),
                _buildDivider(spacing),
                _buildInfoRow('Payment Method', order.paymentMethod?.replaceAll('_', ' ').toUpperCase() ?? 'N/A', textTheme, spacing),
                _buildDivider(spacing),
                _buildInfoRow('Payment Status', order.paymentStatus.toUpperCase(), textTheme, spacing),
              ],
            ),
            textTheme: textTheme,
            spacing: spacing,
          ),

          if (order.notes != null || order.specialInstructions != null) ...[
            SizedBox(height: spacing.md),
            _buildSection(
              title: 'Notes & Instructions',
              icon: Icons.note,
              child: Column(
                children: [
                  if (order.notes != null) ...[
                    _buildInfoRow('Notes', order.notes!, textTheme, spacing, isMultiline: true),
                  ],
                  if (order.notes != null && order.specialInstructions != null)
                    _buildDivider(spacing),
                  if (order.specialInstructions != null) ...[
                    _buildInfoRow('Special Instructions', order.specialInstructions!, textTheme, spacing, isMultiline: true),
                  ],
                ],
              ),
              textTheme: textTheme,
              spacing: spacing,
            ),
          ],

          if (order.trackingHistory.isNotEmpty) ...[
            SizedBox(height: spacing.md),
            _buildSection(
              title: 'Tracking History',
              icon: Icons.history,
              child: _buildTrackingHistory(order.trackingHistory, textTheme, spacing),
              textTheme: textTheme,
              spacing: spacing,
            ),
          ],

          SizedBox(height: spacing.xl * 2), // Space for bottom actions
        ],
      ),
    );
  }

  Widget _buildStatusBanner(ShopOrder order, TextTheme textTheme, ResponsiveSpacing spacing) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(spacing.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getStatusColor(order.status),
              _getStatusColor(order.status).withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: _getStatusColor(order.status).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(order.status),
                color: Colors.white,
                size: 56,
              ),
            ),
            SizedBox(height: spacing.md),
            Text(
              order.status.label,
              style: GoogleFonts.inter(
                fontSize: Responsive.fontSize(context, mobile: 26, tablet: 28, desktop: 30),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (order.assignedAt != null) ...[
              SizedBox(height: spacing.xs),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.md,
                  vertical: spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: Colors.white),
                    SizedBox(width: spacing.xs / 2),
                    Text(
                      'Assigned: ${_formatDate(order.assignedAt!)}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
    required TextTheme textTheme,
    required ResponsiveSpacing spacing,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: spacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(spacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryOrange.withOpacity(0.08),
                    AppTheme.primaryOrange.withOpacity(0.02),
                  ],
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
                      color: AppTheme.primaryOrange,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryOrange.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  SizedBox(width: spacing.sm),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: Responsive.fontSize(context, mobile: 16, tablet: 17, desktop: 18),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(spacing.md),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    TextTheme textTheme,
    ResponsiveSpacing spacing, {
    bool isMultiline = false,
  }) {
    return Container(
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
                color: AppTheme.mediumGray,
                fontWeight: FontWeight.w500,
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
                color: AppTheme.darkGray,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount,
    TextTheme textTheme,
    ResponsiveSpacing spacing, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: color ?? AppTheme.mediumGray,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          'EGP ${amount.toStringAsFixed(2)}',
          style: textTheme.bodyMedium?.copyWith(
            color: color ?? AppTheme.darkGray,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(ShopOrderItem item, TextTheme textTheme, ResponsiveSpacing spacing) {
    return Container(
      padding: EdgeInsets.all(spacing.sm),
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightGray.withOpacity(0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.product.imageUrl.isNotEmpty
                  ? Image.network(
                      item.product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.primaryOrange.withOpacity(0.1),
                          child: const Icon(
                            Icons.shopping_bag_rounded,
                            color: AppTheme.primaryOrange,
                            size: 32,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppTheme.primaryOrange.withOpacity(0.1),
                      child: const Icon(
                        Icons.shopping_bag_rounded,
                        color: AppTheme.primaryOrange,
                        size: 32,
                      ),
                    ),
            ),
          ),

          SizedBox(width: spacing.sm),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkGray,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.product.category != null) ...[
                  SizedBox(height: spacing.xs / 2),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.product.category!,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.purple[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                if (item.product.description != null && item.product.description!.isNotEmpty) ...[
                  SizedBox(height: spacing.xs / 2),
                  Text(
                    item.product.description!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.mediumGray,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (item.product.brand != null) ...[
                  SizedBox(height: spacing.xs / 2),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.product.brand!,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                if (item.product.sku != null && item.product.sku!.isNotEmpty) ...[
                  SizedBox(height: spacing.xs / 2),
                  Text(
                    'SKU: ${item.product.sku}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.mediumGray,
                    ),
                  ),
                ],
                if (item.notes != null) ...[
                  SizedBox(height: spacing.xs / 2),
                  Container(
                    padding: EdgeInsets.all(spacing.xs),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.note, size: 12, color: Colors.amber[700]),
                        SizedBox(width: spacing.xs / 2),
                        Expanded(
                          child: Text(
                            item.notes!,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.amber[900],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: spacing.sm),
                Container(
                  padding: EdgeInsets.all(spacing.sm),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryOrange.withOpacity(0.1),
                        AppTheme.primaryOrange.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Qty: ${item.quantity} × EGP ${item.price.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.mediumGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: spacing.xs / 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.darkGray,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'EGP ${item.totalPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingHistory(List<TrackingHistory> history, TextTheme textTheme, ResponsiveSpacing spacing) {
    return Column(
      children: history.asMap().entries.map((entry) {
        final index = entry.key;
        final track = entry.value;
        final isLast = index == history.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: AppTheme.lightGray,
                  ),
              ],
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.status.toUpperCase(),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  SizedBox(height: spacing.xs / 2),
                  Text(
                    _formatDate(track.updatedAt),
                    style: textTheme.bodySmall?.copyWith(
                      color: AppTheme.mediumGray,
                    ),
                  ),
                  if (track.location != null) ...[
                    SizedBox(height: spacing.xs / 2),
                    Text(
                      'Location: ${track.location}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppTheme.mediumGray,
                      ),
                    ),
                  ],
                  if (track.notes != null) ...[
                    SizedBox(height: spacing.xs / 2),
                    Text(
                      track.notes!,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppTheme.mediumGray,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (!isLast) SizedBox(height: spacing.sm),
                ],
              ),
            ),
          ],
        );
      }).toList(),
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

  Widget _buildBottomActions(TextTheme textTheme, ResponsiveSpacing spacing) {
    final order = _order!;

    return Container(
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (order.status == ShopOrderStatus.assigned)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _showMarkAsInTransitDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: AppTheme.primaryOrange.withOpacity(0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_shipping_rounded, size: 24),
                      SizedBox(width: spacing.sm),
                      Text(
                        'Mark as In Transit',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (order.status == ShopOrderStatus.inTransit) ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () => _showMarkAsReturnedDialog(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[600],
                          side: BorderSide(color: Colors.red[600]!, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.keyboard_return_rounded, size: 20),
                            const SizedBox(height: 2),
                            Text(
                              'Return',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _showMarkAsDeliveredDialog(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 22),
                            SizedBox(width: spacing.sm),
                            Text(
                              'Mark as Delivered',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showMarkAsInTransitDialog() async {
    final locationController = TextEditingController();
    final notesController = TextEditingController();
    final spacing = AppTheme.spacing(context);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    color: AppTheme.primaryOrange,
                    size: 48,
                  ),
                ),
                SizedBox(height: spacing.md),
                Text(
                  'Mark as In Transit',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGray,
                  ),
                ),
                SizedBox(height: spacing.sm),
                Text(
                  'Update order status to in transit?',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.mediumGray,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.lg),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Current Location (Optional)',
                    labelStyle: GoogleFonts.inter(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.location_on_rounded, color: AppTheme.primaryOrange),
                    filled: true,
                    fillColor: AppTheme.lightGray.withOpacity(0.3),
                  ),
                ),
                SizedBox(height: spacing.sm),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes (Optional)',
                    labelStyle: GoogleFonts.inter(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.note_rounded, color: AppTheme.primaryOrange),
                    filled: true,
                    fillColor: AppTheme.lightGray.withOpacity(0.3),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: spacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: spacing.md),
                          side: const BorderSide(color: AppTheme.mediumGray),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.mediumGray,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: spacing.sm),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: spacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Confirm',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true) return;

    await _updateOrderStatus(
      'in_transit',
      location: locationController.text.trim().isNotEmpty ? locationController.text.trim() : null,
      notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
    );
  }

  Future<void> _showMarkAsDeliveredDialog() async {
    final locationController = TextEditingController();
    final notesController = TextEditingController();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green),
              SizedBox(width: 8),
              Text('Mark as Delivered'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Confirm order delivery?'),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Location (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
            ],
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
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _updateOrderStatus(
      'delivered',
      location: locationController.text.trim().isNotEmpty ? locationController.text.trim() : null,
      notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
    );
  }

  Future<void> _showMarkAsReturnedDialog() async {
    final locationController = TextEditingController();
    final notesController = TextEditingController();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.keyboard_return, color: Colors.red),
              SizedBox(width: 8),
              Text('Mark as Returned'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Mark this order as returned?'),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Return Location (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Return Reason',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
            ],
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
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _updateOrderStatus(
      'returned',
      location: locationController.text.trim().isNotEmpty ? locationController.text.trim() : null,
      notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
    );
  }

  Future<void> _updateOrderStatus(String status, {String? location, String? notes}) async {
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
              Text('Updating status...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }

    try {
      final response = await ShopOrdersApiService.updateShopOrderStatus(
        orderId: widget.orderId,
        status: status,
        location: location,
        notes: notes,
      );

      if (mounted) {
        final message = response['message'] as String? ?? 'Status updated successfully';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh order details
        await _fetchOrderDetails();

        // Return to previous screen with refresh flag
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildErrorState(TextTheme textTheme, ResponsiveSpacing spacing) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 80,
                  color: Colors.red[400],
                ),
              ),
            ),
            SizedBox(height: spacing.xl),
            Text(
              'Unable to Load Order',
              style: GoogleFonts.inter(
                fontSize: Responsive.fontSize(context, mobile: 24, tablet: 26, desktop: 28),
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.sm),
            Text(
              'We couldn\'t retrieve the order details',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppTheme.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.md),
            Container(
              padding: EdgeInsets.all(spacing.md),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Text(
                _errorMessage ?? 'Unknown error occurred',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: spacing.xl),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _fetchOrderDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh_rounded, size: 24),
                    SizedBox(width: spacing.sm),
                    Text(
                      'Try Again',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(ShopOrderStatus status) {
    switch (status) {
      case ShopOrderStatus.pending:
        return Icons.schedule_outlined;
      case ShopOrderStatus.confirmed:
        return Icons.verified_outlined;
      case ShopOrderStatus.assigned:
        return Icons.assignment_outlined;
      case ShopOrderStatus.inTransit:
        return Icons.local_shipping_outlined;
      case ShopOrderStatus.delivered:
        return Icons.check_circle_outline;
      case ShopOrderStatus.cancelled:
        return Icons.cancel_outlined;
      case ShopOrderStatus.returned:
        return Icons.keyboard_return;
    }
  }

  Color _getStatusColor(ShopOrderStatus status) {
    switch (status) {
      case ShopOrderStatus.pending:
        return Colors.grey;
      case ShopOrderStatus.confirmed:
        return Colors.blueGrey;
      case ShopOrderStatus.assigned:
        return Colors.blue;
      case ShopOrderStatus.inTransit:
        return AppTheme.primaryOrange;
      case ShopOrderStatus.delivered:
        return Colors.green;
      case ShopOrderStatus.cancelled:
        return Colors.red[700]!;
      case ShopOrderStatus.returned:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }
}
