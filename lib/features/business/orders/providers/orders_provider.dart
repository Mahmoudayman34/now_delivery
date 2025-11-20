import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import 'package:flutter_riverpod/legacy.dart';
final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  return OrdersNotifier();
});

final filteredOrdersProvider = Provider<List<Order>>((ref) {
  final ordersState = ref.watch(ordersProvider);
  final orders = ordersState.orders;
  final selectedStatus = ordersState.selectedStatus;
  final selectedZones = ordersState.selectedZones;

  return orders.where((order) {
    // Filter by status
    if (selectedStatus != null && order.status != selectedStatus) {
      return false;
    }

    // Filter by zones
    if (selectedZones.isNotEmpty && !selectedZones.contains(order.zone)) {
      return false;
    }

    return true;
  }).toList();
});

final activeOrdersProvider = Provider<List<Order>>((ref) {
  final ordersState = ref.watch(ordersProvider);
  return ordersState.orders.where((order) {
    return order.status == OrderStatus.assigned ||
           order.status == OrderStatus.pickedUp ||
           order.status == OrderStatus.inTransit;
  }).toList();
});

final availableZonesProvider = Provider<List<String>>((ref) {
  final ordersState = ref.watch(ordersProvider);
  final zones = ordersState.orders.map((order) => order.zone).toSet().toList();
  zones.sort();
  return zones;
});

class OrdersNotifier extends StateNotifier<OrdersState> {
  OrdersNotifier() : super(const OrdersState()) {
    _loadMockData();
  }

  /// Load mock orders data
  void _loadMockData() {
    final mockOrders = [
      Order(
        id: 'ORD001',
        pickupLocation: 'McDonald\'s Downtown',
        dropoffLocation: '123 Main Street',
        pickupAddress: '456 Business Ave, Downtown',
        dropoffAddress: '123 Main Street, Residential Area',
        type: OrderType.express,
        status: OrderStatus.assigned,
        distance: 2.5,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        zone: 'Downtown',
        customerName: 'John Doe',
        customerPhone: '+1234567890',
        latitude: 40.7128,
        longitude: -74.0060,
      ),
      Order(
        id: 'ORD002',
        pickupLocation: 'Pizza Palace',
        dropoffLocation: 'Oak Street Apartments',
        pickupAddress: '789 Food Court, Mall District',
        dropoffAddress: '456 Oak Street, Apt 3B',
        type: OrderType.normal,
        status: OrderStatus.readyForPickup,
        distance: 1.8,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        zone: 'North',
        customerName: 'Jane Smith',
        customerPhone: '+1234567891',
        latitude: 40.7589,
        longitude: -73.9851,
      ),
      Order(
        id: 'ORD003',
        pickupLocation: 'Burger King',
        dropoffLocation: 'University Campus',
        pickupAddress: '321 Fast Food Lane',
        dropoffAddress: 'Building A, Room 205',
        type: OrderType.scheduled,
        status: OrderStatus.pending,
        distance: 3.2,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        pickupTime: DateTime.now().add(const Duration(hours: 2)),
        zone: 'East',
        customerName: 'Mike Johnson',
        customerPhone: '+1234567892',
        latitude: 40.6892,
        longitude: -74.0445,
      ),
      Order(
        id: 'ORD004',
        pickupLocation: 'Starbucks Central',
        dropoffLocation: 'Corporate Plaza',
        pickupAddress: '654 Coffee Street',
        dropoffAddress: '987 Business Plaza, Floor 15',
        type: OrderType.express,
        status: OrderStatus.pickedUp,
        distance: 4.1,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        zone: 'West',
        customerName: 'Sarah Wilson',
        customerPhone: '+1234567893',
        latitude: 40.7505,
        longitude: -73.9934,
      ),
      Order(
        id: 'ORD005',
        pickupLocation: 'Subway Station Mall',
        dropoffLocation: 'Residential Complex',
        pickupAddress: '147 Mall Avenue',
        dropoffAddress: '258 Residential Drive',
        type: OrderType.normal,
        status: OrderStatus.delivered,
        distance: 2.0,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        deliveryTime: DateTime.now().subtract(const Duration(minutes: 30)),
        zone: 'South',
        customerName: 'Robert Brown',
        customerPhone: '+1234567894',
        latitude: 40.7282,
        longitude: -74.0776,
      ),
    ];

    state = state.copyWith(orders: mockOrders, isLoading: false);
  }

  /// Set status filter
  void setStatusFilter(OrderStatus? status) {
    if (status == null) {
      state = state.copyWith(clearSelectedStatus: true);
    } else {
      state = state.copyWith(selectedStatus: status);
    }
  }

  /// Toggle zone filter
  void toggleZoneFilter(String zone) {
    final currentZones = List<String>.from(state.selectedZones);
    if (currentZones.contains(zone)) {
      currentZones.remove(zone);
    } else {
      currentZones.add(zone);
    }
    state = state.copyWith(selectedZones: currentZones);
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(
      clearSelectedStatus: true,
      selectedZones: [],
    );
  }

  /// Update order status
  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final orders = state.orders.map((order) {
      if (order.id == orderId) {
        return order.copyWith(status: newStatus);
      }
      return order;
    }).toList();

    state = state.copyWith(orders: orders);
  }

  /// Refresh orders (load from local data)
  Future<void> refreshOrders() async {
    state = state.copyWith(isLoading: true);
    
    // Load local mock data
    _loadMockData();
  }
}

class OrdersState {
  final List<Order> orders;
  final bool isLoading;
  final OrderStatus? selectedStatus;
  final List<String> selectedZones;
  final String? errorMessage;

  const OrdersState({
    this.orders = const [],
    this.isLoading = true,
    this.selectedStatus,
    this.selectedZones = const [],
    this.errorMessage,
  });

  OrdersState copyWith({
    List<Order>? orders,
    bool? isLoading,
    OrderStatus? selectedStatus,
    bool clearSelectedStatus = false,
    List<String>? selectedZones,
    String? errorMessage,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      selectedStatus: clearSelectedStatus ? null : (selectedStatus ?? this.selectedStatus),
      selectedZones: selectedZones ?? this.selectedZones,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

