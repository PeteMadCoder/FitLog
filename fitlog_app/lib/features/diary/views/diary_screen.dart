import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/diary/providers/diary_providers.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';
import 'package:fitlog_app/features/analytics/views/workout_detail_screen.dart';
import 'package:fitlog_app/features/diary/views/workout_calendar.dart';
import 'package:fitlog_app/shared/extensions/duration_extensions.dart';
import 'package:fitlog_app/core/utils/pace_calculator.dart';

/// Screen displaying a chronological list or calendar of all recorded workout sessions.
class DiaryScreen extends ConsumerWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutHistoryProvider);
    final isCalendarView = ref.watch(diaryViewModeProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Diary'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(isCalendarView ? Icons.view_list : Icons.calendar_month),
            onPressed: () => ref.read(diaryViewModeProvider.notifier).toggle(),
            tooltip: isCalendarView ? 'Show List' : 'Show Calendar',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: workoutsAsync.when(
        data: (workouts) {
          if (workouts.isEmpty) {
            return _buildEmptyState(context);
          }
          return isCalendarView
              ? const SingleChildScrollView(child: WorkoutCalendar())
              : ListView.builder(
                  itemCount: workouts.length,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemBuilder: (context, index) {
                    final workout = workouts[index];
                    return _buildWorkoutCard(context, workout);
                  },
                );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Error loading workouts: $err',
            style: TextStyle(color: colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Workouts Recorded',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track a session in the tracker tab to view your activity history here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, Workout workout) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final duration = Duration(seconds: workout.durationSeconds.toInt());
    final distanceKm = workout.distanceMeters / 1000.0;

    // Choose icon and colors based on sport type
    IconData sportIcon;
    Color iconColor;
    Color iconBgColor;

    switch (workout.sportType.toLowerCase()) {
      case 'running':
        sportIcon = Icons.directions_run;
        iconColor = Colors.orange.shade700;
        iconBgColor = Colors.orange.shade100;
        break;
      case 'cycling':
        sportIcon = Icons.directions_bike;
        iconColor = Colors.cyan.shade700;
        iconBgColor = Colors.cyan.shade100;
        break;
      case 'walking':
        sportIcon = Icons.directions_walk;
        iconColor = Colors.green.shade700;
        iconBgColor = Colors.green.shade100;
        break;
      case 'hiking':
        sportIcon = Icons.terrain;
        iconColor = Colors.brown.shade700;
        iconBgColor = Colors.brown.shade100;
        break;
      default:
        sportIcon = Icons.fitness_center;
        iconColor = colorScheme.primary;
        iconBgColor = colorScheme.primaryContainer;
    }

    if (theme.brightness == Brightness.dark) {
      iconBgColor = iconColor.withOpacity(0.2);
    }

    final formattedDate = _formatDateTime(workout.startTime);

    // Calculate pace or speed
    String speedOrPaceValue;
    String speedOrPaceLabel;
    if (workout.sportType.toLowerCase() == 'cycling') {
      final speedKmH = workout.averageSpeed != null
          ? workout.averageSpeed! * 3.6
          : 0.0;
      speedOrPaceValue = '${speedKmH.toStringAsFixed(1)} km/h';
      speedOrPaceLabel = 'Speed';
    } else {
      final pace = PaceCalculator.calculateAveragePaceMinPerKm(
        duration,
        workout.distanceMeters,
      );
      speedOrPaceValue = '${PaceCalculator.formatPace(pace)}/km';
      speedOrPaceLabel = 'Pace';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutDetailScreen(workoutId: workout.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(sportIcon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),

              // Details & Summary Columns
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name ??
                          '${workout.sportType.toUpperCase()} WORKOUT',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Inline stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMiniMetric(
                          context,
                          'Distance',
                          '${distanceKm.toStringAsFixed(2)} km',
                        ),
                        _buildMiniMetric(
                          context,
                          'Duration',
                          duration.toHoursMinutesSeconds(),
                        ),
                        _buildMiniMetric(
                          context,
                          speedOrPaceLabel,
                          speedOrPaceValue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Navigation Arrow
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniMetric(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
