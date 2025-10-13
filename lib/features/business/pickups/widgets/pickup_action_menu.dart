import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/pickup.dart';

class PickupActionMenu {
  static void show({
    required BuildContext context,
    required Pickup pickup,
    required VoidCallback onComplete,
    required VoidCallback onBusinessClosed,
    required VoidCallback onReject,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PickupActionBottomSheet(
        pickup: pickup,
        onComplete: onComplete,
        onBusinessClosed: onBusinessClosed,
        onReject: onReject,
      ),
    );
  }
}

class _PickupActionBottomSheet extends StatelessWidget {
  final Pickup pickup;
  final VoidCallback onComplete;
  final VoidCallback onBusinessClosed;
  final VoidCallback onReject;

  const _PickupActionBottomSheet({
    required this.pickup,
    required this.onComplete,
    required this.onBusinessClosed,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(pickup.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.local_shipping_rounded,
                      color: _getStatusColor(pickup.status),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pickup Actions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[800],
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pickup.business.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Action Items
              Column(
                children: [
                  // Complete Pickup
                  _ActionMenuItem(
                    icon: Icons.check_circle_rounded,
                    title: 'Complete Pickup',
                    subtitle: pickup.orders.isNotEmpty 
                        ? 'Mark this pickup as completed'
                        : 'Add orders first to complete',
                    color: pickup.orders.isNotEmpty ? Colors.grey[600]! : Colors.red[600]!,
                    backgroundColor: pickup.orders.isNotEmpty ? Colors.grey[50]! : Colors.red[50]!,
                    enabled: pickup.orders.isNotEmpty,
                    onTap: pickup.orders.isNotEmpty
                        ? () {
                            Navigator.pop(context);
                            HapticFeedback.mediumImpact();
                            onComplete();
                          }
                        : null,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Business Closed
                  _ActionMenuItem(
                    icon: Icons.store_mall_directory_rounded,
                    title: 'Business Closed',
                    subtitle: 'Mark business as closed at scheduled time',
                    color: Colors.red[600]!,
                    backgroundColor: Colors.red[50]!,
                    enabled: true,
                    onTap: () {
                      Navigator.pop(context);
                      HapticFeedback.lightImpact();
                      onBusinessClosed();
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Reject Pickup
                  _ActionMenuItem(
                    icon: Icons.cancel_rounded,
                    title: 'Reject Pickup',
                    subtitle: 'Cannot complete pickup for any reason',
                    color: Colors.red[600]!,
                    backgroundColor: Colors.red[50]!,
                    enabled: true,
                    onTap: () {
                      Navigator.pop(context);
                      HapticFeedback.lightImpact();
                      onReject();
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.orange[200]!),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[700],
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
}

class _ActionMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color backgroundColor;
  final bool enabled;
  final VoidCallback? onTap;

  const _ActionMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.backgroundColor,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? backgroundColor : Colors.red[25],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled ? color.withOpacity(0.2) : Colors.red[200]!,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: enabled ? color.withOpacity(0.1) : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: enabled ? color : Colors.red[300],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: enabled ? Colors.grey[800] : Colors.red[400],
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: enabled ? Colors.grey[600] : Colors.red[300],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (enabled) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: color.withOpacity(0.5),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
