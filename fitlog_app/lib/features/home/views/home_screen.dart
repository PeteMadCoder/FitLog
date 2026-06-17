import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/analytics/providers/analytics_providers.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';
import 'package:fitlog_app/shared/extensions/duration_extensions.dart';
import 'package:fitlog_app/features/analytics/views/workout_detail_screen.dart';
import 'package:fitlog_app/features/tracking/models/sport_type.dart';
import 'package:fitlog_app/features/settings/views/settings_screen.dart';

/// Home Dashboard showing a summary of the last workout and weekly statistics.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastWorkoutAsync = ref.watch(latestWorkoutProvider);
    final weeklySummaryAsync = ref.watch(weeklyActivitySummaryProvider);
    final goalProgressAsync = ref.watch(weeklyGoalProgressProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(latestWorkoutProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, 'Weekly Goal'),
              const SizedBox(height: 12),
              goalProgressAsync.when(
                data: (progress) => _WeeklyGoalCard(progress: progress),
                loading: () => const _LoadingPlaceholder(height: 100),
                error: (e, _) => _buildErrorState(context, e.toString()),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'Last Workout'),
              const SizedBox(height: 12),
              lastWorkoutAsync.when(
                data: (workout) => workout != null
                    ? _LastWorkoutCard(workout: workout)
                    : _buildEmptyState(context, 'No workouts recorded yet.'),
                loading: () => const _LoadingPlaceholder(height: 120),
                error: (e, _) => _buildErrorState(context, e.toString()),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'Weekly Summary'),
              const SizedBox(height: 12),
              weeklySummaryAsync.when(
                data: (summary) => summary.statsBySport.isNotEmpty
                    ? _WeeklySummaryList(summary: summary)
                    : _buildEmptyState(context, 'No activity this week.'),
                loading: () => const _LoadingPlaceholder(height: 150),
                error: (e, _) => _buildErrorState(context, e.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(child: Text('Error: $error'));
  }
}

class _WeeklyGoalCard extends StatelessWidget {
  final WeeklyGoalProgress progress;

  const _WeeklyGoalCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (progress.goalHours <= 0) {
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(Icons.flag_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No weekly goal set',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Tap to set a weekly activity goal',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Goal: ${progress.goalHours.toStringAsFixed(1)} hours',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${progress.streakCount} week streak!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${(progress.progressPercentage * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: progress.isGoalMet ? Colors.green : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.progressPercentage,
                minHeight: 12,
                backgroundColor: theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress.isGoalMet ? Colors.green : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${progress.currentWeekHours.toStringAsFixed(1)} / ${progress.goalHours.toStringAsFixed(1)} hours this week',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _LastWorkoutCard extends StatelessWidget {
  final Workout workout;

  const _LastWorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sport = SportType.fromId(workout.sportType);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutDetailScreen(workoutId: workout.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: sport.color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      sport.icon,
                      color: sport.color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sport.name.toUpperCase(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: sport.color,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          _formatDate(workout.startTime),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MetricItem(
                    label: 'Distance',
                    value: _formatDistance(workout.distanceMeters),
                  ),
                  _MetricItem(
                    label: 'Duration',
                    value: Duration(
                      seconds: workout.durationSeconds.toInt(),
                    ).toHoursMinutesSeconds(),
                  ),
                  _MetricItem(
                    label: 'Elevation',
                    value:
                        '${workout.elevationGain?.toStringAsFixed(0) ?? '0'}m',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
  }
}

class _WeeklySummaryList extends StatelessWidget {
  final WeeklyActivitySummary summary;

  const _WeeklySummaryList({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: summary.statsBySport.entries.map((entry) {
        return _WeeklySportCard(sport: entry.key, stats: entry.value);
      }).toList(),
    );
  }
}

class _WeeklySportCard extends StatelessWidget {
  final String sport;
  final AggregatedStats stats;

  const _WeeklySportCard({required this.sport, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sportModel = SportType.fromId(sport);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(sportModel.icon, color: sportModel.color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sportModel.name.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${stats.workoutCount} activities this week'),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDistance(stats.totalDistanceMeters),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(stats.totalDuration.toHoursMinutesSeconds()),
            ],
          ),
        ],
      ),
    );
  }



  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;

  const _MetricItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  final double height;
  const _LoadingPlaceholder({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
