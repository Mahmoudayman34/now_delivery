import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../theme/app_theme.dart';
import '../../../../core/utils/location_permission_dialog.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/driver_status_provider.dart';
import '../../shipments/orders/providers/orders_provider.dart';
import '../../shipments/orders/models/order.dart';
import '../../shipments/orders/screens/order_details_screen.dart';
import '../../shipments/pickups/providers/pickups_provider.dart';
import '../../shipments/pickups/models/pickup.dart';
import '../../shipments/pickups/screens/pickup_details_screen.dart';
import '../../shipments/returns/providers/returns_provider.dart';
import '../../shipments/returns/models/return_shipment.dart';
import '../../shipments/returns/screens/return_details_screen.dart';
import '../../notifications/providers/notification_providers.dart';
import '../../notifications/screens/notifications_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  MobileScannerController? _scannerController;

  TabController get tabController {
    _tabController ??= TabController(length: 3, vsync: this);
    return _tabController!;
  }

  @override
  void initState() {
    super.initState();
    
    // Refresh data when screen loads
    Future.microtask(() {
      ref.read(ordersProvider.notifier).refresh();
      ref.read(pickupsProvider.notifier).refresh();
      ref.read(returnsProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final driverStatus = ref.watch(driverStatusProvider);
    final ordersState = ref.watch(ordersProvider);
    final pickupsState = ref.watch(pickupsProvider);
    final returnsState = ref.watch(returnsProvider);
    final textTheme = AppTheme.getResponsiveTextTheme(context);
    final spacing = AppTheme.spacing(context);

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(ordersProvider.notifier).refresh();
            await ref.read(pickupsProvider.notifier).refresh();
            await ref.read(returnsProvider.notifier).refresh();
          },
          child: CustomScrollView(
      slivers: [
              // Header with gradient background
        SliverToBoxAdapter(
                child: _buildHeader(context, user, textTheme, spacing),
              ),

              // Quick Actions
          SliverToBoxAdapter(
                child: _buildQuickActions(context, driverStatus, textTheme, spacing, ref),
              ),

              // Today's Summary
          SliverToBoxAdapter(
                child: _buildTodaysSummary(context, ordersState, textTheme, spacing),
              ),

              // Assigned Shipments with Tabs
        SliverToBoxAdapter(
                child: _buildAssignedShipmentsWithTabs(
                  context, ordersState, pickupsState, returnsState, textTheme, spacing
                ),
              ),

              // Bottom padding
              SliverToBoxAdapter(
                child: SizedBox(height: spacing.xxl),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Notification icon with badge
  Widget _buildNotificationIcon(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(unreadCountProvider);

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NotificationsScreen(),
          ),
        );
        // Refresh unread count after returning from notifications screen
        ref.invalidate(unreadCountProvider);
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 24,
            ),
            unreadCountAsync.when(
              data: (count) {
                if (count == 0) return const SizedBox.shrink();
                return Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        count > 9 ? '9+' : count.toString(),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // Header with gradient background
  Widget _buildHeader(
    BuildContext context,
    dynamic user,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryOrange,
            AppTheme.darkOrange,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.all(spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Welcome back,',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                  Text(
                      user?.name ?? 'Alex Rivera',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ),
              _buildNotificationIcon(context, ref),
            ],
          ),
        ],
      ),
    );
  }

  // Quick Actions Section
  Widget _buildQuickActions(
    BuildContext context,
    DriverStatus driverStatus,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
    WidgetRef ref,
  ) {
    return Padding(
        padding: EdgeInsets.all(spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
            'Quick Actions',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
                      color: AppTheme.darkGray,
                    ),
                  ),
          SizedBox(height: spacing.md),
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
        children: [
                // Online Status Toggle - Redesigned
                GestureDetector(
                  onTap: () {
                    ref.read(driverStatusProvider.notifier).toggleStatus(
                      showDialogCallback: () => showLocationPermissionDialog(context),
                      context: context,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(spacing.md),
                    decoration: BoxDecoration(
                      color: driverStatus.isOnline 
                          ? AppTheme.primaryOrange 
                          : AppTheme.mediumGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
            children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                    color: Colors.white,
                            shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                          child: Text(
                            driverStatus.isOnline ? 'You are Online' : 'You are Offline',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                    fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    Text(
                          driverStatus.isOnline ? 'Tap to go offline' : 'Tap to go online',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                  ),
                ),
                SizedBox(height: spacing.md),
                // Scan Shipment Button
                GestureDetector(
                  onTap: () {
                    _showBarcodeScanner();
                  },
              child: Container(
                    padding: EdgeInsets.all(spacing.md),
                decoration: BoxDecoration(
                      color: AppTheme.lightGray,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.borderGray,
                        width: 1,
                      ),
                ),
                child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                        Container(
                          padding: EdgeInsets.all(spacing.sm),
                          decoration: BoxDecoration(
              color: AppTheme.primaryOrange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: spacing.sm),
                        Text(
                          'Scan Shipment',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkGray,
                      ),
                    ),
                  ],
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

  // Today's Summary Section
  Widget _buildTodaysSummary(
    BuildContext context,
    AsyncValue<Map<String, List<Order>>> ordersState,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
  ) {
    final ordersMap = ordersState.when(
      data: (ordersMap) => ordersMap,
      loading: () => <String, List<Order>>{},
      error: (_, __) => <String, List<Order>>{},
    );

    // Flatten all orders from the map
    final orders = <Order>[];
    for (var ordersList in ordersMap.values) {
      orders.addAll(ordersList);
    }

    // Filter today's orders
    final today = DateTime.now();
    final todayOrders = orders.where((order) {
      final orderDate = order.orderDate;
      return orderDate.year == today.year &&
          orderDate.month == today.month &&
          orderDate.day == today.day;
    }).toList();

    final completedToday = todayOrders.where((order) => 
      order.status == OrderStatus.delivered || 
      order.status == OrderStatus.completed
    ).length;
    
    final pendingToday = todayOrders.where((order) => 
      order.status != OrderStatus.delivered && 
      order.status != OrderStatus.completed &&
      order.status != OrderStatus.canceled
    ).length;
    
    final totalToday = todayOrders.length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.md),
      child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Summary',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
                    color: AppTheme.darkGray,
                  ),
                ),
          SizedBox(height: spacing.md),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                Expanded(
                  child: _buildSummaryCard(
                    '$completedToday',
                    'Completed',
                    AppTheme.successGreen.withOpacity(0.1),
                    AppTheme.successGreen,
                    spacing,
                  ),
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: _buildSummaryCard(
                    '$pendingToday',
                    'Pending',
                    AppTheme.primaryOrange.withOpacity(0.1),
                    AppTheme.primaryOrange,
                    spacing,
                  ),
                ),
                SizedBox(width: spacing.sm),
                    Expanded(
                  child: _buildSummaryCard(
                    '$totalToday',
                    'Total Today',
                    AppTheme.lightGray,
                    AppTheme.darkGray,
                    spacing,
                      ),
                    ),
                  ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String value,
    String label,
    Color bgColor,
    Color textColor,
    ResponsiveSpacing spacing,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: spacing.lg,
        horizontal: spacing.sm,
      ),
            decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: textColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.2,
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.mediumGray,
                      fontWeight: FontWeight.w500,
              height: 1.2,
                    ),
                    textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Assigned Shipments Section with Tabs
  Widget _buildAssignedShipmentsWithTabs(
    BuildContext context,
    AsyncValue<Map<String, List<Order>>> ordersState,
    AsyncValue<Map<String, List<Pickup>>> pickupsState,
    AsyncValue<Map<String, List<ReturnShipment>>> returnsState,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
  ) {
    final driverStatus = ref.watch(driverStatusProvider);
    return Padding(
      padding: EdgeInsets.all(spacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
            'Today\'s Assigned Shipments',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkGray,
                          ),
                        ),
          SizedBox(height: spacing.md),
          
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: tabController,
              indicator: BoxDecoration(
                color: AppTheme.primaryOrange,
                                borderRadius: BorderRadius.circular(12),
                              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.mediumGray,
              labelStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Orders'),
                Tab(text: 'Pickups'),
                Tab(text: 'Returns'),
              ],
            ),
          ),
          
          SizedBox(height: spacing.md),
          
          // Tab Content
          SizedBox(
            height: 400, // Fixed height for the tab content
            child: TabBarView(
              controller: tabController,
              children: [
                // Orders Tab
                _buildOrdersTab(ordersState, spacing, driverStatus.isOnline),
                
                // Pickups Tab
                _buildPickupsTab(pickupsState, spacing, driverStatus.isOnline),
                
                // Returns Tab
                _buildReturnsTab(returnsState, spacing, driverStatus.isOnline),
              ],
                  ),
                ),
              ],
            ),
    );
  }

  // Orders Tab Content
  Widget _buildOrdersTab(
    AsyncValue<Map<String, List<Order>>> ordersState,
    ResponsiveSpacing spacing,
    bool isOnline,
  ) {
    return ordersState.when(
      data: (ordersMap) {
        // Flatten all orders from the map
        final allOrders = <Order>[];
        for (var ordersList in ordersMap.values) {
          allOrders.addAll(ordersList);
        }
        
        // Get today's date
        final today = DateTime.now();
        
        // Filter for assigned orders from today only
        final todaysAssignedOrders = allOrders.where((order) {
          // Check if order is from today
          final orderDate = order.orderDate;
          final isToday = orderDate.year == today.year &&
              orderDate.month == today.month &&
              orderDate.day == today.day;
          
          // Check if order is in an assigned status
          final isAssigned = order.status == OrderStatus.pendingPickup || 
              order.status == OrderStatus.pickedUp ||
              order.status == OrderStatus.outForDelivery ||
              order.status == OrderStatus.headingToCustomer;
          
          return isToday && isAssigned;
        }).toList();
        
        // Sort by order date (most recent first)
        todaysAssignedOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
        
        if (todaysAssignedOrders.isEmpty) {
          return _buildEmptyShipments('No orders for today', spacing);
        }
        
        return ListView(
          padding: EdgeInsets.zero,
          children: todaysAssignedOrders.map((order) => 
            _buildShipmentCard(
              orderNumber: order.orderNumber,
              customerName: order.customerName,
              address: order.customerAddress,
              status: order.statusLabel,
              statusColor: _getStatusColor(order.status),
              type: 'Delivery',
              spacing: spacing,
              isLocked: !isOnline,
              onTap: isOnline ? () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsScreen(order: order),
                  ),
                );
                
                // Refresh if order was updated
                if (result == true && context.mounted) {
                  ref.read(ordersProvider.notifier).refresh();
                }
              } : null,
            )
          ).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildEmptyShipments('Error loading orders', spacing),
    );
  }

  // Pickups Tab Content
  Widget _buildPickupsTab(
    AsyncValue<Map<String, List<Pickup>>> pickupsState,
    ResponsiveSpacing spacing,
    bool isOnline,
  ) {
    return pickupsState.when(
      data: (pickupsMap) {
        final allPickups = <Pickup>[];
        for (var pickupsList in pickupsMap.values) {
          allPickups.addAll(pickupsList);
        }
        
        // Get today's date
        final today = DateTime.now();
        
        // Filter for active pickups from today only
        final todaysActivePickups = allPickups.where((pickup) {
          // Check if pickup is from today
          final pickupDate = pickup.pickupDate;
          final isToday = pickupDate.year == today.year &&
              pickupDate.month == today.month &&
              pickupDate.day == today.day;
          
          // Check if pickup is in an active status
          final isActive = pickup.status == PickupStatus.newPickup || 
              pickup.status == PickupStatus.driverAssigned ||
              pickup.status == PickupStatus.pickedUp;
          
          return isToday && isActive;
        }).toList();
        
        // Sort by pickup date (most recent first)
        todaysActivePickups.sort((a, b) => b.pickupDate.compareTo(a.pickupDate));
        
        if (todaysActivePickups.isEmpty) {
          return _buildEmptyShipments('No pickups for today', spacing);
        }
        
        return ListView(
          padding: EdgeInsets.zero,
          children: todaysActivePickups.map((pickup) => 
            _buildShipmentCard(
              orderNumber: pickup.pickupNumber,
              customerName: pickup.merchantName,
              address: pickup.merchantAddress,
              status: pickup.status.label,
              statusColor: _getPickupStatusColor(pickup.status),
              type: 'Pickup',
              spacing: spacing,
              isLocked: !isOnline,
              onTap: isOnline ? () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PickupDetailsScreen(pickup: pickup),
                  ),
                );
                
                // Refresh if pickup was updated
                if (result == true && context.mounted) {
                  ref.read(pickupsProvider.notifier).refresh();
                }
              } : null,
            )
          ).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildEmptyShipments('Error loading pickups', spacing),
    );
  }

  // Returns Tab Content
  Widget _buildReturnsTab(
    AsyncValue<Map<String, List<ReturnShipment>>> returnsState,
    ResponsiveSpacing spacing,
    bool isOnline,
  ) {
    return returnsState.when(
      data: (returnsMap) {
        final allReturns = <ReturnShipment>[];
        for (var returnsList in returnsMap.values) {
          allReturns.addAll(returnsList);
        }
        
        // Get today's date
        final today = DateTime.now();
        
        // Filter for returns from today only
        final todaysActiveReturns = allReturns.where((returnShipment) {
          // Check if return is from today
          final returnDate = returnShipment.orderDate;
          final isToday = returnDate.year == today.year &&
              returnDate.month == today.month &&
              returnDate.day == today.day;
          
          return isToday;
        }).toList();
        
        // Sort by order date (most recent first)
        todaysActiveReturns.sort((a, b) => b.orderDate.compareTo(a.orderDate));
        
        if (todaysActiveReturns.isEmpty) {
          return _buildEmptyShipments('No returns for today', spacing);
        }
        
        return ListView(
          padding: EdgeInsets.zero,
          children: todaysActiveReturns.map((returnShipment) => 
            _buildShipmentCard(
              orderNumber: returnShipment.orderNumber,
              customerName: returnShipment.merchantName,
              address: returnShipment.customerAddress,
              status: returnShipment.statusLabel,
              statusColor: _getReturnStatusColor(returnShipment.status),
              type: 'Return',
              spacing: spacing,
              isLocked: !isOnline,
              onTap: isOnline ? () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReturnDetailsScreen(
                      orderNumber: returnShipment.orderNumber,
                    ),
                  ),
                );
                
                // Refresh if return was updated
                if (result == true && context.mounted) {
                  ref.read(returnsProvider.notifier).refresh();
                }
              } : null,
            )
          ).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildEmptyShipments('Error loading returns', spacing),
    );
  }

  Widget _buildShipmentCard({
    required String orderNumber,
    required String customerName,
    required String address,
    required String status,
    required Color statusColor,
    required String type,
    required ResponsiveSpacing spacing,
    required bool isLocked,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Opacity(
        opacity: isLocked ? 0.6 : 1.0,
        child: Container(
          margin: EdgeInsets.only(bottom: spacing.sm),
          padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
            color: Colors.white,
        borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderGray,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.sm,
                        vertical: spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        type,
                  style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryOrange,
                  ),
                ),
                    ),
                    SizedBox(width: spacing.sm),
                Text(
                      '#$orderNumber',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkGray,
                  ),
                ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.xs,
                  ),
      decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
          ),
        ],
      ),
            SizedBox(height: spacing.sm),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: AppTheme.mediumGray,
                ),
                SizedBox(width: spacing.xs),
                Expanded(
                  child: Text(
                    customerName,
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
            SizedBox(height: spacing.xs),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppTheme.mediumGray,
                ),
                SizedBox(width: spacing.xs),
                Expanded(
                  child: Text(
                    address,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.mediumGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: spacing.xs),
                Icon(
                  isLocked ? Icons.lock_outline : Icons.arrow_forward_ios,
                  size: 12,
                  color: isLocked ? AppTheme.errorRed : AppTheme.mediumGray,
                ),
              ],
            ),
            if (isLocked)
                    Container(
                margin: EdgeInsets.only(top: spacing.sm),
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs,
                      ),
                      decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.errorRed.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 12,
                      color: AppTheme.errorRed,
                    ),
                    SizedBox(width: spacing.xs),
                    Text(
                      'Go online to unlock',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.errorRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyShipments(String message, ResponsiveSpacing spacing) {
    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
                    color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderGray,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.mediumGray,
          ),
        ),
      ),
    );
  }

  void _showBarcodeScanner() {
    _scannerController = MobileScannerController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: 500,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Scan Shipment Barcode',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkGray,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _scannerController?.dispose();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                      color: AppTheme.darkGray,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: MobileScanner(
                      controller: _scannerController,
                      onDetect: (BarcodeCapture capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty) {
                          final String? code = barcodes.first.rawValue;
                          if (code != null && code.isNotEmpty) {
                            _scannerController?.dispose();
                            Navigator.of(context).pop();
                            _handleScannedBarcode(code);
                          }
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Position the barcode within the frame',
                  style: GoogleFonts.inter(
                    color: AppTheme.mediumGray,
                    fontSize: 14,
                  ),
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

  Future<void> _handleScannedBarcode(String barcode) async {
    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Text('Searching for shipment...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    try {
      // Search for the order in orders
      final ordersAsync = ref.read(ordersProvider);
      await ordersAsync.when(
        data: (ordersMap) async {
          Order? foundOrder;
          for (var ordersList in ordersMap.values) {
            try {
              foundOrder = ordersList.firstWhere(
                (order) => order.orderNumber == barcode || order.smartFlyerBarcode == barcode,
              );
              break; // Found, exit loop
            } catch (e) {
              // Not found in this list, continue searching
            }
          }

          if (foundOrder != null) {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailsScreen(order: foundOrder!),
                ),
              );
            }
            return;
          }

          // Search in pickups
          final pickupsAsync = ref.read(pickupsProvider);
          await pickupsAsync.when(
            data: (pickupsMap) async {
              Pickup? foundPickup;
              for (var pickupsList in pickupsMap.values) {
                try {
                  foundPickup = pickupsList.firstWhere(
                    (pickup) => pickup.pickupNumber == barcode,
                  );
                  break; // Found, exit loop
                } catch (e) {
                  // Not found in this list, continue searching
                }
              }

              if (foundPickup != null) {
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PickupDetailsScreen(pickup: foundPickup!),
                    ),
                  );
                }
                return;
              }

              // Search in returns
              final returnsAsync = ref.read(returnsProvider);
              await returnsAsync.when(
                data: (returnsMap) async {
                  ReturnShipment? foundReturn;
                  for (var returnsList in returnsMap.values) {
                    try {
                      foundReturn = returnsList.firstWhere(
                        (returnShipment) => returnShipment.orderNumber == barcode,
                      );
                      break; // Found, exit loop
                    } catch (e) {
                      // Not found in this list, continue searching
                    }
                  }

                  if (foundReturn != null) {
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReturnDetailsScreen(
                            orderNumber: foundReturn!.orderNumber,
                          ),
                        ),
                      );
                    }
                    return;
                  }

                  // Not found
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Shipment not found: $barcode'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                loading: () {},
                error: (_, __) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Shipment not found: $barcode'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
              );
            },
            loading: () {},
            error: (_, __) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Shipment not found: $barcode'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          );
        },
        loading: () {},
        error: (_, __) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error searching for shipment'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
      case OrderStatus.completed:
        return AppTheme.successGreen;
      case OrderStatus.canceled:
        return AppTheme.errorRed;
      case OrderStatus.pendingPickup:
      case OrderStatus.pickedUp:
      case OrderStatus.outForDelivery:
      case OrderStatus.headingToCustomer:
      case OrderStatus.inProgress:
        return AppTheme.primaryOrange;
      default:
        return AppTheme.mediumGray;
    }
  }

  Color _getPickupStatusColor(PickupStatus status) {
    switch (status) {
      case PickupStatus.completed:
        return AppTheme.successGreen;
      case PickupStatus.cancelled:
        return AppTheme.errorRed;
      case PickupStatus.newPickup:
      case PickupStatus.driverAssigned:
      case PickupStatus.pickedUp:
        return AppTheme.primaryOrange;
    }
  }

  Color _getReturnStatusColor(ReturnStatus status) {
    switch (status) {
      case ReturnStatus.returnCompleted:
        return AppTheme.successGreen;
      case ReturnStatus.returnAssigned:
      case ReturnStatus.returnPickedUp:
      case ReturnStatus.returnToBusiness:
        return AppTheme.primaryOrange;
      case ReturnStatus.returnInitiated:
      case ReturnStatus.inReturnStock:
      case ReturnStatus.returnAtWarehouse:
      case ReturnStatus.returnInspection:
      case ReturnStatus.returnProcessing:
        return AppTheme.warningYellow;
      default:
        return AppTheme.mediumGray;
    }
  }
}
