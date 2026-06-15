import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import 'package:fitlog_app/app/app_providers.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';

part 'diary_providers.g.dart';

/// Provider exposing a real-time stream of all workouts from Isar sorted by date.
@riverpod
Stream<List<Workout>> workoutHistory(WorkoutHistoryRef ref) async* {
  final isar = await ref.watch(isarProvider.future);

  // Watch all workouts, sorted by startTime descending.
  final query = isar.workouts.where().sortByStartTimeDesc();
  yield* query.watch(fireImmediately: true);
}

/// Provider to track the currently viewed month in the calendar.
@riverpod
class CalendarMonth extends _$CalendarMonth {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void setMonth(DateTime month) {
    state = DateTime(month.year, month.month);
  }

  void nextMonth() {
    state = DateTime(state.year, state.month + 1);
  }

  void previousMonth() {
    state = DateTime(state.year, state.month - 1);
  }
}

/// Provider exposing workouts for a specific month.
@riverpod
Stream<List<Workout>> workoutsByMonth(WorkoutsByMonthRef ref, DateTime month) async* {
  final isar = await ref.watch(isarProvider.future);
  
  final startOfMonth = DateTime(month.year, month.month);
  final endOfMonth = DateTime(month.year, month.month + 1).subtract(const Duration(milliseconds: 1));

  final query = isar.workouts
      .filter()
      .startTimeBetween(startOfMonth, endOfMonth)
      .sortByStartTimeDesc();
      
  yield* query.watch(fireImmediately: true);
}

/// Provider to track the selected view mode (List vs Calendar).
@riverpod
class DiaryViewMode extends _$DiaryViewMode {
  @override
  bool build() => false; // false = List, true = Calendar

  void toggle() => state = !state;
}
