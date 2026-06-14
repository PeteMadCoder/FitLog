import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/tracking/providers/tracking_notifier.dart';
import 'package:fitlog_app/features/tracking/providers/tracking_state.dart';
import 'active_workout_screen.dart';

/// Screen displayed when the Tracker tab is selected.
/// Displays the sport selection launcher when idle, and transitions to the
/// [ActiveWorkoutScreen] once tracking begins.
class TrackerScreen extends ConsumerStatefulWidget {
  const TrackerScreen({super.key});

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen> {
  String _selectedSport = 'running';

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackingNotifierProvider);

    // If recording or paused, redirect to the ActiveWorkoutScreen
    if (trackingState.status != TrackingStatus.idle) {
      return const ActiveWorkoutScreen();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Start Workout')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_circle_fill,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Ready to hit the road?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select your sport and start tracking your path in real time.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 48),

              // Sport selection layout cards
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSportCard(
                    sportType: 'running',
                    label: 'Run',
                    icon: Icons.directions_run,
                  ),
                  const SizedBox(width: 24),
                  _buildSportCard(
                    sportType: 'cycling',
                    label: 'Ride',
                    icon: Icons.directions_bike,
                  ),
                ],
              ),
              const SizedBox(height: 64),

              // Start button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await ref
                        .read(trackingNotifierProvider.notifier)
                        .startTracking(_selectedSport);

                    if (context.mounted && result.isFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result.failureOrNullValue?.message ??
                                'Failed to start tracking',
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'START WORKOUT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSportCard({
    required String sportType,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedSport == sportType;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSport = sportType;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.12)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? theme.colorScheme.primary : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? theme.colorScheme.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
