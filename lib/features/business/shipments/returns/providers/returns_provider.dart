import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/return_shipment.dart';
import '../services/returns_api_service.dart';
import 'package:flutter_riverpod/legacy.dart';

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
    
    // Sort items within each zone: newest first, express first on same day
    for (final zone in grouped.keys) {
      grouped[zone]!.sort((a, b) {
        // Check if both are from the same day
        final aDate = DateTime(a.orderDate.year, a.orderDate.month, a.orderDate.day);
        final bDate = DateTime(b.orderDate.year, b.orderDate.month, b.orderDate.day);
        final sameDay = aDate == bDate;
        
        // If same day, express returns come first
        if (sameDay) {
          if (a.isExpressShipping && !b.isExpressShipping) return -1;
          if (!a.isExpressShipping && b.isExpressShipping) return 1;
        }
        
        // Sort by date (newest first)
        return b.orderDate.compareTo(a.orderDate);
      });
    }
    
    // Sort zones by most recent return date in each zone
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) {
        // Get the most recent return date from each zone
        final aLatestDate = a.value.isNotEmpty 
            ? a.value.map((r) => r.orderDate).reduce((a, b) => a.isAfter(b) ? a : b)
            : DateTime(1970);
        final bLatestDate = b.value.isNotEmpty
            ? b.value.map((r) => r.orderDate).reduce((a, b) => a.isAfter(b) ? a : b)
            : DateTime(1970);
        
        // Sort by most recent date (newest first)
        return bLatestDate.compareTo(aLatestDate);
      });
    
    return Map.fromEntries(sortedEntries);
  }

  /// Refresh returns
  Future<void> refresh() async {
    await _loadReturns();
  }
}
