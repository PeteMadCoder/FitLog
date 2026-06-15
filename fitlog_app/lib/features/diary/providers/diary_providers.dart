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
