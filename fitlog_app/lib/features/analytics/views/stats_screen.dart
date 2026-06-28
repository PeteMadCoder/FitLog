import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/analytics/providers/analytics_providers.dart';
import 'package:fitlog_app/shared/extensions/duration_extensions.dart';
import 'package:fitlog_app/features/settings/views/settings_screen.dart';
import 'package:fitlog_app/features/tracking/models/sport_type.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';

/// Screen displaying aggregated statistics across different timeframes.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final selectedTimeframe = ref.watch(selectedStatsTimeframeProvider);
    final refDate = ref.watch(statsReferenceDateProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeframe Selector
              _buildTimeframeSelector(context, ref, selectedTimeframe),
              if (selectedTimeframe != StatsTimeframe.allTime) ...[
                const SizedBox(height: 16),
                _buildPaginationHeader(context, ref, selectedTimeframe, refDate),
                const SizedBox(height: 16),
                _buildMicroCalendar(context, ref, selectedTimeframe, refDate),
              ],
              const SizedBox(height: 24),

              statsAsync.when(
                data: (stats) => Column(
                  children: [
                    _buildMainMetricCard(
                      context,
                      'Total Distance',
                      (stats.totalDistanceMeters / 1000).toStringAsFixed(2),
                      'km',
                      Icons.route,
                      colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSecondaryMetricCard(
                            context,
                            'Duration',
                            stats.totalDuration.toHoursMinutesSeconds(),
                            Icons.timer_outlined,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSecondaryMetricCard(
                            context,
                            'Calories',
                            '${stats.totalCalories.toInt()}',
                            Icons.local_fire_department_outlined,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSecondaryMetricCard(
                      context,
                      'Workouts',
                      '${stats.workoutCount}',
                      Icons.fitness_center,
                      Colors.blue,
                      isFullWidth: true,
                    ),
                  ],
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => Center(
                  child: Text(
                    'Error: $err',
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              _buildInfoSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeframeSelector(
    BuildContext context,
    WidgetRef ref,
    StatsTimeframe current,
  ) {
    return SegmentedButton<StatsTimeframe>(
      segments: const [
        ButtonSegment(value: StatsTimeframe.weekly, label: Text('Week')),
        ButtonSegment(value: StatsTimeframe.monthly, label: Text('Month')),
        ButtonSegment(value: StatsTimeframe.yearly, label: Text('Year')),
        ButtonSegment(value: StatsTimeframe.allTime, label: Text('All')),
      ],
      selected: {current},
      onSelectionChanged: (newSelection) {
        ref
            .read(selectedStatsTimeframeProvider.notifier)
            .setTimeframe(newSelection.first);
      },
      showSelectedIcon: false,
    );
  }

  Widget _buildMainMetricCard(
    BuildContext context,
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isFullWidth = false,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About your data',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'All statistics are calculated locally on your device. Only completed workouts within the selected timeframe are included.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  String _formatWeeklyHeader(DateTime refDate) {
    final monday = refDate.subtract(Duration(days: refDate.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    if (monday.month == sunday.month) {
      return '${_monthNames[monday.month - 1]} ${monday.day} - ${sunday.day}, ${monday.year}';
    } else if (monday.year == sunday.year) {
      return '${_monthNames[monday.month - 1]} ${monday.day} - ${_monthNames[sunday.month - 1]} ${sunday.day}, ${monday.year}';
    } else {
      return '${_monthNames[monday.month - 1]} ${monday.day}, ${monday.year} - ${_monthNames[sunday.month - 1]} ${sunday.day}, ${sunday.year}';
    }
  }

  String _formatMonthlyHeader(DateTime refDate) {
    return '${_monthNames[refDate.month - 1]} ${refDate.year}';
  }

  String _formatYearlyHeader(DateTime refDate) {
    return 'Year ${refDate.year}';
  }

  Widget _buildPaginationHeader(
    BuildContext context,
    WidgetRef ref,
    StatsTimeframe timeframe,
    DateTime refDate,
  ) {
    final theme = Theme.of(context);
    String label = '';
    switch (timeframe) {
      case StatsTimeframe.weekly:
        label = _formatWeeklyHeader(refDate);
        break;
      case StatsTimeframe.monthly:
        label = _formatMonthlyHeader(refDate);
        break;
      case StatsTimeframe.yearly:
        label = _formatYearlyHeader(refDate);
        break;
      case StatsTimeframe.allTime:
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            ref.read(statsReferenceDateProvider.notifier).previous();
          },
        ),
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            ref.read(statsReferenceDateProvider.notifier).next();
          },
        ),
      ],
    );
  }

  Widget _buildMicroCalendar(
    BuildContext context,
    WidgetRef ref,
    StatsTimeframe timeframe,
    DateTime refDate,
  ) {
    final workoutsAsync = ref.watch(statsWorkoutsProvider);
    return workoutsAsync.when(
      data: (workouts) {
        switch (timeframe) {
          case StatsTimeframe.weekly:
            return _buildWeekMicroCalendar(context, refDate, workouts);
          case StatsTimeframe.monthly:
            return _buildMonthMicroCalendar(context, refDate, workouts);
          case StatsTimeframe.yearly:
            return _buildYearlyHeatmap(context, refDate, workouts);
          case StatsTimeframe.allTime:
            return const SizedBox.shrink();
        }
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Center(child: Text('Error loading calendar: $e')),
    );
  }

  Widget _buildWeekMicroCalendar(
    BuildContext context,
    DateTime refDate,
    List<Workout> workouts,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final monday = refDate.subtract(Duration(days: refDate.weekday - 1));
    final weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (i) {
            final dayDate = monday.add(Duration(days: i));
            final isToday = _isToday(dayDate);
            final dayWorkouts = workouts.where((w) {
              return w.startTime.year == dayDate.year &&
                  w.startTime.month == dayDate.month &&
                  w.startTime.day == dayDate.day;
            }).toList();
            final hasWorkouts = dayWorkouts.isNotEmpty;

            return Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    weekdayLabels[i],
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: isToday
                          ? colorScheme.primaryContainer.withOpacity(0.5)
                          : hasWorkouts
                              ? colorScheme.surfaceVariant.withOpacity(0.3)
                              : null,
                      borderRadius: BorderRadius.circular(12),
                      border: isToday
                          ? Border.all(color: colorScheme.primary, width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayDate.day.toString(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isToday || hasWorkouts
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isToday ? colorScheme.primary : null,
                          ),
                        ),
                        if (hasWorkouts) ...[
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: dayWorkouts.take(3).map((w) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: SportType.fromId(w.sportType).color,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMonthMicroCalendar(
    BuildContext context,
    DateTime refDate,
    List<Workout> workouts,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final firstDayOfMonth = DateTime(refDate.year, refDate.month, 1);
    final lastDayOfMonth = DateTime(refDate.year, refDate.month + 1, 0);
    final leadingEmptyDays = firstDayOfMonth.weekday - 1;
    final daysInMonth = lastDayOfMonth.day;

    final workoutsByDay = <int, List<Workout>>{};
    for (final workout in workouts) {
      final day = workout.startTime.day;
      workoutsByDay.putIfAbsent(day, () => []).add(workout);
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Weekday labels
            Row(
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
            const SizedBox(height: 8),

            // Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemCount: leadingEmptyDays + daysInMonth,
              itemBuilder: (context, index) {
                if (index < leadingEmptyDays) {
                  return const SizedBox.shrink();
                }

                final day = index - leadingEmptyDays + 1;
                final dayWorkouts = workoutsByDay[day] ?? [];
                final hasWorkouts = dayWorkouts.isNotEmpty;
                final dayDate = DateTime(refDate.year, refDate.month, day);
                final isToday = _isToday(dayDate);

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isToday
                        ? colorScheme.primaryContainer.withOpacity(0.5)
                        : hasWorkouts
                            ? colorScheme.surfaceVariant.withOpacity(0.3)
                            : null,
                    border: isToday
                        ? Border.all(color: colorScheme.primary, width: 1.5)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: isToday || hasWorkouts
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isToday ? colorScheme.primary : null,
                        ),
                      ),
                      if (hasWorkouts) ...[
                        const SizedBox(height: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: dayWorkouts.take(3).map((w) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 0.5),
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: SportType.fromId(w.sportType).color,
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearlyHeatmap(
    BuildContext context,
    DateTime refDate,
    List<Workout> workouts,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final startOfYear = DateTime(refDate.year, 1, 1);
    final endOfYear = DateTime(refDate.year, 12, 31);
    final gridStartDate = startOfYear.subtract(Duration(days: startOfYear.weekday - 1));
    final maxDiffDays = endOfYear.difference(gridStartDate).inDays;
    final totalCols = (maxDiffDays ~/ 7) + 1;

    final Map<String, List<Workout>> workoutsByDateStr = {};
    for (final w in workouts) {
      final dateStr = '${w.startTime.year}-${w.startTime.month}-${w.startTime.day}';
      workoutsByDateStr.putIfAbsent(dateStr, () => []).add(w);
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Heatmap',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Weekdays label column
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['M', 'W', 'F', 'S']
                        .map(
                          (d) => Padding(
                            padding: const EdgeInsets.only(right: 8.0, bottom: 6.0),
                            child: Text(
                              d,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.4),
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  // Grid itself
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(totalCols, (col) {
                          return Column(
                            children: List.generate(7, (row) {
                              final cellDate = gridStartDate.add(Duration(days: col * 7 + row));
                              final isWithinYear = cellDate.year == refDate.year;
                              
                              if (!isWithinYear) {
                                return const SizedBox(
                                  width: 13,
                                  height: 13,
                                );
                              }

                              final dateStr = '${cellDate.year}-${cellDate.month}-${cellDate.day}';
                              final dayWorkouts = workoutsByDateStr[dateStr] ?? [];
                              final hasWorkouts = dayWorkouts.isNotEmpty;
                              
                              Color cellColor = colorScheme.surfaceVariant.withOpacity(0.2);
                              if (hasWorkouts) {
                                final sportColor = SportType.fromId(dayWorkouts.first.sportType).color;
                                cellColor = sportColor.withOpacity(
                                  dayWorkouts.length == 1 ? 0.4 : (dayWorkouts.length == 2 ? 0.7 : 1.0)
                                );
                              }

                              final isToday = _isToday(cellDate);

                              return Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.all(1.5),
                                decoration: BoxDecoration(
                                  color: cellColor,
                                  borderRadius: BorderRadius.circular(2),
                                  border: isToday
                                      ? Border.all(color: colorScheme.primary, width: 1)
                                      : null,
                                ),
                              );
                            }),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Less',
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 8, color: colorScheme.onSurface.withOpacity(0.5)),
                ),
                const SizedBox(width: 4),
                _buildLegendBox(colorScheme.surfaceVariant.withOpacity(0.2)),
                _buildLegendBox(colorScheme.primary.withOpacity(0.4)),
                _buildLegendBox(colorScheme.primary.withOpacity(0.7)),
                _buildLegendBox(colorScheme.primary.withOpacity(1.0)),
                const SizedBox(width: 4),
                Text(
                  'More',
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 8, color: colorScheme.onSurface.withOpacity(0.5)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }

  String _getMonthAbbreviation(int month) {
    const list = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return list[month - 1];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year && now.month == date.month && now.day == date.day;
  }
}
