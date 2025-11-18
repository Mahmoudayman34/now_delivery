import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../theme/app_theme.dart';
import '../../../../../core/utils/responsive.dart';
import '../../dashboard/providers/driver_status_provider.dart';
import '../models/shop_order.dart';
import '../providers/shop_orders_provider.dart';
import 'shop_order_details_screen.dart';

class ShopOrdersScreen extends ConsumerStatefulWidget {
  const ShopOrdersScreen({super.key});

  @override
  ConsumerState<ShopOrdersScreen> createState() => _ShopOrdersScreenState();
}

class _ShopOrdersScreenState extends ConsumerState<ShopOrdersScreen> with SingleTickerProviderStateMixin {
  String? _selectedStatus;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = AppTheme.getResponsiveTextTheme(context);
    final spacing = AppTheme.spacing(context);
    final shopOrdersAsync = ref.watch(shopOrdersProvider);
    final driverStatus = ref.watch(driverStatusProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Shop',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: Responsive.fontSize(context, mobile: 20, tablet: 22, desktop: 24),
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryOrange,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Offline Banner
          if (!driverStatus.isOnline)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(spacing.md),
              color: AppTheme.errorRed.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: AppTheme.errorRed,
                    size: 20,
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: Text(
                      'You are offline. Go online to access shop orders.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.errorRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Status Filter Chips
          _buildStatusFilter(spacing),
          
          // Orders List
          Expanded(
            child: Opacity(
              opacity: driverStatus.isOnline ? 1.0 : 0.6,
              child: IgnorePointer(
                ignoring: !driverStatus.isOnline,
                child: shopOrdersAsync.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => ref.read(shopOrdersProvider.notifier).refresh(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 200,
                        child: _buildEmptyState(textTheme, spacing),
                      ),
                    ),
                  );
                }

                // Group orders by status
                final groupedOrders = _groupOrdersByStatus(orders);

                return RefreshIndicator(
                  onRefresh: () => ref.read(shopOrdersProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      left: spacing.md,
                      right: spacing.md,
                      top: spacing.md,
                      bottom: spacing.xl * 3, // Extra padding for bottom nav bar
                    ),
                    itemCount: groupedOrders.length,
                    itemBuilder: (context, index) {
                      final entry = groupedOrders.entries.elementAt(index);
                      return _buildStatusGroup(
                        entry.key,
                        entry.value,
                        textTheme,
                        spacing,
                        driverStatus.isOnline,
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(error, textTheme, spacing),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(ResponsiveSpacing spacing) {
    final statuses = <String?, String>{
      null: 'All',
      'pending': 'Pending',
      'confirmed': 'Confirmed',
      'assigned': 'Assigned',
      'in_transit': 'In Transit',
      'delivered': 'Delivered',
      'cancelled': 'Cancelled',
      'returned': 'Returned',
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: spacing.sm),
            child: Text(
              'Filter by Status',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: statuses.entries.map((entry) {
                final isSelected = _selectedStatus == entry.key;
                return Padding(
                  padding: EdgeInsets.only(right: spacing.sm),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedStatus = isSelected ? null : entry.key;
                          });
                          ref.read(shopOrdersProvider.notifier).fetchOrders(
                            status: _selectedStatus,
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.md,
                            vertical: spacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppTheme.primaryOrange 
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected 
                                  ? AppTheme.primaryOrange 
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            entry.value,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? Colors.white : AppTheme.darkGray,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Map<ShopOrderStatus, List<ShopOrder>> _groupOrdersByStatus(List<ShopOrder> orders) {
    final grouped = <ShopOrderStatus, List<ShopOrder>>{};
    
    for (final order in orders) {
      if (!grouped.containsKey(order.status)) {
        grouped[order.status] = [];
      }
      grouped[order.status]!.add(order);
    }

    // Sort by priority: pending > confirmed > assigned > in_transit > delivered > cancelled > returned
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) {
        const priority = {
          ShopOrderStatus.pending: 1,
          ShopOrderStatus.confirmed: 2,
          ShopOrderStatus.assigned: 3,
          ShopOrderStatus.inTransit: 4,
          ShopOrderStatus.delivered: 5,
          ShopOrderStatus.cancelled: 6,
          ShopOrderStatus.returned: 7,
        };
        return (priority[a.key] ?? 99).compareTo(priority[b.key] ?? 99);
      });

    return Map.fromEntries(sortedEntries);
  }

  Widget _buildStatusGroup(
    ShopOrderStatus status,
    List<ShopOrder> orders,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
    bool isOnline,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: spacing.md),
          padding: EdgeInsets.all(spacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getStatusColor(status).withOpacity(0.15),
                _getStatusColor(status).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getStatusColor(status).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor(status).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getStatusIcon(status),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  status.label,
                  style: GoogleFonts.inter(
                    fontSize: Responsive.fontSize(context, mobile: 16, tablet: 17, desktop: 18),
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(status),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm + 2,
                  vertical: spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${orders.length}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...orders.map((order) => _buildOrderCard(order, textTheme, spacing, isOnline)),
        SizedBox(height: spacing.lg),
      ],
    );
  }

  Widget _buildOrderCard(
    ShopOrder order,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
    bool isOnline,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: spacing.md),
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
      child: Opacity(
        opacity: isOnline ? 1.0 : 0.6,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isOnline ? () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShopOrderDetailsScreen(orderId: order.id),
                ),
              );
              
              if (result == true && mounted) {
                ref.read(shopOrdersProvider.notifier).refresh();
              }
            } : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Header: Order Number & Status Badge
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.orderNumber,
                              style: GoogleFonts.inter(
                                fontSize: Responsive.fontSize(context, mobile: 16, tablet: 17, desktop: 18),
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkGray,
                              ),
                            ),
                            SizedBox(height: spacing.xs / 2),
                            Text(
                              _formatDate(order.createdAt),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.mediumGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.sm + 2,
                          vertical: spacing.xs + 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getStatusColor(order.status),
                              _getStatusColor(order.status).withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _getStatusColor(order.status).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(order.status),
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: spacing.xs / 2),
                            Text(
                              order.status.label,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: spacing.md),
                    child: Divider(color: AppTheme.lightGray.withOpacity(0.5), height: 1),
                  ),
                  
                  // Business & Customer Section
                  Row(
                    children: [
                      // Business Icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.store_rounded,
                          size: 24,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                      SizedBox(width: spacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.business.brandName,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.darkGray,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: spacing.xs / 2),
                            Row(
                              children: [
                                Icon(Icons.person_outline, size: 14, color: AppTheme.mediumGray),
                                SizedBox(width: spacing.xs / 2),
                                Expanded(
                                  child: Text(
                                    order.customer.fullName,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppTheme.mediumGray,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: spacing.sm),
                  
                  // Location
                  Container(
                    padding: EdgeInsets.all(spacing.sm),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: AppTheme.primaryOrange,
                        ),
                        SizedBox(width: spacing.xs),
                        Expanded(
                          child: Text(
                            '${order.customer.city}, ${order.customer.governorate}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.darkGray,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: spacing.md),
                  
                  // Bottom Info: Items, Payment & Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Items Count
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.sm,
                          vertical: spacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shopping_bag_rounded,
                              size: 14,
                              color: Colors.blue[700],
                            ),
                            SizedBox(width: spacing.xs / 2),
                            Text(
                              '${order.itemsCount} item${order.itemsCount != 1 ? 's' : ''}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Payment Method
                      if (order.paymentMethod != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.sm,
                            vertical: spacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.payment_rounded,
                                size: 14,
                                color: Colors.purple[700],
                              ),
                              SizedBox(width: spacing.xs / 2),
                              Text(
                                order.paymentMethod!.replaceAll('_', ' ').toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.purple[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Total Amount
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.sm + 2,
                          vertical: spacing.xs + 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryOrange,
                              AppTheme.darkOrange,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryOrange.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'EGP ${order.totalAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(TextTheme textTheme, ResponsiveSpacing spacing) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 64,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                ),
                SizedBox(height: spacing.lg),
                Text(
                  'No Shop Orders Yet',
                  style: GoogleFonts.inter(
                    fontSize: Responsive.fontSize(context, mobile: 22, tablet: 24, desktop: 26),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGray,
                  ),
                ),
                SizedBox(height: spacing.sm),
                Text(
                  'Shop orders will appear here when\nthey are assigned to you',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.mediumGray,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.lg),
                Container(
                  padding: EdgeInsets.all(spacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildEmptyStateTip(
                        Icons.notifications_active_outlined,
                        'Stay Ready',
                        'Keep your notifications enabled',
                        spacing,
                      ),
                      SizedBox(height: spacing.sm),
                      _buildEmptyStateTip(
                        Icons.check_circle_outline,
                        'Quick Response',
                        'Accept orders as soon as they arrive',
                        spacing,
                      ),
                      SizedBox(height: spacing.sm),
                      _buildEmptyStateTip(
                        Icons.local_shipping_outlined,
                        'Fast Delivery',
                        'Complete deliveries efficiently',
                        spacing,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateTip(IconData icon, String title, String subtitle, ResponsiveSpacing spacing) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppTheme.primaryOrange),
        ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkGray,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.mediumGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(Object error, TextTheme textTheme, ResponsiveSpacing spacing) {
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
              'Oops! Something Went Wrong',
              style: GoogleFonts.inter(
                fontSize: Responsive.fontSize(context, mobile: 22, tablet: 24, desktop: 26),
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.sm),
            Text(
              'We couldn\'t load your shop orders',
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
                error.toString(),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: spacing.xl),
            ElevatedButton.icon(
              onPressed: () => ref.read(shopOrdersProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded, size: 20),
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
                elevation: 0,
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
