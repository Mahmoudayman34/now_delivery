import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../services/orders_api_service.dart';
import 'package:flutter_riverpod/legacy.dart';
/// Provider for managing orders data
final ordersProvider = StateNotifierProvider<OrdersNotifier, AsyncValue<Map<String, List<Order>>>>((ref) {
  return OrdersNotifier();
});

/// Notifier for orders management with zone-based grouping
class OrdersNotifier extends StateNotifier<AsyncValue<Map<String, List<Order>>>> {
  OrdersNotifier() : super(const AsyncValue.loading()) {
    _loadOrders();
  }

  /// Load orders from API
  Future<void> _loadOrders() async {
    state = const AsyncValue.loading();
    
    try {
      // Fetch orders from API
      final orders = await OrdersApiService.fetchOrders();
      
      // Filter out completed and delivered orders
      final activeOrders = orders.where((order) => 
        order.status != OrderStatus.completed && 
        order.status != OrderStatus.delivered
      ).toList();
      
      // Group orders by zone
      final groupedOrders = _groupOrdersByZone(activeOrders);
      
      state = AsyncValue.data(groupedOrders);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Group orders by their delivery zone
  Map<String, List<Order>> _groupOrdersByZone(List<Order> orders) {
    final Map<String, List<Order>> grouped = {};
    
    for (final order in orders) {
      // Use the zone from the order model
      final zone = order.zone;
      
      if (!grouped.containsKey(zone)) {
        grouped[zone] = [];
      }
      grouped[zone]!.add(order);
    }
    
    // Sort zones alphabetically
    final sortedKeys = grouped.keys.toList()..sort();
    final sortedMap = <String, List<Order>>{};
    for (final key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }
    
    return sortedMap;
  }



  /// Refresh orders
  Future<void> refresh() async {
    await _loadOrders();
  }
}
