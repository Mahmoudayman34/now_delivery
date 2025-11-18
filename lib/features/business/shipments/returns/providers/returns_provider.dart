import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/return_shipment.dart';
import '../services/returns_api_service.dart';

/// Provider for managing returns data
final returnsProvider = StateNotifierProvider<ReturnsNotifier, AsyncValue<Map<String, List<ReturnShipment>>>>((ref) {
  return ReturnsNotifier();
});

/// Notifier for returns management with zone-based grouping
class ReturnsNotifier extends StateNotifier<AsyncValue<Map<String, List<ReturnShipment>>>> {
  ReturnsNotifier() : super(const AsyncValue.loading()) {
    _loadReturns();
  }

  /// Load returns from API
  Future<void> _loadReturns() async {
    state = const AsyncValue.loading();
    
    try {
      // Fetch returns from API
      final returns = await ReturnsApiService.fetchReturns();
      
      // Group returns by zone
      final groupedReturns = _groupReturnsByZone(returns);
      
      state = AsyncValue.data(groupedReturns);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Group returns by their zone
  Map<String, List<ReturnShipment>> _groupReturnsByZone(List<ReturnShipment> returns) {
    final Map<String, List<ReturnShipment>> grouped = {};
    
    for (final returnShipment in returns) {
      // Use zone field from API
      final zone = returnShipment.zone;
      
      if (!grouped.containsKey(zone)) {
        grouped[zone] = [];
      }
      grouped[zone]!.add(returnShipment);
    }
    
    // Sort zones alphabetically
    final sortedKeys = grouped.keys.toList()..sort();
    final sortedMap = <String, List<ReturnShipment>>{};
    for (final key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }
    
    return sortedMap;
  }

  /// Refresh returns
  Future<void> refresh() async {
    await _loadReturns();
  }
}
