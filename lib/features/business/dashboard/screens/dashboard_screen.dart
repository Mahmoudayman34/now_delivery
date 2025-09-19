import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/driver_status_provider.dart';
import '../../orders/providers/orders_provider.dart';
import '../../orders/models/order.dart';
import '../widgets/active_order_card.dart';
import '../widgets/order_list_item.dart';
import '../widgets/filter_chips.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final driverStatus = ref.watch(driverStatusProvider);
    final activeOrders = ref.watch(activeOrdersProvider);
    final filteredOrders = ref.watch(filteredOrdersProvider);
    final ordersState = ref.watch(ordersProvider);
    final textTheme = AppTheme.getResponsiveTextTheme(context);
    final spacing = AppTheme.spacing(context);

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(ordersProvider.notifier).refreshOrders(),
          child: Responsive.builder(
            context: context,
            mobile: _buildMobileLayout(
              context, user, driverStatus, activeOrders, filteredOrders, 
              ordersState, textTheme, spacing, ref
            ),
            tablet: context.isLandscape
                ? _buildTabletLandscapeLayout(
                    context, user, driverStatus, activeOrders, filteredOrders,
                    ordersState, textTheme, spacing, ref
                  )
                : _buildMobileLayout(
                    context, user, driverStatus, activeOrders, filteredOrders,
                    ordersState, textTheme, spacing, ref
                  ),
            desktop: _buildDesktopLayout(
              context, user, driverStatus, activeOrders, filteredOrders,
              ordersState, textTheme, spacing, ref
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    dynamic user,
    DriverStatus driverStatus,
    List<Order> activeOrders,
    List<Order> filteredOrders,
    dynamic ordersState,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
    WidgetRef ref,
  ) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildHeader(context, user, driverStatus, ref, textTheme, spacing),
            ),
          ),
        ),

        // Active Orders
        if (activeOrders.isNotEmpty)
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.md),
                  child: ActiveOrderCard(order: activeOrders.first),
                ),
              ),
            ),
          ),

        // Orders List Header
        SliverToBoxAdapter(
          child: _buildOrdersListHeader(
            context, filteredOrders, textTheme, spacing
          ),
        ),

        // Orders List
        _buildOrdersList(
          context, driverStatus, filteredOrders, ordersState, spacing
        ),
      ],
    );
  }

  Widget _buildTabletLandscapeLayout(
    BuildContext context,
    dynamic user,
    DriverStatus driverStatus,
    List<Order> activeOrders,
    List<Order> filteredOrders,
    dynamic ordersState,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
    WidgetRef ref,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Panel - Header and Active Orders
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(spacing.md),
            child: Column(
              children: [
                _buildHeader(context, user, driverStatus, ref, textTheme, spacing),
                if (activeOrders.isNotEmpty) ...[
                  SizedBox(height: spacing.lg),
                  ActiveOrderCard(order: activeOrders.first),
                ],
              ],
            ),
          ),
        ),
        
        // Right Panel - Orders List
        Expanded(
          flex: 2,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildOrdersListHeader(
                  context, filteredOrders, textTheme, spacing
                ),
              ),
              _buildOrdersList(
                context, driverStatus, filteredOrders, ordersState, spacing
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    dynamic user,
    DriverStatus driverStatus,
    List<Order> activeOrders,
    List<Order> filteredOrders,
    dynamic ordersState,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
    WidgetRef ref,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Panel - Header and Active Orders
        SizedBox(
          width: context.responsive<double>(
            mobile: 300,
            desktop: 350,
            largeDesktop: 400,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              children: [
                _buildHeader(context, user, driverStatus, ref, textTheme, spacing),
                if (activeOrders.isNotEmpty) ...[
                  SizedBox(height: spacing.xl),
                  ActiveOrderCard(order: activeOrders.first),
                ],
              ],
            ),
          ),
        ),
        
        // Main Panel - Orders Grid
        Expanded(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: context.responsive<double>(
                mobile: double.infinity,
                desktop: 1000,
                largeDesktop: 1200,
              ),
            ),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildOrdersListHeader(
                    context, filteredOrders, textTheme, spacing
                  ),
                ),
                _buildOrdersGrid(
                  context, driverStatus, filteredOrders, ordersState, spacing
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersListHeader(
    BuildContext context,
    List<Order> filteredOrders,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: EdgeInsets.all(spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Orders',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  Text(
                    '${filteredOrders.length} orders',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mediumGray,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.md),
              const FilterChips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList(
    BuildContext context,
    DriverStatus driverStatus,
    List<Order> filteredOrders,
    dynamic ordersState,
    ResponsiveSpacing spacing,
  ) {
    if (ordersState.isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(
              color: AppTheme.primaryOrange,
            ),
          ),
        ),
      );
    } else if (!driverStatus.isOnline) {
      return SliverToBoxAdapter(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildOfflineState(),
        ),
      );
    } else if (filteredOrders.isEmpty) {
      return SliverToBoxAdapter(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildEmptyState(),
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: spacing.md,
                    right: spacing.md,
                    bottom: index == filteredOrders.length - 1 ? 100 : spacing.sm,
                  ),
                  child: OrderListItem(
                    order: filteredOrders[index],
                    onTap: driverStatus.isOnline 
                        ? () => _showOrderDetails(context, filteredOrders[index])
                        : null,
                    isLocked: !driverStatus.isOnline,
                  ),
                ),
              ),
            );
          },
          childCount: filteredOrders.length,
        ),
      );
    }
  }

  Widget _buildOrdersGrid(
    BuildContext context,
    DriverStatus driverStatus,
    List<Order> filteredOrders,
    dynamic ordersState,
    ResponsiveSpacing spacing,
  ) {
    if (ordersState.isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(
              color: AppTheme.primaryOrange,
            ),
          ),
        ),
      );
    } else if (!driverStatus.isOnline) {
      return SliverToBoxAdapter(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildOfflineState(),
        ),
      );
    } else if (filteredOrders.isEmpty) {
      return SliverToBoxAdapter(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildEmptyState(),
        ),
      );
    } else {
      final crossAxisCount = Responsive.gridColumns(
        context,
        mobile: 1,
        tablet: 2,
        desktop: 2,
        largeDesktop: 3,
      );

      return SliverPadding(
        padding: EdgeInsets.all(spacing.md),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing.md,
            mainAxisSpacing: spacing.md,
            childAspectRatio: context.responsive<double>(
              mobile: 1.2,
              tablet: 1.1,
              desktop: 1.0,
            ),
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: OrderListItem(
                    order: filteredOrders[index],
                    onTap: driverStatus.isOnline 
                        ? () => _showOrderDetails(context, filteredOrders[index])
                        : null,
                    isLocked: !driverStatus.isOnline,
                  ),
                ),
              );
            },
            childCount: filteredOrders.length,
          ),
        ),
      );
    }
  }

  Widget _buildHeader(
    BuildContext context,
    dynamic user, 
    DriverStatus driverStatus, 
    WidgetRef ref,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
  ) {
    return Container(
      padding: EdgeInsets.all(spacing.md),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Bar
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryOrange,
                child: Text(
                  (user?.name ?? 'U')[0].toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Driver',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkGray,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: context.responsive<double>(
                        mobile: 8,
                        tablet: 9,
                        desktop: 10,
                      ),
                      height: context.responsive<double>(
                        mobile: 8,
                        tablet: 9,
                        desktop: 10,
                      ),
                      decoration: BoxDecoration(
                        color: driverStatus.isOnline 
                            ? AppTheme.successGreen 
                            : AppTheme.warningYellow,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: spacing.xs),
                    Text(
                      driverStatus.statusText,
                      style: textTheme.bodySmall?.copyWith(
                        color: driverStatus.isOnline 
                            ? AppTheme.successGreen 
                            : AppTheme.warningYellow,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                  ],
                ),
              ),
              Switch(
                value: driverStatus.isOnline,
                onChanged: (value) {
                  ref.read(driverStatusProvider.notifier).toggleStatus();
                },
                activeColor: AppTheme.successGreen,
                inactiveThumbColor: AppTheme.mediumGray,
              ),
            ],
          ),
          
          // Status message
          if (driverStatus.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: AppTheme.errorRed,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        driverStatus.errorMessage!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.errorRed,
                        ),
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 64,
            color: AppTheme.mediumGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No orders available',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.mediumGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back soon for new delivery opportunities!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.mediumGray.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.warningYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.lock_outline,
              size: 48,
              color: AppTheme.warningYellow,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Orders Locked',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You are currently offline. Switch to online mode to view and accept delivery orders.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.mediumGray,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.warningYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.warningYellow.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppTheme.warningYellow,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Use the toggle switch above to go online',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.warningYellow,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Details',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkGray,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildDetailRow('Order ID', order.id),
                        _buildDetailRow('Type', order.type.displayName),
                        _buildDetailRow('Status', order.status.displayName),
                        _buildDetailRow('Distance', '${order.distance.toStringAsFixed(1)} km'),
                        _buildDetailRow('Zone', order.zone),
                        if (order.customerName != null)
                          _buildDetailRow('Customer', order.customerName!),
                        if (order.customerPhone != null)
                          _buildDetailRow('Phone', order.customerPhone!),
                        const SizedBox(height: 24),
                        Text(
                          'Locations',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkGray,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLocationCard(
                          'Pickup',
                          order.pickupLocation,
                          order.pickupAddress,
                          Icons.store,
                          AppTheme.primaryOrange,
                        ),
                        const SizedBox(height: 12),
                        _buildLocationCard(
                          'Delivery',
                          order.dropoffLocation,
                          order.dropoffAddress,
                          Icons.location_on,
                          AppTheme.successGreen,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (order.latitude != null && order.longitude != null) {
                                final url = 'https://www.google.com/maps/dir/?api=1&destination=${order.latitude},${order.longitude}';
                                if (await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(Uri.parse(url));
                                }
                              }
                            },
                            icon: const Icon(Icons.navigation),
                            label: const Text('Start Navigation'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.mediumGray,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.darkGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(
    String label,
    String title,
    String address,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.mediumGray,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkGray,
                  ),
                ),
                Text(
                  address,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.mediumGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
