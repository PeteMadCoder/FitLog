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
String _$workoutsByMonthHash() => r'89237b545c09ee8f8ec866e25809a6ac637acb9c';

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

/// Provider exposing workouts for a specific month.
///
/// Copied from [workoutsByMonth].
@ProviderFor(workoutsByMonth)
const workoutsByMonthProvider = WorkoutsByMonthFamily();

/// Provider exposing workouts for a specific month.
///
/// Copied from [workoutsByMonth].
class WorkoutsByMonthFamily extends Family<AsyncValue<List<Workout>>> {
  /// Provider exposing workouts for a specific month.
  ///
  /// Copied from [workoutsByMonth].
  const WorkoutsByMonthFamily();

  /// Provider exposing workouts for a specific month.
  ///
  /// Copied from [workoutsByMonth].
  WorkoutsByMonthProvider call(DateTime month) {
    return WorkoutsByMonthProvider(month);
  }

  @override
  WorkoutsByMonthProvider getProviderOverride(
    covariant WorkoutsByMonthProvider provider,
  ) {
    return call(provider.month);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'workoutsByMonthProvider';
}

/// Provider exposing workouts for a specific month.
///
/// Copied from [workoutsByMonth].
class WorkoutsByMonthProvider extends AutoDisposeStreamProvider<List<Workout>> {
  /// Provider exposing workouts for a specific month.
  ///
  /// Copied from [workoutsByMonth].
  WorkoutsByMonthProvider(DateTime month)
    : this._internal(
        (ref) => workoutsByMonth(ref as WorkoutsByMonthRef, month),
        from: workoutsByMonthProvider,
        name: r'workoutsByMonthProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$workoutsByMonthHash,
        dependencies: WorkoutsByMonthFamily._dependencies,
        allTransitiveDependencies:
            WorkoutsByMonthFamily._allTransitiveDependencies,
        month: month,
      );

  WorkoutsByMonthProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.month,
  }) : super.internal();

  final DateTime month;

  @override
  Override overrideWith(
    Stream<List<Workout>> Function(WorkoutsByMonthRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WorkoutsByMonthProvider._internal(
        (ref) => create(ref as WorkoutsByMonthRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Workout>> createElement() {
    return _WorkoutsByMonthProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkoutsByMonthProvider && other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WorkoutsByMonthRef on AutoDisposeStreamProviderRef<List<Workout>> {
  /// The parameter `month` of this provider.
  DateTime get month;
}

class _WorkoutsByMonthProviderElement
    extends AutoDisposeStreamProviderElement<List<Workout>>
    with WorkoutsByMonthRef {
  _WorkoutsByMonthProviderElement(super.provider);

  @override
  DateTime get month => (origin as WorkoutsByMonthProvider).month;
}

String _$calendarMonthHash() => r'9bddad347bd76603d67736cd6ee9e476677830e6';

/// Provider to track the currently viewed month in the calendar.
///
/// Copied from [CalendarMonth].
@ProviderFor(CalendarMonth)
final calendarMonthProvider =
    AutoDisposeNotifierProvider<CalendarMonth, DateTime>.internal(
      CalendarMonth.new,
      name: r'calendarMonthProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$calendarMonthHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CalendarMonth = AutoDisposeNotifier<DateTime>;
String _$diaryViewModeHash() => r'084e8e28a7a694755eec8611ee7d04326b84d0c0';

/// Provider to track the selected view mode (List vs Calendar).
///
/// Copied from [DiaryViewMode].
@ProviderFor(DiaryViewMode)
final diaryViewModeProvider =
    AutoDisposeNotifierProvider<DiaryViewMode, bool>.internal(
      DiaryViewMode.new,
      name: r'diaryViewModeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$diaryViewModeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DiaryViewMode = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
