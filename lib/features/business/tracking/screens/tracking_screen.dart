import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/location_tracking_provider.dart';
import '../../../../core/services/location_service.dart';
import 'package:intl/intl.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize tracking on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationTrackingProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(locationTrackingProvider);
    final locationStream = ref.watch(locationStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracking'),
        actions: [
          IconButton(
            icon: Icon(
              trackingState.isSocketConnected
                  ? Icons.cloud_done
                  : Icons.cloud_off,
              color: trackingState.isSocketConnected
                  ? Colors.green
                  : Colors.grey,
            ),
            onPressed: () {
              ref.read(locationTrackingProvider.notifier).refreshSocketStatus();
            },
            tooltip: trackingState.isSocketConnected
                ? 'Connected to server'
                : 'Disconnected from server',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(locationTrackingProvider.notifier).checkLocationStatus();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tracking Status Card
              _buildStatusCard(trackingState, context),
              
              const SizedBox(height: 16),
              
              // Current Location Card
              locationStream.when(
                data: (position) {
                  if (position != null) {
                    return _buildLocationCard(position);
                  }
                  return _buildNoLocationCard();
                },
                loading: () => _buildLoadingCard(),
                error: (error, stack) => _buildErrorCard(error.toString()),
              ),
              
              const SizedBox(height: 16),
              
              // Tracking Controls
              _buildControlsCard(trackingState, context),
              
              const SizedBox(height: 16),
              
              // Error Message
              if (trackingState.errorMessage != null)
                _buildErrorMessage(trackingState.errorMessage!, context),
              
              const SizedBox(height: 16),
              
              // Info Card
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(trackingState, BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  trackingState.isTracking
                      ? Icons.location_on
                      : Icons.location_off,
                  color: trackingState.isTracking
                      ? Colors.green
                      : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tracking Status',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trackingState.isTracking ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: trackingState.isTracking
                              ? Colors.green
                              : Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: trackingState.isLocationTrackingEnabled
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    trackingState.isLocationTrackingEnabled
                        ? 'Enabled'
                        : 'Disabled',
                    style: TextStyle(
                      color: trackingState.isLocationTrackingEnabled
                          ? Colors.green
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatusItem(
                    icon: Icons.wifi,
                    label: 'Connection',
                    value: trackingState.isSocketConnected
                        ? 'Connected'
                        : 'Disconnected',
                    isActive: trackingState.isSocketConnected,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusItem(
                    icon: Icons.my_location,
                    label: 'GPS',
                    value: trackingState.isTracking ? 'Active' : 'Inactive',
                    isActive: trackingState.isTracking,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isActive,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: isActive ? Colors.green : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(position) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Current Location',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildLocationRow(
              'Latitude',
              position.latitude.toStringAsFixed(6),
            ),
            const SizedBox(height: 8),
            _buildLocationRow(
              'Longitude',
              position.longitude.toStringAsFixed(6),
            ),
            const SizedBox(height: 8),
            _buildLocationRow(
              'Accuracy',
              '${position.accuracy.toStringAsFixed(2)} meters',
            ),
            const SizedBox(height: 8),
            _buildLocationRow(
              'Time',
              DateFormat('HH:mm:ss').format(position.timestamp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildNoLocationCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(
              Icons.location_off,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            const Text(
              'No location data available',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return const Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      elevation: 2,
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsCard(trackingState, BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Controls',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Location Tracking'),
              subtitle: const Text('Allow server to track your location'),
              value: trackingState.isLocationTrackingEnabled,
              onChanged: trackingState.isLoading
                  ? null
                  : (value) {
                      ref
                          .read(locationTrackingProvider.notifier)
                          .toggleLocationTracking(value, context: context);
                    },
              secondary: Icon(
                trackingState.isLocationTrackingEnabled
                    ? Icons.toggle_on
                    : Icons.toggle_off,
                color: trackingState.isLocationTrackingEnabled
                    ? Colors.green
                    : Colors.grey,
              ),
            ),
            const Divider(),
            if (trackingState.isLocationTrackingEnabled) ...[
              ElevatedButton.icon(
                onPressed: trackingState.isLoading || trackingState.isTracking
                    ? null
                    : () {
                        ref
                            .read(locationTrackingProvider.notifier)
                            .startTracking(context: context);
                      },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Tracking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: trackingState.isLoading || !trackingState.isTracking
                    ? null
                    : () {
                        ref
                            .read(locationTrackingProvider.notifier)
                            .stopTracking();
                      },
                icon: const Icon(Icons.stop),
                label: const Text('Stop Tracking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message, BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                ref.read(locationTrackingProvider.notifier).clearError();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Tracking Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Update Interval', 'Every 25 seconds'),
            const SizedBox(height: 8),
            _buildInfoRow('Background Fallback', 'Every 15 minutes'),
            const SizedBox(height: 8),
            _buildInfoRow('GPS Accuracy', 'High'),
            const SizedBox(height: 12),
            const Text(
              'Your location is sent to the server every 25 seconds via Socket.IO (real-time) and REST API (backup) to ensure reliable tracking. Keep app in foreground for optimal 25-second updates.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}


