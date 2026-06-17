import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import 'package:fitlog_app/app/app_providers.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';
import 'package:fitlog_app/features/tracking/models/gps_point.dart';
import 'package:fitlog_app/features/tracking/models/sensor_data.dart';
import 'package:fitlog_app/features/settings/providers/settings_provider.dart';

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

/// Notifier to handle editing and deleting workouts.
@riverpod
class WorkoutEditor extends _$WorkoutEditor {
  @override
  void build() {}

  /// Updates the name of a workout.
  Future<void> updateWorkoutName(int id, String newName) async {
    final isar = await ref.read(isarProvider.future);
    await isar.writeTxn(() async {
      final workout = await isar.workouts.get(id);
      if (workout != null) {
        workout.name = newName;
        await isar.workouts.put(workout);
      }
    });
  }

  /// Deletes a workout and its associated GPS points and sensor data.
  Future<void> deleteWorkout(int id) async {
    final isar = await ref.read(isarProvider.future);
    await isar.writeTxn(() async {
      final workout = await isar.workouts.get(id);
      if (workout != null) {
        if (workout.gpsPoints.isAttached) {
          await workout.gpsPoints.load();
        }
        if (workout.sensorData.isAttached) {
          await workout.sensorData.load();
        }
        final gpsIds = workout.gpsPoints.map((p) => p.id).toList();
        final sensorIds = workout.sensorData.map((s) => s.id).toList();
        
        await isar.gpsPoints.deleteAll(gpsIds);
        await isar.sensorDatas.deleteAll(sensorIds);
        await isar.workouts.delete(id);
      }
    });
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

/// State class for weekly goal progress.
class WeeklyGoalProgress {
  final double goalHours;
  final double currentWeekHours;
  final int streakCount;

  WeeklyGoalProgress({
    required this.goalHours,
    required this.currentWeekHours,
    required this.streakCount,
  });

  double get progressPercentage => goalHours > 0 ? (currentWeekHours / goalHours).clamp(0.0, 1.0) : 0.0;
  bool get isGoalMet => currentWeekHours >= goalHours && goalHours > 0;
}

/// Provider exposing the weekly goal progress.
@riverpod
Stream<WeeklyGoalProgress> weeklyGoalProgress(WeeklyGoalProgressRef ref) async* {
  final isar = await ref.watch(isarProvider.future);
  final settings = await ref.watch(settingsStateProvider.future);
  final goalHours = settings.weeklyGoalHours ?? 0.0;

  yield* isar.workouts.where().sortByStartTimeDesc().watch(fireImmediately: true).map((workouts) {
    return calculateWeeklyGoalProgress(
      workouts: workouts,
      goalHours: goalHours,
      now: DateTime.now(),
    );
  });
}

WeeklyGoalProgress calculateWeeklyGoalProgress({
  required List<Workout> workouts,
  required double goalHours,
  required DateTime now,
}) {
  if (workouts.isEmpty) {
    return WeeklyGoalProgress(
      goalHours: goalHours,
      currentWeekHours: 0.0,
      streakCount: 0,
    );
  }

  // Monday of current week
  final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
  final startOfCurrentWeek = DateTime(currentWeekStart.year, currentWeekStart.month, currentWeekStart.day);

  double currentWeekSeconds = 0;
  
  // Map of week identifier (year-weekNumber) to total duration in seconds
  final Map<String, double> weeklyDurations = {};

  for (final workout in workouts) {
    if (workout.startTime.isAfter(startOfCurrentWeek) || workout.startTime.isAtSameMomentAs(startOfCurrentWeek)) {
      currentWeekSeconds += workout.durationSeconds;
    }

    final weekId = _getWeekId(workout.startTime);
    weeklyDurations[weekId] = (weeklyDurations[weekId] ?? 0) + workout.durationSeconds;
  }

  int streakCount = 0;
  if (goalHours > 0) {
    // Check current week
    final currentWeekMet = currentWeekSeconds >= goalHours * 3600;
    
    // Check backwards from previous weeks
    DateTime checkDate = startOfCurrentWeek.subtract(const Duration(days: 1)); // Sunday of last week
    
    bool streakBroken = false;
    
    // If current week is met, streak starts at 1 and we look back
    if (currentWeekMet) {
      streakCount = 1;
    } 
    // If current week not met, we still check previous weeks to see if the streak from last week is alive
    
    while (!streakBroken) {
      final prevWeekId = _getWeekId(checkDate);
      final prevWeekDuration = weeklyDurations[prevWeekId] ?? 0;
      
      if (prevWeekDuration >= goalHours * 3600) {
        streakCount++;
        checkDate = checkDate.subtract(const Duration(days: 7));
      } else {
        streakBroken = true;
      }
      
      // Safety break to prevent infinite loop (though checkDate decreases)
      if (streakCount > 1000) break; 
    }
  }

  return WeeklyGoalProgress(
    goalHours: goalHours,
    currentWeekHours: currentWeekSeconds / 3600.0,
    streakCount: streakCount,
  );
}

String _getWeekId(DateTime date) {
  // ISO 8601 week number logic
  // A week starts on Monday. The first week of the year is the one that contains the first Thursday.
  
  // Find Thursday of this week
  final thursday = date.add(Duration(days: 4 - date.weekday));
  
  // The year of the week is the year of that Thursday
  final year = thursday.year;
  
  // Find January 1st of that year
  final firstOfJan = DateTime(year, 1, 1);
  
  // Find the first Thursday of the year
  final firstThursday = firstOfJan.add(Duration(days: (4 - firstOfJan.weekday + 7) % 7));
  
  // The first week starts 3 days before the first Thursday
  final firstMonday = firstThursday.subtract(const Duration(days: 3));
  
  // Week number is (days since first Monday) / 7 + 1
  final weekNumber = (thursday.difference(firstMonday).inDays / 7).floor() + 1;
  
  return '$year-W${weekNumber.toString().padLeft(2, '0')}';
}
