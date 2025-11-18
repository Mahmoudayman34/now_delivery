import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../theme/app_theme.dart';
import '../models/order.dart';

/// Professional order card widget with orange and white theme
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = AppTheme.spacing(context);

    return Card(
      margin: EdgeInsets.only(bottom: spacing.sm),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.lightGray.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Opacity(
        opacity: onTap == null ? 0.6 : 1.0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
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
                  // Order Number with gradient
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.sm,
                      vertical: spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryOrange.withOpacity(0.15),
                          AppTheme.primaryOrange.withOpacity(0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primaryOrange.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '#${order.orderNumber}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryOrange,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  // Date
                  Text(
                    _formatDate(order.orderDate),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.mediumGray,
                    ),
                  ),
                ],
              ),

              SizedBox(height: spacing.md),

              // Customer Name
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGray,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: spacing.sm),

              // Status Badge & Express Badge
              Wrap(
                spacing: spacing.xs,
                runSpacing: spacing.xs,
                children: [
                  _buildStatusBadge(order.status, spacing),
                  if (order.isExpressShipping)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.withOpacity(0.15),
                            Colors.purple.withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.purple.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            size: 14,
                            color: Colors.purple,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Express',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.purple,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              SizedBox(height: spacing.md),

              // Divider
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.lightGray.withOpacity(0.5),
                      AppTheme.lightGray.withOpacity(0.1),
                    ],
                  ),
                ),
              ),

              SizedBox(height: spacing.md),

              // Total Amount & Payment Method
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Total Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.mediumGray,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${order.orderFees.toStringAsFixed(0)} EGP',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkGray,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  // Payment Method
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.sm,
                      vertical: spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.withOpacity(0.15),
                          Colors.green.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.payments_rounded,
                          size: 16,
                          color: Colors.green,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'COD',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: spacing.md),

              // Summary Line
              Container(
                padding: EdgeInsets.all(spacing.sm),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.lightGray.withOpacity(0.3),
                      AppTheme.lightGray.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_rounded,
                          size: 16,
                          color: AppTheme.mediumGray,
                        ),
                        SizedBox(width: spacing.xs),
                        Text(
                          '${order.numberOfItems} ${order.numberOfItems == 1 ? 'Item' : 'Items'}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.mediumGray,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    Flexible(
                      child: Text(
                        order.productDescription,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.mediumGray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                      borderRadius: BorderRadius.circular(16),
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

  Widget _buildStatusBadge(OrderStatus status, ResponsiveSpacing spacing) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case OrderStatus.newOrder:
        statusColor = Colors.blue;
        statusText = order.statusLabel;
        statusIcon = Icons.fiber_new_rounded;
        break;
      case OrderStatus.pendingPickup:
        statusColor = Colors.orange;
        statusText = order.statusLabel;
        statusIcon = Icons.schedule_rounded;
        break;
      case OrderStatus.pickedUp:
        statusColor = Colors.purple;
        statusText = order.statusLabel;
        statusIcon = Icons.shopping_bag_rounded;
        break;
      case OrderStatus.packed:
        statusColor = Colors.teal;
        statusText = order.statusLabel;
        statusIcon = Icons.inventory_2_rounded;
        break;
      case OrderStatus.shipping:
        statusColor = Colors.indigo;
        statusText = order.statusLabel;
        statusIcon = Icons.local_shipping_rounded;
        break;
      case OrderStatus.inProgress:
        statusColor = Colors.blue;
        statusText = order.statusLabel;
        statusIcon = Icons.sync_rounded;
        break;
      case OrderStatus.outForDelivery:
        statusColor = Colors.deepPurple;
        statusText = order.statusLabel;
        statusIcon = Icons.delivery_dining_rounded;
        break;
      case OrderStatus.headingToCustomer:
        statusColor = Colors.indigo;
        statusText = order.statusLabel;
        statusIcon = Icons.delivery_dining_rounded;
        break;
      case OrderStatus.delivered:
        statusColor = Colors.green;
        statusText = order.statusLabel;
        statusIcon = Icons.check_circle_rounded;
        break;
      case OrderStatus.completed:
        statusColor = Colors.green;
        statusText = order.statusLabel;
        statusIcon = Icons.check_circle_rounded;
        break;
      case OrderStatus.canceled:
        statusColor = Colors.red;
        statusText = order.statusLabel;
        statusIcon = Icons.cancel_rounded;
        break;
      case OrderStatus.returned:
      case OrderStatus.returnInitiated:
      case OrderStatus.returnAssigned:
      case OrderStatus.returnPickedUp:
      case OrderStatus.inReturnStock:
      case OrderStatus.returnAtWarehouse:
      case OrderStatus.returnInspection:
      case OrderStatus.returnProcessing:
      case OrderStatus.returnToBusiness:
      case OrderStatus.returnCompleted:
        statusColor = Colors.orange;
        statusText = order.statusLabel;
        statusIcon = Icons.keyboard_return_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.15),
            statusColor.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
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
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
