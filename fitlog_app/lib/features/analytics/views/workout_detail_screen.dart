import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';
import 'package:fitlog_app/features/tracking/widgets/metric_card.dart';
import 'package:fitlog_app/features/analytics/providers/analytics_providers.dart';
import 'package:fitlog_app/shared/extensions/duration_extensions.dart';
import 'package:fitlog_app/core/utils/pace_calculator.dart';

/// A premium screen presenting the post-workout analysis,
/// including a static route map and a grid of summary metrics.
class WorkoutDetailScreen extends ConsumerWidget {
  final int workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutAsync = ref.watch(workoutDetailProvider(workoutId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Summary'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: workoutAsync.when(
        data: (workout) {
          if (workout == null) {
            return const Center(child: Text('Workout not found'));
          }
          return _buildContent(context, workout);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Workout workout) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gpsPoints = workout.gpsPoints.toList();
    final List<LatLng> routePoints = gpsPoints
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    // Setup dates formatting manually
    final startFormatted = _formatDateTime(workout.startTime);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Sport Header / Title card
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  workout.sportType == 'cycling'
                      ? Icons.directions_bike
                      : Icons.directions_run,
                  color: colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name ??
                          '${workout.sportType.toUpperCase()} WORKOUT',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      startFormatted,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Static Route Map
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: routePoints.isNotEmpty
                  ? FlutterMap(
                      options: MapOptions(
                        initialCameraFit: CameraFit.bounds(
                          bounds: LatLngBounds.fromPoints(routePoints),
                          padding: const EdgeInsets.all(32.0),
                        ),
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.madcoder.fitlog',
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: routePoints,
                              color: colorScheme.primary,
                              strokeWidth: 5.0,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            // Start marker (Green)
                            Marker(
                              point: routePoints.first,
                              width: 16,
                              height: 16,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            // End marker (Red)
                            Marker(
                              point: routePoints.last,
                              width: 16,
                              height: 16,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Container(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 48,
                            color: colorScheme.onSurface.withOpacity(0.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No GPS route recorded',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 28),

          // 3. Grid of Summary Metrics
          const Text(
            'PERFORMANCE STATISTICS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildMetricsGrid(workout),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(Workout workout) {
    final duration = Duration(seconds: workout.durationSeconds.toInt());
    final distanceKm = workout.distanceMeters / 1000.0;

    final averageSpeedKmH = workout.averageSpeed != null
        ? workout.averageSpeed! * 3.6
        : 0.0;
    final maxSpeedKmH = workout.maxSpeed != null
        ? workout.maxSpeed! * 3.6
        : 0.0;

    final pace = PaceCalculator.calculateAveragePaceMinPerKm(
      duration,
      workout.distanceMeters,
    );

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        MetricCard(
          label: 'Distance',
          value: distanceKm.toStringAsFixed(2),
          unit: 'km',
          icon: Icons.directions_run,
          iconColor: Colors.green,
        ),
        MetricCard(
          label: 'Duration',
          value: duration.toHoursMinutesSeconds(),
          icon: Icons.timer_outlined,
          iconColor: Colors.blue,
        ),
        MetricCard(
          label: 'Avg Speed',
          value: averageSpeedKmH.toStringAsFixed(1),
          unit: 'km/h',
          icon: Icons.speed,
          iconColor: Colors.orange,
        ),
        MetricCard(
          label: 'Avg Pace',
          value: PaceCalculator.formatPace(pace),
          unit: '/km',
          icon: Icons.av_timer,
          iconColor: Colors.purple,
        ),
        MetricCard(
          label: 'Max Speed',
          value: maxSpeedKmH.toStringAsFixed(1),
          unit: 'km/h',
          icon: Icons.bolt,
          iconColor: Colors.amber,
        ),
        MetricCard(
          label: 'Elevation Gain',
          value: workout.elevationGain?.toStringAsFixed(0) ?? '0',
          unit: 'm',
          icon: Icons.terrain,
          iconColor: Colors.brown,
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = monthNames[dt.month - 1];
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final hourStr = dt.hour.toString().padLeft(2, '0');
    return '$month ${dt.day}, ${dt.year} at $hourStr:$minuteStr';
  }
}
