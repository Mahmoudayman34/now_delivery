import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/shop_order.dart';
import '../services/shop_orders_api_service.dart';

/// Provider for shop orders list
final shopOrdersProvider = StateNotifierProvider<ShopOrdersNotifier, AsyncValue<List<ShopOrder>>>((ref) {
  return ShopOrdersNotifier();
});

/// Notifier for managing shop orders state
class ShopOrdersNotifier extends StateNotifier<AsyncValue<List<ShopOrder>>> {
  ShopOrdersNotifier() : super(const AsyncValue.loading()) {
    fetchOrders();
  }

  String? _currentStatusFilter;

  /// Fetch shop orders with optional status filter
  Future<void> fetchOrders({String? status}) async {
    _currentStatusFilter = status;
    state = const AsyncValue.loading();
    
    try {
      final orders = await ShopOrdersApiService.fetchShopOrders(status: status);
      state = AsyncValue.data(orders);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Refresh shop orders with current filter
  Future<void> refresh() async {
    await fetchOrders(status: _currentStatusFilter);
  }
}
