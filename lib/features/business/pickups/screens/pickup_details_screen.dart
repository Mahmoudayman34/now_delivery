import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/pickup.dart';
import '../providers/pickup_provider.dart';
import '../widgets/order_scanner_dialog.dart';
import '../widgets/pickup_action_menu.dart';

class PickupDetailsScreen extends ConsumerStatefulWidget {
  final Pickup pickup;

  const PickupDetailsScreen({
    super.key,
    required this.pickup,
  });

  @override
  ConsumerState<PickupDetailsScreen> createState() => _PickupDetailsScreenState();
}

class _PickupDetailsScreenState extends ConsumerState<PickupDetailsScreen> {
  final _orderCodeController = TextEditingController();

  @override
  void dispose() {
    _orderCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pickupState = ref.watch(pickupProvider);
    
    // Find the current pickup in the state (it might have been updated)
    final currentPickup = pickupState.assignedPickups
        .where((p) => p.id == widget.pickup.id)
        .firstOrNull ?? 
        pickupState.completedPickups
        .where((p) => p.id == widget.pickup.id)
        .firstOrNull ?? 
        widget.pickup;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getStatusColor(currentPickup.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.store_rounded,
                color: _getStatusColor(currentPickup.status),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentPickup.business.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Pickup Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        surfaceTintColor: Colors.transparent,
        actions: [],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: Theme.of(context).primaryColor,
              backgroundColor: Colors.white,
              strokeWidth: 3.0,
              displacement: 60.0,
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                await ref.read(pickupProvider.notifier).loadPickups();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BusinessInfoCard(pickup: currentPickup),
                  _PickupInfoCard(pickup: currentPickup),
                  if (!currentPickup.isCompleted) ...[
                    _OrderCollectionCard(
                      pickup: currentPickup,
                      onScanBarcode: _showScannerDialog,
                      onAddManually: _showManualEntryDialog,
                      onRemoveOrder: (orderCode) {
                        _removeOrder(currentPickup.id, orderCode);
                      },
                    ),
                  ] else ...[
                    _CompletedOrdersCard(pickup: currentPickup),
                  ],
                ],
              ),
            ),
          ),
            ),
        ],
      ),
      floatingActionButton: !currentPickup.isCompleted
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[400]!, Colors.orange[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showActionMenu(currentPickup),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.more_horiz_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  void _showActionMenu(Pickup pickup) {
    PickupActionMenu.show(
      context: context,
      pickup: pickup,
      onComplete: () => _completePickup(pickup),
      onBusinessClosed: () => _markBusinessClosed(pickup),
      onReject: () => _showRejectDialog(pickup),
    );
  }

  void _showScannerDialog() {
    showDialog(
      context: context,
      builder: (context) => OrderScannerDialog(
        onOrderScanned: (orderCode) {
          _addOrder(widget.pickup.id, orderCode);
        },
      ),
    );
  }

  void _showManualEntryDialog() {
    _orderCodeController.clear();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 16,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
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
                          'Add Order Manually',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[800],
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enter the order code',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Input Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: TextField(
                  controller: _orderCodeController,
                  decoration: InputDecoration(
                    hintText: 'e.g., ORD123, ORDER456',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: Icon(
                      Icons.qr_code_rounded,
                      color: Colors.grey[500],
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange[400]!, Colors.orange[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final orderCode = _orderCodeController.text.trim().toUpperCase();
                            if (orderCode.isNotEmpty) {
                              Navigator.of(context).pop();
                              HapticFeedback.lightImpact();
                              _addOrder(widget.pickup.id, orderCode);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Add Order',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRejectDialog(Pickup pickup) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Pickup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejecting this pickup:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'e.g., Incorrect address, Business refused',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isNotEmpty) {
                Navigator.of(context).pop();
                _rejectPickup(pickup, reason);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _addOrder(String pickupId, String orderCode) async {
    await ref.read(pickupProvider.notifier).addOrderToPickup(pickupId, orderCode);
    
    if (mounted) {
      
      // Show success or error message
      final error = ref.read(pickupProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(pickupProvider.notifier).clearError();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order $orderCode added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _removeOrder(String pickupId, String orderCode) async {
    await ref.read(pickupProvider.notifier).removeOrderFromPickup(pickupId, orderCode);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order $orderCode removed'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _completePickup(Pickup pickup) async {
    await ref.read(pickupProvider.notifier).updatePickupStatus(
      pickup.id, 
      PickupStatus.completed,
    );
    
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pickup completed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _markBusinessClosed(Pickup pickup) async {
    await ref.read(pickupProvider.notifier).updatePickupStatus(
      pickup.id, 
      PickupStatus.businessClosed,
    );
    
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pickup marked as business closed'),
          backgroundColor: Colors.grey,
        ),
      );
    }
  }

  Future<void> _rejectPickup(Pickup pickup, String reason) async {
    await ref.read(pickupProvider.notifier).updatePickupStatus(
      pickup.id, 
      PickupStatus.rejected,
      rejectionReason: reason,
    );
    
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pickup rejected'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

class _BusinessInfoCard extends StatelessWidget {
  final Pickup pickup;

  const _BusinessInfoCard({required this.pickup});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pickup.business.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Business Information',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[700],
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _ContactItem(
              icon: Icons.location_on_rounded,
              title: 'Address',
              subtitle: pickup.business.address,
              onTap: () => _openInMaps(pickup.business.address),
              actionIcon: Icons.navigation_rounded,
            ),
            if (pickup.business.phone != null) ...[
              const SizedBox(height: 16),
              _ContactItem(
                icon: Icons.phone_rounded,
                title: 'Phone',
                subtitle: pickup.business.phone!,
                onTap: () => _makePhoneCall(pickup.business.phone!),
                actionIcon: Icons.call_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openInMaps(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final url = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}

class _PickupInfoCard extends StatelessWidget {
  final Pickup pickup;

  const _PickupInfoCard({required this.pickup});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pickup Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    label: 'Pickup ID',
                    value: pickup.id.toUpperCase(),
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    label: 'Status',
                    value: pickup.status.displayName,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    label: 'Scheduled Time',
                    value: DateFormat('MMM d, yyyy HH:mm').format(pickup.scheduledTime),
                  ),
                ),
                if (pickup.completedAt != null)
                  Expanded(
                    child: _InfoItem(
                      label: 'Completed At',
                      value: DateFormat('MMM d, yyyy HH:mm').format(pickup.completedAt!),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCollectionCard extends StatelessWidget {
  final Pickup pickup;
  final VoidCallback onScanBarcode;
  final VoidCallback onAddManually;
  final Function(String) onRemoveOrder;

  const _OrderCollectionCard({
    required this.pickup,
    required this.onScanBarcode,
    required this.onAddManually,
    required this.onRemoveOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Picked-up Orders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${pickup.orders.length} orders',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange[400]!, Colors.orange[600]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onScanBarcode();
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.qr_code_scanner_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Scan Barcode',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.orange[200]!,
                        width: 2,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onAddManually();
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                color: Colors.orange[700],
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Manual Entry',
                                  style: TextStyle(
                                    color: Colors.orange[700],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (pickup.orders.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              ...pickup.orders.map((order) => _OrderItem(
                order: order,
                onRemove: () => onRemoveOrder(order.orderCode),
              )),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompletedOrdersCard extends StatelessWidget {
  final Pickup pickup;

  const _CompletedOrdersCard({required this.pickup});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Collected Orders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${pickup.orders.length} orders',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (pickup.orders.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...pickup.orders.map((order) => _OrderItem(
                order: order,
                isReadOnly: true,
              )),
            ] else ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'No orders were collected',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final IconData? actionIcon;

  const _ContactItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (onTap != null) {
              HapticFeedback.lightImpact();
              onTap!();
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Colors.grey[700],
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
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      actionIcon ?? Icons.open_in_new_rounded,
                      size: 16,
                      color: Colors.orange[600],
                    ),
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

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _OrderItem extends StatelessWidget {
  final PickupOrder order;
  final VoidCallback? onRemove;
  final bool isReadOnly;

  const _OrderItem({
    required this.order,
    this.onRemove,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              order.orderCode,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (!isReadOnly && onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(
                Icons.remove_circle_outline,
                color: Colors.red,
                size: 20,
              ),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}
