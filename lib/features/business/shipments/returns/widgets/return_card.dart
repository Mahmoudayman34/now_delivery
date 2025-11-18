import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../theme/app_theme.dart';
import '../models/return_shipment.dart';

/// Professional return card widget displaying return shipment details
class ReturnCard extends StatelessWidget {
  final ReturnShipment returnShipment;
  final VoidCallback? onTap;

  const ReturnCard({
    super.key,
    required this.returnShipment,
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
                  // Order Number
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.sm,
                      vertical: spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${returnShipment.orderNumber}',
                      style: textTheme.titleSmall?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Express Badge
                  if (returnShipment.isExpressShipping) ...[
                    SizedBox(width: spacing.xs),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.xs,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt,
                            size: 12,
                            color: Colors.purple,
                          ),
                          SizedBox(width: 2),
                          Text(
                            'Express',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.purple,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Date
                  Text(
                    _formatDate(returnShipment.orderDate),
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
                    Icons.person_outline,
                    size: 18,
                    color: AppTheme.darkGray,
                  ),
                  SizedBox(width: spacing.xs),
                  Expanded(
                    child: Text(
                      returnShipment.customerName,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGray,
                      ),
                    ),
                  ),
                ],
              ),

              // Product Description & Items
              SizedBox(height: spacing.xs),
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 16,
                    color: AppTheme.mediumGray,
                  ),
                  SizedBox(width: spacing.xs),
                  Expanded(
                    child: Text(
                      '${returnShipment.numberOfItems} item${returnShipment.numberOfItems > 1 ? 's' : ''} • ${returnShipment.productDescription}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppTheme.mediumGray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Return Reason
              SizedBox(height: spacing.xs),
              Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: Colors.orange,
                  ),
                  SizedBox(width: spacing.xs),
                  Expanded(
                    child: Text(
                      _formatReturnReason(returnShipment.returnReason),
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              SizedBox(height: spacing.sm),

              // Status Badge
              _buildStatusBadge(returnShipment.status, returnShipment.statusLabel, textTheme, spacing),

              SizedBox(height: spacing.md),

              // Divider
              Divider(
                color: AppTheme.lightGray,
                height: 1,
              ),

              SizedBox(height: spacing.md),

              // Fees and Attempt Count
              Row(
                children: [
                  Expanded(
                    child: _buildStatBox(
                      icon: Icons.attach_money_outlined,
                      label: 'Total Fees',
                      value: '${returnShipment.totalFees.toStringAsFixed(2)} EGP',
                      color: Colors.green,
                      textTheme: textTheme,
                      spacing: spacing,
                    ),
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: _buildStatBox(
                      icon: Icons.replay_outlined,
                      label: 'Attempts',
                      value: '${returnShipment.attemptCount}',
                      color: Colors.orange,
                      textTheme: textTheme,
                      spacing: spacing,
                    ),
                  ),
                ],
              ),

              SizedBox(height: spacing.md),

              // Merchant Info & Scheduled Retry
              Container(
                padding: EdgeInsets.all(spacing.sm),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.store,
                          size: 16,
                          color: AppTheme.mediumGray,
                        ),
                        SizedBox(width: spacing.xs),
                        Expanded(
                          child: Text(
                            returnShipment.merchantName,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppTheme.darkGray,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (returnShipment.scheduledRetryAt != null) ...[
                      SizedBox(height: spacing.xs),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 16,
                            color: AppTheme.mediumGray,
                          ),
                          SizedBox(width: spacing.xs),
                          Text(
                            'Next Retry: ${_formatRetryDate(returnShipment.scheduledRetryAt!)}',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppTheme.darkGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
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
    ReturnStatus status,
    String statusLabel,
    TextTheme textTheme,
    ResponsiveSpacing spacing,
  ) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case ReturnStatus.returnInitiated:
        statusColor = Colors.orange;
        statusIcon = Icons.assignment_return_outlined;
        break;
      case ReturnStatus.returnAssigned:
        statusColor = Colors.blue;
        statusIcon = Icons.person_add_outlined;
        break;
      case ReturnStatus.returnPickedUp:
        statusColor = Colors.purple;
        statusIcon = Icons.shopping_bag_outlined;
        break;
      case ReturnStatus.inReturnStock:
        statusColor = Colors.deepPurple;
        statusIcon = Icons.inventory_outlined;
        break;
      case ReturnStatus.returnAtWarehouse:
        statusColor = Colors.indigo;
        statusIcon = Icons.warehouse_outlined;
        break;
      case ReturnStatus.returnInspection:
        statusColor = Colors.teal;
        statusIcon = Icons.search_outlined;
        break;
      case ReturnStatus.returnProcessing:
        statusColor = Colors.cyan;
        statusIcon = Icons.hourglass_empty_outlined;
        break;
      case ReturnStatus.returnToBusiness:
        statusColor = Colors.amber;
        statusIcon = Icons.local_shipping_outlined;
        break;
      case ReturnStatus.returnCompleted:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case ReturnStatus.returnToWarehouse:
        statusColor = Colors.red;
        statusIcon = Icons.keyboard_return_outlined;
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
            statusLabel,
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

  String _formatRetryDate(DateTime dateTime) {
    return '${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  String _formatReturnReason(String reason) {
    switch (reason.toLowerCase()) {
      case 'business_canceled':
        return 'Canceled by Business';
      case 'customer_refused':
        return 'Customer Refused';
      case 'damaged_package':
        return 'Damaged Package';
      case 'wrong_address':
        return 'Wrong Address';
      case 'wrong_item':
        return 'Wrong Item';
      case 'defective_product':
        return 'Defective Product';
      default:
        return reason.replaceAll('_', ' ').split(' ').map((word) => 
          word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase()
        ).join(' ');
    }
  }
}
