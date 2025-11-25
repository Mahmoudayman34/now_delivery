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
    
    // Sort items within each zone: newest first, express first on same day
    for (final zone in grouped.keys) {
      grouped[zone]!.sort((a, b) {
        // Check if both are from the same day
        final aDate = DateTime(a.orderDate.year, a.orderDate.month, a.orderDate.day);
        final bDate = DateTime(b.orderDate.year, b.orderDate.month, b.orderDate.day);
        final sameDay = aDate == bDate;
        
        // If same day, express orders come first
        if (sameDay) {
          if (a.isExpressShipping && !b.isExpressShipping) return -1;
          if (!a.isExpressShipping && b.isExpressShipping) return 1;
        }
        
        // Sort by date (newest first)
        return b.orderDate.compareTo(a.orderDate);
      });
    }
    
    // Sort zones by most recent order date in each zone
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) {
        // Get the most recent order date from each zone
        final aLatestDate = a.value.isNotEmpty 
            ? a.value.map((o) => o.orderDate).reduce((a, b) => a.isAfter(b) ? a : b)
            : DateTime(1970);
        final bLatestDate = b.value.isNotEmpty
            ? b.value.map((o) => o.orderDate).reduce((a, b) => a.isAfter(b) ? a : b)
            : DateTime(1970);
        
        // Sort by most recent date (newest first)
        return bLatestDate.compareTo(aLatestDate);
      });
    
    return Map.fromEntries(sortedEntries);
  }



  /// Refresh orders
  Future<void> refresh() async {
    await _loadOrders();
  }
}
