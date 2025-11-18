import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pickup.dart';
import '../services/pickups_api_service.dart';

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
      
      // Group pickups by zone (city)
      final groupedPickups = _groupPickupsByZone(activePickups);
      
      state = AsyncValue.data(groupedPickups);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Group pickups by their zone (city)
  Map<String, List<Pickup>> _groupPickupsByZone(List<Pickup> pickups) {
    final Map<String, List<Pickup>> grouped = {};
    
    for (final pickup in pickups) {
      // Use merchant city as the zone
      final zone = pickup.merchantCity;
      
      if (!grouped.containsKey(zone)) {
        grouped[zone] = [];
      }
      grouped[zone]!.add(pickup);
    }
    
    // Sort zones alphabetically
    final sortedKeys = grouped.keys.toList()..sort();
    final sortedMap = <String, List<Pickup>>{};
    for (final key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }
    
    return sortedMap;
  }

  /// Refresh pickups
  Future<void> refresh() async {
    await _loadPickups();
  }
}
