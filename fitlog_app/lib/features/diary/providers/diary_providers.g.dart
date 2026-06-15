// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workoutHistoryHash() => r'00f2fe758c4e2da91bcf07f05075615fd16ba21f';

/// Provider exposing a real-time stream of all workouts from Isar sorted by date.
///
/// Copied from [workoutHistory].
@ProviderFor(workoutHistory)
final workoutHistoryProvider =
    AutoDisposeStreamProvider<List<Workout>>.internal(
      workoutHistory,
      name: r'workoutHistoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$workoutHistoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef WorkoutHistoryRef = AutoDisposeStreamProviderRef<List<Workout>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
