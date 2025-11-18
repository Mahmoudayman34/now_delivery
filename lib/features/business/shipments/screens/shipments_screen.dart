import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/app_theme.dart';
import '../../dashboard/providers/driver_status_provider.dart';
import '../orders/screens/orders_screen.dart';
import '../pickups/screens/pickups_screen.dart';
import '../returns/screens/returns_screen.dart';

/// Main shipments screen with tabs for Orders, Pickups, and Returns
class ShipmentsScreen extends ConsumerStatefulWidget {
  const ShipmentsScreen({super.key});

  @override
  ConsumerState<ShipmentsScreen> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends ConsumerState<ShipmentsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppTheme.spacing(context);
    final driverStatus = ref.watch(driverStatusProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryOrange,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Shipments',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
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
                      'You are offline. Go online to access shipments.',
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
          
          // Tab Bar Section
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(spacing.md),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryOrange,
                      AppTheme.primaryOrange.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryOrange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.mediumGray,
                labelStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
                unselectedLabelStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.3,
                ),
                tabs: [
                  Tab(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text('Orders'),
                      ],
                    ),
                  ),
                  Tab(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text('Pickups'),
                      ],
                    ),
                  ),
                  Tab(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_return_outlined,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text('Returns'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Tab Content
          Expanded(
            child: Opacity(
              opacity: driverStatus.isOnline ? 1.0 : 0.6,
              child: IgnorePointer(
                ignoring: !driverStatus.isOnline,
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    OrdersScreen(),
                    PickupsScreen(),
                    ReturnsScreen(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
