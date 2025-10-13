import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pickup_provider.dart';
import '../models/pickup.dart';
import '../widgets/pickup_card.dart';
import '../widgets/pickup_action_menu.dart';
import 'pickup_details_screen.dart';

class PickupScreen extends ConsumerStatefulWidget {
  const PickupScreen({super.key});

  @override
  ConsumerState<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends ConsumerState<PickupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Future<void> _completePickup(Pickup pickup) async {
    await ref.read(pickupProvider.notifier).updatePickupStatus(
      pickup.id, 
      PickupStatus.completed,
    );
    
    if (mounted) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pickup marked as business closed'),
          backgroundColor: Colors.grey,
        ),
      );
    }
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
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isNotEmpty) {
                Navigator.of(context).pop();
                await ref.read(pickupProvider.notifier).updatePickupStatus(
                  pickup.id, 
                  PickupStatus.rejected,
                  rejectionReason: reason,
                );
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pickup rejected'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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

  @override
  Widget build(BuildContext context) {
    final pickupState = ref.watch(pickupProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_shipping,
                color: Colors.orange[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pickups',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Manage your deliveries',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.orange[800],
        elevation: 0,
        shadowColor: Colors.orange.withOpacity(0.1),
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.orange[600],
                unselectedLabelColor: Colors.orange[400],
                indicatorColor: Colors.orange[600],
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Assigned'),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: pickupState.assignedPickups.isNotEmpty 
                                ? Colors.orange[600]
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${pickupState.assignedPickups.length}',
                            style: TextStyle(
                              color: pickupState.assignedPickups.isNotEmpty 
                                  ? Colors.white 
                                  : Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Completed'),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: pickupState.completedPickups.isNotEmpty 
                                ? Colors.green[600]
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${pickupState.completedPickups.length}',
                            style: TextStyle(
                              color: pickupState.completedPickups.isNotEmpty 
                                  ? Colors.white 
                                  : Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [],
      ),
      body: pickupState.isLoading
          ? const _LoadingWidget()
          : pickupState.error != null
              ? _ErrorWidget(
                  error: pickupState.error!,
                  onRetry: () {
                    ref.read(pickupProvider.notifier).clearError();
                    ref.read(pickupProvider.notifier).loadPickups();
                  },
                )
              : TabBarView(
                    controller: _tabController,
                    children: [
                      _PickupListView(
                        pickups: pickupState.assignedPickups,
                        emptyMessage: 'No assigned pickups',
                        emptySubtitle: 'New pickups will appear here',
                        onMenuTap: _showActionMenu,
                        onRefresh: () => ref.read(pickupProvider.notifier).loadPickups(),
                      ),
                      _PickupListView(
                        pickups: pickupState.completedPickups,
                        emptyMessage: 'No completed pickups',
                        emptySubtitle: 'Completed pickups will appear here',
                        onMenuTap: _showActionMenu,
                        onRefresh: () => ref.read(pickupProvider.notifier).loadPickups(),
                      ),
                    ],
                  ),
    );
  }
}

class _PickupListView extends StatelessWidget {
  final List<Pickup> pickups;
  final String emptyMessage;
  final String emptySubtitle;
  final Function(Pickup)? onMenuTap;
  final Future<void> Function()? onRefresh;

  const _PickupListView({
    required this.pickups,
    required this.emptyMessage,
    required this.emptySubtitle,
    this.onMenuTap,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (pickups.isEmpty) {
      return _EmptyStateWidget(
        message: emptyMessage,
        subtitle: emptySubtitle,
      );
    }

    return RefreshIndicator(
      color: Colors.orange[600],
      backgroundColor: Colors.white,
      strokeWidth: 3.0,
      displacement: 60.0,
      onRefresh: () async {
        // Add haptic feedback
        HapticFeedback.mediumImpact();
        // Refresh pickups with proper provider call
        if (onRefresh != null) {
          await onRefresh!();
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        itemCount: pickups.length,
        itemBuilder: (context, index) {
          final pickup = pickups[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 150 + (index * 50)),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.only(bottom: 16),
            child: PickupCard(
              pickup: pickup,
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        PickupDetailsScreen(pickup: pickup),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOutCubic;
                      
                      var tween = Tween(begin: begin, end: end).chain(
                        CurveTween(curve: curve),
                      );
                      
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              },
              onMenuTap: !pickup.isCompleted && onMenuTap != null
                  ? () {
                      HapticFeedback.lightImpact();
                      onMenuTap!(pickup);
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }

}

class _LoadingWidget extends StatefulWidget {
  const _LoadingWidget();

  @override
  State<_LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<_LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.orange[600]!,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading pickups...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we fetch your data',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorWidget({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  size: 48,
                  color: Colors.red[400],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onRetry();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStateWidget extends StatefulWidget {
  final String message;
  final String subtitle;

  const _EmptyStateWidget({
    required this.message,
    required this.subtitle,
  });

  @override
  State<_EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<_EmptyStateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_shipping_rounded,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
