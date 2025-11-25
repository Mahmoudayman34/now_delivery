import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pickup.dart';
import '../services/pickups_api_service.dart';
import 'package:flutter_riverpod/legacy.dart';
/// Provider for managing pickups data
final pickupsProvider = StateNotifierProvider<PickupsNotifier, AsyncValue<Map<String, List<Pickup>>>>((ref) {
  return PickupsNotifier();
});

/// Notifier for pickups management with zone-based grouping
class PickupsNotifier extends StateNotifier<AsyncValue<Map<String, List<Pickup>>>> {
  PickupsNotifier() : super(const AsyncValue.loading()) {
    _loadPickups();
  }

  /// Load pickups from API
  Future<void> _loadPickups() async {
    state = const AsyncValue.loading();
    
    try {
      // Fetch pickups from API
      final pickups = await PickupsApiService.fetchPickups();
      
      // Filter out completed pickups
      final activePickups = pickups.where((pickup) => pickup.status != PickupStatus.completed).toList();
      
      // Group pickups by zone
      final groupedPickups = _groupPickupsByZone(activePickups);
      
      state = AsyncValue.data(groupedPickups);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Group pickups by their zone
  Map<String, List<Pickup>> _groupPickupsByZone(List<Pickup> pickups) {
    final Map<String, List<Pickup>> grouped = {};
    
    for (final pickup in pickups) {
      // Use merchant zone for grouping
      final zone = pickup.merchantZone;
      
      if (!grouped.containsKey(zone)) {
        grouped[zone] = [];
      }
      grouped[zone]!.add(pickup);
    }
    
    // Sort items within each zone by date (newest first)
    for (final zone in grouped.keys) {
      grouped[zone]!.sort((a, b) {
        // Sort by pickup date (newest first)
        return b.pickupDate.compareTo(a.pickupDate);
      });
    }
    
    // Sort zones by most recent pickup date in each zone
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) {
        // Get the most recent pickup date from each zone
        final aLatestDate = a.value.isNotEmpty 
            ? a.value.map((p) => p.pickupDate).reduce((a, b) => a.isAfter(b) ? a : b)
            : DateTime(1970);
        final bLatestDate = b.value.isNotEmpty
            ? b.value.map((p) => p.pickupDate).reduce((a, b) => a.isAfter(b) ? a : b)
            : DateTime(1970);
        
        // Sort by most recent date (newest first)
        return bLatestDate.compareTo(aLatestDate);
      });
    
    return Map.fromEntries(sortedEntries);
  }

  /// Refresh pickups
  Future<void> refresh() async {
    await _loadPickups();
  }
}
