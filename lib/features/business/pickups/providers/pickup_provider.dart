import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pickup.dart';

// State class for pickup management
class PickupState {
  final List<Pickup> assignedPickups;
  final List<Pickup> completedPickups;
  final bool isLoading;
  final String? error;

  const PickupState({
    this.assignedPickups = const [],
    this.completedPickups = const [],
    this.isLoading = false,
    this.error,
  });

  PickupState copyWith({
    List<Pickup>? assignedPickups,
    List<Pickup>? completedPickups,
    bool? isLoading,
    String? error,
  }) {
    return PickupState(
      assignedPickups: assignedPickups ?? this.assignedPickups,
      completedPickups: completedPickups ?? this.completedPickups,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Pickup provider
class PickupNotifier extends StateNotifier<PickupState> {
  PickupNotifier() : super(const PickupState()) {
    loadPickups();
  }

  Future<void> loadPickups() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Simulate API call - replace with actual API integration
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Mock data for demonstration
      final mockAssignedPickups = _generateMockAssignedPickups();
      final mockCompletedPickups = _generateMockCompletedPickups();
      
      state = state.copyWith(
        assignedPickups: mockAssignedPickups,
        completedPickups: mockCompletedPickups,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updatePickupStatus(String pickupId, PickupStatus status, {String? rejectionReason}) async {
    try {
      final pickup = _findPickupById(pickupId);
      if (pickup == null) return;

      final updatedPickup = pickup.copyWith(
        status: status,
        completedAt: status != PickupStatus.assigned && status != PickupStatus.inProgress 
            ? DateTime.now() 
            : null,
        rejectionReason: rejectionReason,
      );

      _updatePickupInState(updatedPickup);
      
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addOrderToPickup(String pickupId, String orderCode) async {
    try {
      final pickup = _findPickupById(pickupId);
      if (pickup == null) return;

      // Check if order already exists
      final existingOrder = pickup.orders.where((o) => o.orderCode == orderCode).firstOrNull;
      if (existingOrder != null) {
        state = state.copyWith(error: 'Order $orderCode already added');
        return;
      }

      final newOrder = PickupOrder(
        orderCode: orderCode,
        isCollected: true,
        collectedAt: DateTime.now(),
      );

      final updatedOrders = [...pickup.orders, newOrder];
      final updatedPickup = pickup.copyWith(
        orders: updatedOrders,
        status: PickupStatus.inProgress,
      );

      _updatePickupInState(updatedPickup);
      
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeOrderFromPickup(String pickupId, String orderCode) async {
    try {
      final pickup = _findPickupById(pickupId);
      if (pickup == null) return;

      final updatedOrders = pickup.orders.where((o) => o.orderCode != orderCode).toList();
      final updatedPickup = pickup.copyWith(orders: updatedOrders);

      _updatePickupInState(updatedPickup);
      
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Helper methods
  Pickup? _findPickupById(String pickupId) {
    try {
      return state.assignedPickups.firstWhere((p) => p.id == pickupId);
    } catch (e) {
      try {
        return state.completedPickups.firstWhere((p) => p.id == pickupId);
      } catch (e) {
        return null;
      }
    }
  }

  void _updatePickupInState(Pickup updatedPickup) {
    List<Pickup> newAssignedPickups = [...state.assignedPickups];
    List<Pickup> newCompletedPickups = [...state.completedPickups];

    // Remove from current list
    newAssignedPickups.removeWhere((p) => p.id == updatedPickup.id);
    newCompletedPickups.removeWhere((p) => p.id == updatedPickup.id);

    // Add to appropriate list based on status
    if (updatedPickup.isCompleted) {
      newCompletedPickups.insert(0, updatedPickup);
    } else {
      newAssignedPickups = newAssignedPickups.map((p) => 
        p.id == updatedPickup.id ? updatedPickup : p
      ).toList();
      if (!newAssignedPickups.any((p) => p.id == updatedPickup.id)) {
        newAssignedPickups.add(updatedPickup);
      }
    }

    state = state.copyWith(
      assignedPickups: newAssignedPickups,
      completedPickups: newCompletedPickups,
    );
  }

  // Mock data generators
  List<Pickup> _generateMockAssignedPickups() {
    return [
      Pickup(
        id: 'pickup_001',
        businessId: 'business_001',
        business: const Business(
          id: 'business_001',
          name: 'Pizza Palace',
          address: '123 Main Street, Downtown',
          phone: '+1-234-567-8900',
          logoUrl: null,
          latitude: 40.7128,
          longitude: -74.0060,
        ),
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
        status: PickupStatus.assigned,
        orders: const [],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Pickup(
        id: 'pickup_002',
        businessId: 'business_002',
        business: const Business(
          id: 'business_002',
          name: 'Burger Barn',
          address: '456 Oak Avenue, Midtown',
          phone: '+1-234-567-8901',
          logoUrl: null,
          latitude: 40.7589,
          longitude: -73.9851,
        ),
        scheduledTime: DateTime.now().add(const Duration(minutes: 30)),
        status: PickupStatus.inProgress,
        orders: const [
          PickupOrder(
            orderCode: 'ORD001',
            isCollected: true,
            collectedAt: null,
          ),
          PickupOrder(
            orderCode: 'ORD002',
            isCollected: true,
            collectedAt: null,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Pickup(
        id: 'pickup_003',
        businessId: 'business_003',
        business: const Business(
          id: 'business_003',
          name: 'Sushi Spot',
          address: '789 Pine Road, Uptown',
          phone: '+1-234-567-8902',
          logoUrl: null,
          latitude: 40.7831,
          longitude: -73.9712,
        ),
        scheduledTime: DateTime.now().add(const Duration(hours: 2)),
        status: PickupStatus.assigned,
        orders: const [],
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];
  }

  List<Pickup> _generateMockCompletedPickups() {
    return [
      Pickup(
        id: 'pickup_004',
        businessId: 'business_004',
        business: const Business(
          id: 'business_004',
          name: 'Coffee Corner',
          address: '321 Elm Street, Downtown',
          phone: '+1-234-567-8903',
          logoUrl: null,
        ),
        scheduledTime: DateTime.now().subtract(const Duration(hours: 3)),
        status: PickupStatus.completed,
        orders: const [
          PickupOrder(
            orderCode: 'ORD003',
            isCollected: true,
            collectedAt: null,
          ),
          PickupOrder(
            orderCode: 'ORD004',
            isCollected: true,
            collectedAt: null,
          ),
          PickupOrder(
            orderCode: 'ORD005',
            isCollected: true,
            collectedAt: null,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        completedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Pickup(
        id: 'pickup_005',
        businessId: 'business_005',
        business: const Business(
          id: 'business_005',
          name: 'Taco Time',
          address: '654 Maple Drive, Southside',
          phone: null,
          logoUrl: null,
        ),
        scheduledTime: DateTime.now().subtract(const Duration(hours: 5)),
        status: PickupStatus.businessClosed,
        orders: const [],
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        completedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ];
  }
}

final pickupProvider = StateNotifierProvider<PickupNotifier, PickupState>((ref) {
  return PickupNotifier();
});
