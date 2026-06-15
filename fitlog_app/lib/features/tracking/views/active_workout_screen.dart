import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fitlog_app/features/tracking/providers/tracking_notifier.dart';
import 'package:fitlog_app/features/tracking/providers/tracking_state.dart';
import 'package:fitlog_app/features/tracking/widgets/workout_metrics_widgets.dart';
import 'package:fitlog_app/features/analytics/views/workout_detail_screen.dart';

/// Screen displayed during an active workout session.
/// Renders a live map, routes breadcrumbs, real-time metrics, and pause/resume/stop controls.
class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  late final MapController _mapController;
  bool _followUser = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackingNotifierProvider);
    final gpsPoints = trackingState.gpsPoints;

    // Map list of GpsPoints into LatLng coordinates
    final List<LatLng> routePoints = gpsPoints
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    // Map default center coordinates: SF as fallback
    final LatLng mapCenter = routePoints.isNotEmpty
        ? routePoints.last
        : const LatLng(37.7749, -122.4194);

    // Auto-center map to current location if follow mode is active
    if (_followUser && routePoints.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(mapCenter, _mapController.camera.zoom);
        }
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. Live Map Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: mapCenter,
              initialZoom: 15.0,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture && _followUser) {
                  setState(() {
                    _followUser = false;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.madcoder.fitlog.app',
              ),
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      color: Theme.of(context).colorScheme.primary,
                      strokeWidth: 5.0,
                    ),
                  ],
                ),
              if (routePoints.isNotEmpty)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: routePoints.last,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // 2. Upper Floating Widgets (Sport status and online warning)
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        trackingState.sportType == 'cycling'
                            ? Icons.directions_bike
                            : Icons.directions_run,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${trackingState.sportType.toUpperCase()} • ${trackingState.status.name.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Online Map Tiles',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Floating Re-Center Button
          if (!_followUser)
            Positioned(
              bottom: 230,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: () {
                  setState(() {
                    _followUser = true;
                  });
                },
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.gps_fixed),
              ),
            ),

          // 4. Premium Bottom Dashboard Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const WorkoutMetricsGrid(),
                  const SizedBox(height: 24),

                  // Tracking action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (trackingState.status == TrackingStatus.recording) ...[
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(trackingNotifierProvider.notifier)
                                .pauseTracking();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(20),
                            elevation: 4,
                          ),
                          child: const Icon(Icons.pause, size: 28),
                        ),
                      ] else if (trackingState.status ==
                          TrackingStatus.paused) ...[
                        ElevatedButton(
                          onPressed: () => _showStopConfirmationDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(20),
                            elevation: 4,
                          ),
                          child: const Icon(Icons.stop, size: 28),
                        ),
                        const SizedBox(width: 32),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(trackingNotifierProvider.notifier)
                                .resumeTracking();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(20),
                            elevation: 4,
                          ),
                          child: const Icon(Icons.play_arrow, size: 28),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStopConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'End Workout',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Would you like to save this workout or discard it?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: ctx,
                            builder: (confirmCtx) => AlertDialog(
                              title: const Text('Discard Workout?'),
                              content: const Text(
                                'This will delete all recorded data for this session. This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(confirmCtx, false),
                                  child: const Text('CANCEL'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(confirmCtx, true),
                                  child: const Text(
                                    'DISCARD',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            ref
                                .read(trackingNotifierProvider.notifier)
                                .discardTracking();
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Discard'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Capture navigator and context before the async operation
                          // because the ActiveWorkoutScreen might be unmounted
                          // when stopTracking transitions the state to idle.
                          final navigator = Navigator.of(ctx);

                          final result = await ref
                              .read(trackingNotifierProvider.notifier)
                              .stopTracking();

                          if (ctx.mounted) {
                            navigator.pop();
                          }

                          result.fold(
                            (workout) {
                              ScaffoldMessenger.of(
                                navigator.context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Workout completed! Saved ${workout.gpsPoints.length} points.',
                                  ),
                                ),
                              );
                              navigator.push(
                                MaterialPageRoute(
                                  builder: (context) => WorkoutDetailScreen(
                                    workoutId: workout.id,
                                  ),
                                ),
                              );
                            },
                            (failure) {
                              ScaffoldMessenger.of(
                                navigator.context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(failure.message),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                ),
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Save Workout'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
