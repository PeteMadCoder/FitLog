import 'package:riverpod_annotation/riverpod_annotation.dart';
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
