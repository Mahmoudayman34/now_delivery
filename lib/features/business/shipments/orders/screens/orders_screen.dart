import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../theme/app_theme.dart';
import '../../../dashboard/providers/driver_status_provider.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_card.dart';
import 'order_details_screen.dart';

/// Orders screen displaying delivery orders grouped by zones
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = AppTheme.spacing(context);
    final ordersAsync = ref.watch(ordersProvider);
    final driverStatus = ref.watch(driverStatusProvider);

    return Container(
      color: Colors.white,
      child: ordersAsync.when(
        data: (ordersMap) {
          if (ordersMap.isEmpty) {
            return _buildEmptyState(context, spacing);
          }

          return RefreshIndicator(
            color: AppTheme.primaryOrange,
            onRefresh: () => ref.read(ordersProvider.notifier).refresh(),
            child: ListView.builder(
              padding: EdgeInsets.only(
                left: spacing.md,
                right: spacing.md,
                top: spacing.md,
                bottom: spacing.xl * 3,
              ),
              itemCount: ordersMap.length,
              itemBuilder: (context, index) {
                final zone = ordersMap.keys.elementAt(index);
                final orders = ordersMap[zone]!;

                return _ZoneSection(
                  zone: zone,
                  itemCount: orders.length,
                  itemLabel: orders.length == 1 ? 'order' : 'orders',
                  zoneColor: AppTheme.primaryOrange,
                  children: orders.map((order) => OrderCard(
                    order: order,
                    onTap: driverStatus.isOnline ? () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsScreen(order: order),
                        ),
                      );
                      
                      // If result is true, refresh the orders list
                      if (result == true && context.mounted) {
                        ref.read(ordersProvider.notifier).refresh();
                      }
                    } : null,
                  )).toList(),
                );
              },
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryOrange,
          ),
        ),
        error: (error, stack) => _buildErrorState(context, spacing, ref),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ResponsiveSpacing spacing) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(spacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(spacing.xl),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryOrange.withOpacity(0.1),
                        AppTheme.primaryOrange.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_shipping_outlined,
                    size: 64,
                    color: AppTheme.primaryOrange,
                  ),
                ),
                SizedBox(height: spacing.xl),
                Text(
                  'No Orders Yet',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkGray,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: spacing.sm),
                Text(
                  'Your delivery orders will appear here',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppTheme.mediumGray,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ResponsiveSpacing spacing, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(spacing.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withOpacity(0.1),
                    Colors.red.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
            ),
            SizedBox(height: spacing.xl),
            Text(
              'Failed to Load Orders',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkGray,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: spacing.sm),
            Text(
              'Please try again',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.mediumGray,
              ),
            ),
            SizedBox(height: spacing.xl),
            ElevatedButton(
              onPressed: () => ref.read(ordersProvider.notifier).refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.xl,
                  vertical: spacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Collapsible zone section widget with modern design
class _ZoneSection extends StatefulWidget {
  final String zone;
  final int itemCount;
  final String itemLabel;
  final Color zoneColor;
  final List<Widget> children;

  const _ZoneSection({
    required this.zone,
    required this.itemCount,
    required this.itemLabel,
    required this.zoneColor,
    required this.children,
  });

  @override
  State<_ZoneSection> createState() => _ZoneSectionState();
}

class _ZoneSectionState extends State<_ZoneSection> with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  late AnimationController _animController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(_animController);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppTheme.spacing(context);

    return Container(
      margin: EdgeInsets.only(bottom: spacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightGray.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Zone Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggle,
              borderRadius: _isExpanded
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    )
                  : BorderRadius.circular(16),
              child: Container(
                padding: EdgeInsets.all(spacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.zoneColor.withOpacity(0.1),
                      widget.zoneColor.withOpacity(0.05),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: _isExpanded
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        )
                      : BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // Zone Icon with Badge
                    Container(
                      padding: EdgeInsets.all(spacing.sm),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.zoneColor,
                            widget.zoneColor.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: widget.zoneColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: spacing.sm),
                    // Zone Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.zone,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.darkGray,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '${widget.itemCount} ${widget.itemLabel}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Expand/Collapse Icon
                    RotationTransition(
                      turns: _rotationAnimation,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: widget.zoneColor,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Collapsible Content
          if (_isExpanded)
            Padding(
              padding: EdgeInsets.all(spacing.sm),
              child: Column(
                children: widget.children,
              ),
            ),
        ],
      ),
    );
  }
}
