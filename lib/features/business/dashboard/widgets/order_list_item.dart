import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/app_theme.dart';
import '../../orders/models/order.dart';

class OrderListItem extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;
  final bool isLocked;

  const OrderListItem({
    super.key,
    required this.order,
    this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLocked ? Colors.grey.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isLocked ? 0.02 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.id,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGray,
                      ),
                    ),
                    Row(
                      children: [
                        _buildTypeChip(),
                        const SizedBox(width: 8),
                        _buildStatusChip(),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Pickup Location
                _buildLocationRow(
                  Icons.store,
                  'Pickup',
                  order.pickupLocation,
                  order.pickupAddress,
                  AppTheme.primaryOrange,
                ),

                const SizedBox(height: 8),

                // Dropoff Location
                _buildLocationRow(
                  Icons.location_on,
                  'Delivery',
                  order.dropoffLocation,
                  order.dropoffAddress,
                  AppTheme.successGreen,
                ),

                const SizedBox(height: 12),

                // Bottom Info Row
                Row(
                  children: [
                    Icon(
                      Icons.route,
                      size: 16,
                      color: AppTheme.mediumGray,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${order.distance.toStringAsFixed(1)} km',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.mediumGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.location_city,
                      size: 16,
                      color: AppTheme.mediumGray,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      order.zone,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.mediumGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (order.pickupTime != null)
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: AppTheme.warningYellow,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(order.pickupTime!),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.warningYellow,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Lock overlay
          if (isLocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock,
                        size: 32,
                        color: AppTheme.warningYellow,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Go Online to View',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.warningYellow,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(
    IconData icon,
    String label,
    String location,
    String address,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppTheme.mediumGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                location,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkGray,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                address,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.mediumGray,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeChip() {
    Color color;
    switch (order.type) {
      case OrderType.express:
        color = AppTheme.errorRed;
        break;
      case OrderType.scheduled:
        color = AppTheme.warningYellow;
        break;
      case OrderType.normal:
        color = AppTheme.successGreen;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        order.type.displayName,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    switch (order.status) {
      case OrderStatus.pending:
        color = AppTheme.warningYellow;
        break;
      case OrderStatus.readyForPickup:
        color = AppTheme.primaryOrange;
        break;
      case OrderStatus.assigned:
        color = AppTheme.primaryOrange;
        break;
      case OrderStatus.pickedUp:
        color = Colors.blue;
        break;
      case OrderStatus.inTransit:
        color = Colors.purple;
        break;
      case OrderStatus.delivered:
        color = AppTheme.successGreen;
        break;
      case OrderStatus.cancelled:
        color = AppTheme.errorRed;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        order.status.displayName,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final orderDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (orderDate == today) {
      // Today - show time only
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      // Different day - show date
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}

