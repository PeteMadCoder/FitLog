import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import 'package:fitlog_app/app/app_providers.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';

part 'analytics_providers.g.dart';

/// Provider exposing a real-time stream of a specific [Workout] by its [id].
/// Automatically loads the associated GPS point links upon retrieval.
@riverpod
Stream<Workout?> workoutDetail(WorkoutDetailRef ref, int id) async* {
  final isar = await ref.watch(isarProvider.future);

  final stream = isar.workouts.watchObject(id, fireImmediately: true);

  await for (final workout in stream) {
    if (workout != null && workout.gpsPoints.isAttached) {
      await workout.gpsPoints.load();
    }
    yield workout;
  }
}

/// Statistics timeframe options.
enum StatsTimeframe { weekly, monthly, yearly, allTime }

/// State class for aggregated statistics.
class AggregatedStats {
  final double totalDistanceMeters;
  final Duration totalDuration;
  final double totalCalories;
  final int workoutCount;

  AggregatedStats({
    required this.totalDistanceMeters,
    required this.totalDuration,
    required this.totalCalories,
    required this.workoutCount,
  });

  factory AggregatedStats.empty() => AggregatedStats(
    totalDistanceMeters: 0,
    totalDuration: Duration.zero,
    totalCalories: 0,
    workoutCount: 0,
  );
}

/// Provider to track the selected timeframe for statistics.
@riverpod
class SelectedStatsTimeframe extends _$SelectedStatsTimeframe {
  @override
  StatsTimeframe build() => StatsTimeframe.weekly;

  void setTimeframe(StatsTimeframe timeframe) => state = timeframe;
}

/// Provider that aggregates workout data based on the selected timeframe.
@riverpod
Stream<AggregatedStats> dashboardStats(DashboardStatsRef ref) async* {
  final isar = await ref.watch(isarProvider.future);
  final timeframe = ref.watch(selectedStatsTimeframeProvider);

  final now = DateTime.now();
  DateTime? startDate;

  switch (timeframe) {
    case StatsTimeframe.weekly:
      // Start of current week (Monday)
      startDate = now.subtract(Duration(days: now.weekday - 1));
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
      break;
    case StatsTimeframe.monthly:
      startDate = DateTime(now.year, now.month, 1);
      break;
    case StatsTimeframe.yearly:
      startDate = DateTime(now.year, 1, 1);
      break;
    case StatsTimeframe.allTime:
      startDate = null;
      break;
  }

  if (startDate != null) {
    yield* isar.workouts
        .filter()
        .startTimeGreaterThan(startDate)
        .watch(fireImmediately: true)
        .map((workouts) {
          return _aggregateWorkouts(workouts);
        });
  } else {
    yield* isar.workouts.where().watch(fireImmediately: true).map((workouts) {
      return _aggregateWorkouts(workouts);
    });
  }
}

AggregatedStats _aggregateWorkouts(List<Workout> workouts) {
  double distance = 0;
  double durationSecs = 0;
  double calories = 0;

  for (final workout in workouts) {
    distance += workout.distanceMeters;
    durationSecs += workout.durationSeconds;
    calories += workout.calories ?? 0;
  }

  return AggregatedStats(
    totalDistanceMeters: distance,
    totalDuration: Duration(seconds: durationSecs.toInt()),
    totalCalories: calories,
    workoutCount: workouts.length,
  );
}

/// Provider exposing the most recent completed workout.
@riverpod
Stream<Workout?> latestWorkout(LatestWorkoutRef ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield* isar.workouts
      .where()
      .sortByStartTimeDesc()
      .limit(1)
      .watch(fireImmediately: true)
      .map((list) => list.isNotEmpty ? list.first : null);
}

/// Weekly activity summary grouped by sport type.
class WeeklyActivitySummary {
  final Map<String, AggregatedStats> statsBySport;

  WeeklyActivitySummary({required this.statsBySport});
}

/// Provider exposing a weekly activity summary grouped by sport type.
@riverpod
Stream<WeeklyActivitySummary> weeklyActivitySummary(
  WeeklyActivitySummaryRef ref,
) async* {
  final isar = await ref.watch(isarProvider.future);
  final now = DateTime.now();

  // Start of current week (Monday)
  DateTime startDate = now.subtract(Duration(days: now.weekday - 1));
  startDate = DateTime(startDate.year, startDate.month, startDate.day);

  yield* isar.workouts
      .filter()
      .startTimeGreaterThan(startDate)
      .watch(fireImmediately: true)
      .map((workouts) {
        final Map<String, List<Workout>> grouped = {};
        for (final workout in workouts) {
          grouped.putIfAbsent(workout.sportType, () => []).add(workout);
        }

        final Map<String, AggregatedStats> statsBySport = {};
        grouped.forEach((sport, sportWorkouts) {
          statsBySport[sport] = _aggregateWorkouts(sportWorkouts);
        });

        return WeeklyActivitySummary(statsBySport: statsBySport);
      });
}
