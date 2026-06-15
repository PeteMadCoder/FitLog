import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/analytics/providers/analytics_providers.dart';
import 'package:fitlog_app/shared/extensions/duration_extensions.dart';

/// Screen displaying aggregated statistics across different timeframes.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final selectedTimeframe = ref.watch(selectedStatsTimeframeProvider);
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
                  child: Text('Error: $err',
                      style: TextStyle(color: colorScheme.error)),
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
        ButtonSegment(
          value: StatsTimeframe.weekly,
          label: Text('Week'),
        ),
        ButtonSegment(
          value: StatsTimeframe.monthly,
          label: Text('Month'),
        ),
        ButtonSegment(
          value: StatsTimeframe.yearly,
          label: Text('Year'),
        ),
        ButtonSegment(
          value: StatsTimeframe.allTime,
          label: Text('All'),
        ),
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
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
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
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
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
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
}
