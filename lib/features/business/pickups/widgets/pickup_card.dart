import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/pickup.dart';

// Helper function for status colors
Color _getStatusColor(PickupStatus status) {
  switch (status) {
    case PickupStatus.assigned:
      return Colors.orange[400]!;
    case PickupStatus.inProgress:
      return Colors.orange[600]!;
    case PickupStatus.completed:
      return Colors.orange[700]!;
    case PickupStatus.businessClosed:
      return Colors.orange[300]!;
    case PickupStatus.rejected:
      return Colors.orange[800]!;
  }
}

class PickupCard extends StatelessWidget {
  final Pickup pickup;
  final VoidCallback onTap;
  final VoidCallback? onMenuTap;

  const PickupCard({
    super.key,
    required this.pickup,
    required this.onTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
          highlightColor: Theme.of(context).primaryColor.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.orange[200]!,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.store_rounded,
                        color: Colors.orange[600],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pickup.business.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  pickup.business.address,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        _StatusBadge(status: pickup.status),
                        if (!pickup.isCompleted && onMenuTap != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onMenuTap,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.more_horiz_rounded,
                                    size: 16,
                                    color: Colors.orange[600],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange[200]!,
                        Colors.orange[100]!,
                        Colors.orange[200]!,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[25],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _InfoItem(
                          icon: Icons.qr_code_rounded,
                          label: 'Pickup ID',
                          value: pickup.id.toUpperCase(),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 32,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _InfoItem(
                          icon: Icons.schedule_rounded,
                          label: 'Scheduled',
                          value: _formatTime(pickup.scheduledTime),
                        ),
                      ),
                    ],
                  ),
                ),
                if (pickup.orders.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue[100]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoItem(
                            icon: Icons.inventory_2_rounded,
                            label: 'Orders',
                            value: '${pickup.collectedOrders}/${pickup.totalOrders}',
                          ),
                        ),
                        if (pickup.completedAt != null) ...[
                          Container(
                            width: 1,
                            height: 32,
                            color: Colors.blue[200],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _InfoItem(
                              icon: Icons.check_circle_rounded,
                              label: 'Completed',
                              value: _formatTime(pickup.completedAt!),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (pickup.rejectionReason != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.red[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pickup.rejectionReason!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
            ],
          ),
        ),
      ),
    ));
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (dateTime.day == now.day && 
        dateTime.month == now.month && 
        dateTime.year == now.year) {
      // Same day - show time only
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays.abs() == 1) {
      // Yesterday or tomorrow
      final timeStr = DateFormat('HH:mm').format(dateTime);
      return difference.isNegative ? 'Yesterday $timeStr' : 'Tomorrow $timeStr';
    } else {
      // Different day - show date and time
      return DateFormat('MMM d, HH:mm').format(dateTime);
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final PickupStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    final (icon, bgColor) = _getStatusIconAndBackground(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color) _getStatusIconAndBackground(PickupStatus status) {
    switch (status) {
      case PickupStatus.assigned:
        return (Icons.assignment_rounded, Colors.blue[50]!);
      case PickupStatus.inProgress:
        return (Icons.local_shipping_rounded, Colors.orange[50]!);
      case PickupStatus.completed:
        return (Icons.check_circle_rounded, Colors.green[50]!);
      case PickupStatus.businessClosed:
        return (Icons.store_mall_directory_rounded, Colors.grey[100]!);
      case PickupStatus.rejected:
        return (Icons.cancel_rounded, Colors.red[50]!);
    }
  }

}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
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
}
