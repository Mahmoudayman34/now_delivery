import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/pickup.dart';

class PickupActionButtons extends StatelessWidget {
  final Pickup pickup;
  final VoidCallback onComplete;
  final VoidCallback onBusinessClosed;
  final VoidCallback onReject;

  const PickupActionButtons({
    super.key,
    required this.pickup,
    required this.onComplete,
    required this.onBusinessClosed,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
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
              
              // Complete Pickup Button - Primary Action
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: pickup.orders.isNotEmpty
                      ? LinearGradient(
                          colors: [Colors.green[400]!, Colors.green[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: pickup.orders.isEmpty ? Colors.grey[300] : null,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: pickup.orders.isNotEmpty
                      ? [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: pickup.orders.isNotEmpty 
                        ? () {
                            HapticFeedback.mediumImpact();
                            onComplete();
                          }
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: pickup.orders.isNotEmpty ? Colors.white : Colors.grey[500],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Complete Pickup',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: pickup.orders.isNotEmpty ? Colors.white : Colors.grey[500],
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              if (pickup.orders.isEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange[200]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_rounded,
                        color: Colors.orange[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Add at least one order to complete pickup',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 20),
              
              // Secondary Actions Row
              Row(
                children: [
                  // Business Closed Button
                  Expanded(
                    child: _SecondaryActionButton(
                      icon: Icons.store_mall_directory_rounded,
                      label: 'Business\nClosed',
                      color: Colors.grey[600]!,
                      backgroundColor: Colors.grey[50]!,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onBusinessClosed();
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Reject Pickup Button
                  Expanded(
                    child: _SecondaryActionButton(
                      icon: Icons.cancel_rounded,
                      label: 'Reject\nPickup',
                      color: Colors.red[600]!,
                      backgroundColor: Colors.red[50]!,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onReject();
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Help Text
              Text(
                'Choose an action to complete this pickup',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                    height: 1.2,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PickupActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const PickupActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      );
    }

    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
