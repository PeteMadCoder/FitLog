import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/diary/providers/diary_providers.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';
import 'package:fitlog_app/features/analytics/views/workout_detail_screen.dart';
import 'package:fitlog_app/features/tracking/models/sport_type.dart';

/// A custom calendar widget that displays workouts in a monthly grid.
class WorkoutCalendar extends ConsumerWidget {
  const WorkoutCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMonth = ref.watch(calendarMonthProvider);
    final workoutsAsync = ref.watch(workoutsByMonthProvider(currentMonth));

    return workoutsAsync.when(
      data: (workouts) =>
          _CalendarGrid(month: currentMonth, workouts: workouts),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _CalendarGrid extends ConsumerWidget {
  final DateTime month;
  final List<Workout> workouts;

  const _CalendarGrid({required this.month, required this.workouts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calendar logic
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    // Adjust to start on Monday (1 = Monday, 7 = Sunday)
    // firstDayOfMonth.weekday: 1=Mon, ..., 7=Sun
    final leadingEmptyDays = firstDayOfMonth.weekday - 1;
    final daysInMonth = lastDayOfMonth.day;

    final monthName = _getMonthName(month.month);

    // Group workouts by day for easy lookup
    final workoutsByDay = <int, List<Workout>>{};
    for (final workout in workouts) {
      final day = workout.startTime.day;
      workoutsByDay.putIfAbsent(day, () => []).add(workout);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$monthName ${month.year}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => ref
                          .read(calendarMonthProvider.notifier)
                          .previousMonth(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () =>
                          ref.read(calendarMonthProvider.notifier).nextMonth(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Weekday labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: leadingEmptyDays + daysInMonth,
              itemBuilder: (context, index) {
                if (index < leadingEmptyDays) {
                  return const SizedBox.shrink();
                }

                final day = index - leadingEmptyDays + 1;
                final dayWorkouts = workoutsByDay[day] ?? [];
                final hasWorkouts = dayWorkouts.isNotEmpty;
                final isToday = _isToday(month.year, month.month, day);

                return _CalendarDayTile(
                  day: day,
                  isToday: isToday,
                  workouts: dayWorkouts,
                  onTap: hasWorkouts
                      ? () => _showDayWorkouts(context, day, dayWorkouts)
                      : null,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  bool _isToday(int year, int month, int day) {
    final now = DateTime.now();
    return now.year == year && now.month == month && now.day == day;
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  void _showDayWorkouts(BuildContext context, int day, List<Workout> workouts) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) =>
          _DayWorkoutsSheet(day: day, month: month, workouts: workouts),
    );
  }
}

class _CalendarDayTile extends StatelessWidget {
  final int day;
  final bool isToday;
  final List<Workout> workouts;
  final VoidCallback? onTap;

  const _CalendarDayTile({
    required this.day,
    required this.isToday,
    required this.workouts,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasWorkouts = workouts.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isToday
              ? colorScheme.primaryContainer.withOpacity(0.5)
              : hasWorkouts
              ? colorScheme.surfaceVariant.withOpacity(0.3)
              : null,
          border: isToday
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isToday || hasWorkouts ? FontWeight.bold : null,
                color: isToday ? colorScheme.primary : null,
              ),
            ),
            if (hasWorkouts) ...[
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: workouts.take(3).map((w) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _getSportColor(w.sportType),
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getSportColor(String sportType) {
    return SportType.fromId(sportType).color;
  }
}

class _DayWorkoutsSheet extends StatelessWidget {
  final int day;
  final DateTime month;
  final List<Workout> workouts;

  const _DayWorkoutsSheet({
    required this.day,
    required this.month,
    required this.workouts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Workouts on $day ${_getMonthName(month.month)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final workout = workouts[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getSportColor(
                      workout.sportType,
                    ).withOpacity(0.2),
                    child: Icon(
                      _getSportIcon(workout.sportType),
                      color: _getSportColor(workout.sportType),
                    ),
                  ),
                  title: Text(workout.name ?? SportType.fromId(workout.sportType).name.toUpperCase()),
                  subtitle: Text(
                    '${(workout.distanceMeters / 1000).toStringAsFixed(2)} km • ${_formatDuration(workout.durationSeconds)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WorkoutDetailScreen(workoutId: workout.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  IconData _getSportIcon(String sportType) {
    return SportType.fromId(sportType).icon;
  }

  Color _getSportColor(String sportType) {
    return SportType.fromId(sportType).color;
  }

  String _formatDuration(double seconds) {
    final d = Duration(seconds: seconds.toInt());
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final secs = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m ${secs}s';
  }
}
