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

String _$dashboardStatsHash() => r'e38d61dd8e8646437d9d7e451c266da87f9dfb6a';

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
String _$selectedStatsTimeframeHash() =>
    r'8d6d05b048d97a49b635b1d1158f3cedb36e4139';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
