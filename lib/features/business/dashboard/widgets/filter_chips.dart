import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/app_theme.dart';
import '../../orders/models/order.dart';
import '../../orders/providers/orders_provider.dart';

class FilterChips extends ConsumerWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);
    final availableZones = ref.watch(availableZonesProvider);
    final allOrders = ordersState.orders;
    
    final hasActiveFilters = ordersState.selectedStatus != null || 
                           ordersState.selectedZones.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Clear All
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 20,
                    color: AppTheme.primaryOrange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filters',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  if (hasActiveFilters) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_getActiveFiltersCount(ordersState)}',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (hasActiveFilters)
                TextButton.icon(
                  onPressed: () {
                    ref.read(ordersProvider.notifier).clearFilters();
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: Text(
                    'Clear All',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.errorRed,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),

          // Status Filters Section
          _buildFilterSection(
            'Status',
            Icons.assignment_outlined,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusChip(
                    ref,
                    'All',
                    null,
                    ordersState.selectedStatus == null,
                    _getOrderCountForStatus(allOrders, null),
                  ),
                  const SizedBox(width: 8),
                  ...OrderStatus.values.map((status) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildStatusChip(
                        ref,
                        status.displayName,
                        status,
                        ordersState.selectedStatus == status,
                        _getOrderCountForStatus(allOrders, status),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Zone Filters Section
          if (availableZones.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildFilterSection(
              'Zones',
              Icons.location_on_outlined,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableZones.map((zone) {
                  final isSelected = ordersState.selectedZones.contains(zone);
                  final count = _getOrderCountForZone(allOrders, zone);
                  return _buildZoneChip(ref, zone, isSelected, count);
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: AppTheme.mediumGray,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildStatusChip(
    WidgetRef ref,
    String label,
    OrderStatus? status,
    bool isSelected,
    int count,
  ) {
    Color chipColor = _getStatusColor(status);
    
    return GestureDetector(
      onTap: () {
        final currentSelectedStatus = ref.read(ordersProvider).selectedStatus;
        
        // If tapping on already selected status (and it's not "All"), deselect it
        if (currentSelectedStatus == status && status != null) {
          ref.read(ordersProvider.notifier).setStatusFilter(null);
        } else {
          ref.read(ordersProvider.notifier).setStatusFilter(status);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? LinearGradient(
                  colors: [chipColor, chipColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppTheme.lightGray,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AppTheme.borderGray,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: chipColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.darkGray,
              ),
            ),
            if (isSelected && status != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.close,
                size: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ],
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withOpacity(0.2) 
                    : chipColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : chipColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneChip(WidgetRef ref, String zone, bool isSelected, int count) {
    return GestureDetector(
      onTap: () {
        ref.read(ordersProvider.notifier).toggleZoneFilter(zone);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? LinearGradient(
                  colors: [AppTheme.successGreen, AppTheme.successGreen.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppTheme.lightGray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.successGreen : AppTheme.borderGray,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.successGreen.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : AppTheme.successGreen,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              zone,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.darkGray,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.close,
                size: 10,
                color: Colors.white.withOpacity(0.8),
              ),
            ],
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withOpacity(0.2) 
                    : AppTheme.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppTheme.successGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus? status) {
    if (status == null) return AppTheme.primaryOrange;
    
    switch (status) {
      case OrderStatus.pending:
        return AppTheme.warningYellow;
      case OrderStatus.readyForPickup:
        return AppTheme.primaryOrange;
      case OrderStatus.assigned:
        return AppTheme.primaryOrange;
      case OrderStatus.pickedUp:
        return Colors.blue;
      case OrderStatus.inTransit:
        return Colors.purple;
      case OrderStatus.delivered:
        return AppTheme.successGreen;
      case OrderStatus.cancelled:
        return AppTheme.errorRed;
    }
  }

  int _getOrderCountForStatus(List<Order> orders, OrderStatus? status) {
    if (status == null) return orders.length;
    return orders.where((order) => order.status == status).length;
  }

  int _getOrderCountForZone(List<Order> orders, String zone) {
    return orders.where((order) => order.zone == zone).length;
  }

  int _getActiveFiltersCount(dynamic ordersState) {
    int count = 0;
    if (ordersState.selectedStatus != null) count++;
    if (ordersState.selectedZones.isNotEmpty) count += ordersState.selectedZones.length as int;
    return count;
  }
}

