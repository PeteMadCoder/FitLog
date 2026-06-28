// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workoutDetailHash() => r'b7c5ddd99a716d6876b09bf255e70a662e0c922e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider exposing a real-time stream of a specific [Workout] by its [id].
/// Automatically loads the associated GPS point links upon retrieval.
///
/// Copied from [workoutDetail].
@ProviderFor(workoutDetail)
const workoutDetailProvider = WorkoutDetailFamily();

/// Provider exposing a real-time stream of a specific [Workout] by its [id].
/// Automatically loads the associated GPS point links upon retrieval.
///
/// Copied from [workoutDetail].
class WorkoutDetailFamily extends Family<AsyncValue<Workout?>> {
  /// Provider exposing a real-time stream of a specific [Workout] by its [id].
  /// Automatically loads the associated GPS point links upon retrieval.
  ///
  /// Copied from [workoutDetail].
  const WorkoutDetailFamily();

  /// Provider exposing a real-time stream of a specific [Workout] by its [id].
  /// Automatically loads the associated GPS point links upon retrieval.
  ///
  /// Copied from [workoutDetail].
  WorkoutDetailProvider call(
    int id,
  ) {
    return WorkoutDetailProvider(
      id,
    );
  }

  @override
  WorkoutDetailProvider getProviderOverride(
    covariant WorkoutDetailProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'workoutDetailProvider';
}

/// Provider exposing a real-time stream of a specific [Workout] by its [id].
/// Automatically loads the associated GPS point links upon retrieval.
///
/// Copied from [workoutDetail].
class WorkoutDetailProvider extends AutoDisposeStreamProvider<Workout?> {
  /// Provider exposing a real-time stream of a specific [Workout] by its [id].
  /// Automatically loads the associated GPS point links upon retrieval.
  ///
  /// Copied from [workoutDetail].
  WorkoutDetailProvider(
    int id,
  ) : this._internal(
          (ref) => workoutDetail(
            ref as WorkoutDetailRef,
            id,
          ),
          from: workoutDetailProvider,
          name: r'workoutDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$workoutDetailHash,
          dependencies: WorkoutDetailFamily._dependencies,
          allTransitiveDependencies:
              WorkoutDetailFamily._allTransitiveDependencies,
          id: id,
        );

  WorkoutDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    Stream<Workout?> Function(WorkoutDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WorkoutDetailProvider._internal(
        (ref) => create(ref as WorkoutDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Workout?> createElement() {
    return _WorkoutDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkoutDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WorkoutDetailRef on AutoDisposeStreamProviderRef<Workout?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _WorkoutDetailProviderElement
    extends AutoDisposeStreamProviderElement<Workout?> with WorkoutDetailRef {
  _WorkoutDetailProviderElement(super.provider);

  @override
  int get id => (origin as WorkoutDetailProvider).id;
}

String _$dashboardStatsHash() => r'f8a768a95c85dcfa4d0ec85e7c1b4b4e4fa1652b';

/// Provider that aggregates workout data based on the selected timeframe.
///
/// Copied from [dashboardStats].
@ProviderFor(dashboardStats)
final dashboardStatsProvider =
    AutoDisposeStreamProvider<AggregatedStats>.internal(
  dashboardStats,
  name: r'dashboardStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DashboardStatsRef = AutoDisposeStreamProviderRef<AggregatedStats>;
String _$statsWorkoutsHash() => r'ed3d82a209344055943afc2ae66daeb29cc58b74';

/// Provider exposing workouts for the selected timeframe.
///
/// Copied from [statsWorkouts].
@ProviderFor(statsWorkouts)
final statsWorkoutsProvider = AutoDisposeStreamProvider<List<Workout>>.internal(
  statsWorkouts,
  name: r'statsWorkoutsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$statsWorkoutsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StatsWorkoutsRef = AutoDisposeStreamProviderRef<List<Workout>>;
String _$latestWorkoutHash() => r'241e35e78f1c2e694abab8ba46cb80487a3d92a1';

/// Provider exposing the most recent completed workout.
///
/// Copied from [latestWorkout].
@ProviderFor(latestWorkout)
final latestWorkoutProvider = AutoDisposeStreamProvider<Workout?>.internal(
  latestWorkout,
  name: r'latestWorkoutProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$latestWorkoutHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LatestWorkoutRef = AutoDisposeStreamProviderRef<Workout?>;
String _$weeklyActivitySummaryHash() =>
    r'3a761ba5e603dd2b0f40bac261ed415909e36961';

/// Provider exposing a weekly activity summary grouped by sport type.
///
/// Copied from [weeklyActivitySummary].
@ProviderFor(weeklyActivitySummary)
final weeklyActivitySummaryProvider =
    AutoDisposeStreamProvider<WeeklyActivitySummary>.internal(
  weeklyActivitySummary,
  name: r'weeklyActivitySummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$weeklyActivitySummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WeeklyActivitySummaryRef
    = AutoDisposeStreamProviderRef<WeeklyActivitySummary>;
String _$weeklyGoalProgressHash() =>
    r'749b3fc4a2ae09f4a09da2bea67a41c6a413f54f';

/// Provider exposing the weekly goal progress.
///
/// Copied from [weeklyGoalProgress].
@ProviderFor(weeklyGoalProgress)
final weeklyGoalProgressProvider =
    AutoDisposeStreamProvider<WeeklyGoalProgress>.internal(
  weeklyGoalProgress,
  name: r'weeklyGoalProgressProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$weeklyGoalProgressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WeeklyGoalProgressRef
    = AutoDisposeStreamProviderRef<WeeklyGoalProgress>;
String _$workoutEditorHash() => r'9bd8f02a9e680612e545eb94006723b1d8c10f87';

/// Notifier to handle editing and deleting workouts.
///
/// Copied from [WorkoutEditor].
@ProviderFor(WorkoutEditor)
final workoutEditorProvider =
    AutoDisposeNotifierProvider<WorkoutEditor, void>.internal(
  WorkoutEditor.new,
  name: r'workoutEditorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$workoutEditorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WorkoutEditor = AutoDisposeNotifier<void>;
String _$selectedStatsTimeframeHash() =>
    r'ce091ae81f0ffc395c222eaa072da85903a42c21';

/// Provider to track the selected timeframe for statistics.
///
/// Copied from [SelectedStatsTimeframe].
@ProviderFor(SelectedStatsTimeframe)
final selectedStatsTimeframeProvider = AutoDisposeNotifierProvider<
    SelectedStatsTimeframe, StatsTimeframe>.internal(
  SelectedStatsTimeframe.new,
  name: r'selectedStatsTimeframeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedStatsTimeframeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedStatsTimeframe = AutoDisposeNotifier<StatsTimeframe>;
String _$statsReferenceDateHash() =>
    r'6c2caf22e89f3d54f288df1a1c04e948aeb23e75';

/// Provider to track the reference date for pagination back/forth in statistics.
///
/// Copied from [StatsReferenceDate].
@ProviderFor(StatsReferenceDate)
final statsReferenceDateProvider =
    AutoDisposeNotifierProvider<StatsReferenceDate, DateTime>.internal(
  StatsReferenceDate.new,
  name: r'statsReferenceDateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$statsReferenceDateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StatsReferenceDate = AutoDisposeNotifier<DateTime>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
