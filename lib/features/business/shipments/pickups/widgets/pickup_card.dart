import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../theme/app_theme.dart';
import '../models/pickup.dart';

/// Professional pickup card widget displaying pickup task details
class PickupCard extends StatelessWidget {
  final Pickup pickup;
  final VoidCallback? onTap;

  const PickupCard({
    super.key,
    required this.pickup,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = AppTheme.getResponsiveTextTheme(context);
    final spacing = AppTheme.spacing(context);

    return Card(
      margin: EdgeInsets.only(bottom: spacing.sm),
      elevation: 0,
      color: const Color(0xFFF8F9FA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Opacity(
        opacity: onTap == null ? 0.6 : 1.0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // Header: Order Number & Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Pickup Number
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.sm,
                      vertical: spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${pickup.pickupNumber}',
                      style: textTheme.titleSmall?.copyWith(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Date
                  Text(
                    _formatDate(pickup.requestDate),
                    style: textTheme.bodySmall?.copyWith(
                      color: AppTheme.mediumGray,
                    ),
                  ),
                ],
              ),

              SizedBox(height: spacing.md),

              // Customer Name
              Row(
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 18,
                    color: AppTheme.darkGray,
                  ),
                  SizedBox(width: spacing.xs),
                  Expanded(
                    child: Text(
                      pickup.merchantName,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGray,
                      ),
                    ),
                  ),
                ],
              ),

              // Item Type Badges
              SizedBox(height: spacing.xs),
              Row(
                children: [
                  if (pickup.isFragileItems) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.xs,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber_outlined,
                            size: 14,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Fragile',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: spacing.xs),
                  ],
                  if (pickup.isLargeItems) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.xs,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 14,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Large Items',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: spacing.sm),

              // Status Badge
              _buildStatusBadge(pickup.status, textTheme, spacing),

              SizedBox(height: spacing.md),

              // Divider
              Divider(
                color: AppTheme.lightGray,
                height: 1,
              ),

              SizedBox(height: spacing.md),

              // Expected & Picked Up Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatBox(
                      icon: Icons.assignment_outlined,
                      label: 'Expected',
                      value: '${pickup.numberOfOrders} orders',
                      color: Colors.blue,
                      textTheme: textTheme,
                      spacing: spacing,
                    ),
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: _buildStatBox(
                      icon: Icons.check_circle_outline,
                      label: 'Picked up',
                      value: '${pickup.ordersPickedUp.length} orders',
                      color: Colors.green,
                      textTheme: textTheme,
                      spacing: spacing,
                    ),
                  ),
                ],
              ),

              // Pickup Fees
              if (pickup.pickupFees > 0) ...[
                SizedBox(height: spacing.sm),
                Container(
                  padding: EdgeInsets.all(spacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        size: 18,
                        color: Colors.green,
                      ),
                      SizedBox(width: spacing.xs),
                      Text(
                        'Pickup Fees: ',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppTheme.mediumGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${pickup.pickupFees.toStringAsFixed(2)} EGP',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: spacing.md),

              // Pickup Date
              Container(
                padding: EdgeInsets.all(spacing.sm),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: AppTheme.darkGray,
                    ),
                    SizedBox(width: spacing.xs),
                    Text(
                      'Pickup Date: ',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppTheme.mediumGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatPickupDate(pickup.pickupDate),
                      style: textTheme.bodySmall?.copyWith(
                        color: AppTheme.darkGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
              if (onTap == null)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.md,
                          vertical: spacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: spacing.xs),
                            Text(
                              'Locked - Go online',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required TextTheme textTheme,
    required ResponsiveSpacing spacing,
  }) {
    return Container(
      padding: EdgeInsets.all(spacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              SizedBox(width: 4),
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: AppTheme.darkGray,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(
    PickupStatus status,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
  ) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case PickupStatus.newPickup:
        statusColor = Colors.orange;
        statusText = status.label;
        statusIcon = Icons.new_releases_outlined;
        break;
      case PickupStatus.driverAssigned:
        statusColor = Colors.blue;
        statusText = status.label;
        statusIcon = Icons.person_pin_circle_outlined;
        break;
      case PickupStatus.pickedUp:
        statusColor = Colors.indigo;
        statusText = status.label;
        statusIcon = Icons.local_shipping_outlined;
        break;
      case PickupStatus.completed:
        statusColor = Colors.green;
        statusText = status.label;
        statusIcon = Icons.check_circle_outline;
        break;
      case PickupStatus.cancelled:
        statusColor = Colors.red;
        statusText = status.label;
        statusIcon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 14,
            color: statusColor,
          ),
          SizedBox(width: 4),
          Text(
            statusText,
            style: textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatPickupDate(DateTime dateTime) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = weekdays[dateTime.weekday - 1];
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '$weekday $month/$day/${dateTime.year}';
  }
}
