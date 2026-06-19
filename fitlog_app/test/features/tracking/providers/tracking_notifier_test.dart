import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/core/errors/exceptions.dart';
import 'package:fitlog_app/core/permissions/permission_service.dart';
import 'package:fitlog_app/features/tracking/services/gps_service.dart';
import 'package:fitlog_app/features/tracking/models/gps_point.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';
import 'package:fitlog_app/features/tracking/models/sensor_data.dart';
import 'package:fitlog_app/app/app_providers.dart';
import 'package:fitlog_app/features/tracking/providers/tracking_notifier.dart';
import 'package:fitlog_app/features/tracking/providers/tracking_state.dart';
import 'package:isar/isar.dart';

// Fake implementations for testing
class FakePermissionService implements PermissionService {
  bool locationPermission = true;
  bool backgroundLocationPermission = true;
  bool bluetoothPermission = true;

  @override
  Future<bool> hasLocationPermission() async => locationPermission;

  @override
  Future<bool> requestLocationPermission() async => locationPermission;

  @override
  Future<bool> hasBackgroundLocationPermission() async =>
      backgroundLocationPermission;

  @override
  Future<bool> requestBackgroundLocationPermission() async =>
      backgroundLocationPermission;

  @override
  Future<bool> hasBluetoothPermission() async => bluetoothPermission;

  @override
  Future<bool> requestBluetoothPermission() async => bluetoothPermission;

  @override
  Future<bool> openSettings() async => true;
}

class FakeGpsService implements GpsService {
  final _controller = StreamController<GpsPoint>.broadcast();
  bool backgroundModeEnabled = false;
  Workout? activeWorkout;

  void emitPoint(GpsPoint point) {
    _controller.add(point);
  }

  @override
  Future<Workout?> getActiveWorkout(Isar isar) async {
    if (activeWorkout != null) return activeWorkout;
    try {
      final collection = isar.collection<Workout>() as FakeIsarCollection<Workout>;
      final index = collection.items.indexWhere((w) => !w.isCompleted);
      if (index != -1) {
        return collection.items[index];
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> configureGpsSettings() async {}

  @override
  Future<bool> enableBackgroundMode() async {
    backgroundModeEnabled = true;
    return true;
  }

  @override
  Future<bool> disableBackgroundMode() async {
    backgroundModeEnabled = false;
    return true;
  }

  @override
  Stream<GpsPoint> getGpsPointStream() => _controller.stream;
}

class FakeIsar extends Fake implements Isar {
  final collections = <Type, FakeIsarCollection<dynamic>>{};

  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) {
    return callback();
  }

  @override
  IsarCollection<T> collection<T>() {
    return collections.putIfAbsent(T, () => FakeIsarCollection<T>())
        as IsarCollection<T>;
  }
}

class FakeIsarCollection<T> extends Fake implements IsarCollection<T> {
  final List<T> items = [];

  @override
  Future<List<Id>> putAll(List<T> objects) async {
    final List<Id> ids = [];
    for (final obj in objects) {
      ids.add(await put(obj));
    }
    return ids;
  }

  @override
  Future<Id> put(T object) async {
    int? existingId;
    if (object is Workout) {
      if (object.id != Isar.autoIncrement && object.id > 0) {
        existingId = object.id;
      }
    } else if (object is GpsPoint) {
      if (object.id != Isar.autoIncrement && object.id > 0) {
        existingId = object.id;
      }
    } else if (object is SensorData) {
      if (object.id != Isar.autoIncrement && object.id > 0) {
        existingId = object.id;
      }
    }

    if (existingId != null) {
      final idx = items.indexWhere((item) {
        if (item is Workout && item.id == existingId) return true;
        if (item is GpsPoint && item.id == existingId) return true;
        if (item is SensorData && item.id == existingId) return true;
        return false;
      });
      if (idx != -1) {
        items[idx] = object;
        return existingId;
      }
    }

    final int nextId = items.length + 1;
    if (object is Workout) {
      object.id = nextId;
    } else if (object is GpsPoint) {
      object.id = nextId;
    } else if (object is SensorData) {
      object.id = nextId;
    }
    items.add(object);
    return nextId;
  }

  @override
  Future<T?> get(Id id) async {
    for (final item in items) {
      if (item is Workout && item.id == id) {
        return item as T;
      } else if (item is GpsPoint && item.id == id) {
        return item as T;
      } else if (item is SensorData && item.id == id) {
        return item as T;
      }
    }
    return null;
  }

  @override
  Future<bool> delete(Id id) async {
    final initialLength = items.length;
    items.removeWhere((item) {
      if (item is Workout && item.id == id) return true;
      if (item is GpsPoint && item.id == id) return true;
      if (item is SensorData && item.id == id) return true;
      return false;
    });
    return items.length < initialLength;
  }

  @override
  QueryBuilder<T, T, QFilterCondition> filter() {
    return FakeQueryBuilder<T>(this) as QueryBuilder<T, T, QFilterCondition>;
  }
}

class FakeQueryBuilder<T> extends Fake implements QueryBuilder<T, T, QFilterCondition> {
  final FakeIsarCollection<T> collection;
  FakeQueryBuilder(this.collection);

  FakeQueryBuilder<T> isCompletedEqualTo(bool value) {
    return this;
  }

  Future<T?> findFirst() async {
    if (T == Workout) {
      final list = collection.items as List<Workout>;
      final index = list.indexWhere((w) => !w.isCompleted);
      if (index != -1) {
        return list[index] as T?;
      }
      return null;
    }
    return collection.items.isNotEmpty ? collection.items.first : null;
  }
}

class FakeIsarLinks<T> extends Fake implements IsarLinks<T> {
  final Set<T> _items = {};

  @override
  bool add(T value) {
    return _items.add(value);
  }

  @override
  void addAll(Iterable<T> iterable) {
    _items.addAll(iterable);
  }

  @override
  List<T> toList({bool growable = true}) {
    return _items.toList(growable: growable);
  }

  @override
  int get length => _items.length;

  @override
  bool get isAttached => false;

  @override
  Future<void> load({bool overrideChanges = true}) async {}

  @override
  Future<void> save() async {}
  
  @override
  Iterator<T> get iterator => _items.iterator;
}

class MockWorkout extends Workout {
  @override
  final FakeIsarLinks<GpsPoint> gpsPoints = FakeIsarLinks<GpsPoint>();
  
  @override
  final FakeIsarLinks<SensorData> sensorData = FakeIsarLinks<SensorData>();
}

void main() {
  group('TrackingNotifier Tests', () {
    late FakePermissionService fakePermissionService;
    late FakeGpsService fakeGpsService;
    late FakeIsar fakeIsar;
    late ProviderContainer container;

    setUp(() async {
      fakePermissionService = FakePermissionService();
      fakeGpsService = FakeGpsService();
      fakeIsar = FakeIsar();
      container = ProviderContainer(
        overrides: [
          permissionServiceProvider.overrideWithValue(fakePermissionService),
          gpsServiceProvider.overrideWithValue(fakeGpsService),
          isarProvider.overrideWith((ref) => fakeIsar),
        ],
      );
      container.listen(trackingNotifierProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 10));
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is idle', () {
      final state = container.read(trackingNotifierProvider);
      expect(state.status, equals(TrackingStatus.idle));
      expect(state.sportType, equals('running'));
      expect(state.durationSeconds, equals(0.0));
      expect(state.distanceMeters, equals(0.0));
    });

    test('startTracking fails if location permission is denied', () async {
      fakePermissionService.locationPermission = false;
      final notifier = container.read(trackingNotifierProvider.notifier);

      final result = await notifier.startTracking('cycling');
      expect(result.isFailure, isTrue);
      expect(result.failureOrNullValue, isA<PermissionException>());

      final state = container.read(trackingNotifierProvider);
      expect(state.status, equals(TrackingStatus.idle));
    });

    test('startTracking succeeds if permission is granted', () async {
      final notifier = container.read(trackingNotifierProvider.notifier);

      final result = await notifier.startTracking('running');
      expect(result.isSuccess, isTrue);

      final state = container.read(trackingNotifierProvider);
      expect(state.status, equals(TrackingStatus.recording));
      expect(state.sportType, equals('running'));
      expect(state.startTime, isNotNull);
      expect(fakeGpsService.backgroundModeEnabled, isTrue);
    });

    test('timer increments duration while recording', () async {
      final notifier = container.read(trackingNotifierProvider.notifier);
      await notifier.startTracking('running');

      expect(
        container.read(trackingNotifierProvider).durationSeconds,
        equals(0.0),
      );

      notifier.tick();
      notifier.tick();
      notifier.tick();

      expect(
        container.read(trackingNotifierProvider).durationSeconds,
        equals(3.0),
      );
    });

    test('pauseTracking pauses timer and recording state', () async {
      final notifier = container.read(trackingNotifierProvider.notifier);
      await notifier.startTracking('running');

      notifier.tick();
      notifier.tick();
      expect(
        container.read(trackingNotifierProvider).durationSeconds,
        equals(2.0),
      );

      notifier.pauseTracking();
      expect(
        container.read(trackingNotifierProvider).status,
        equals(TrackingStatus.paused),
      );

      notifier.tick();
      expect(
        container.read(trackingNotifierProvider).durationSeconds,
        equals(2.0),
      );
    });

    test('resumeTracking resumes recording and timer', () async {
      final notifier = container.read(trackingNotifierProvider.notifier);
      await notifier.startTracking('running');

      notifier.pauseTracking();
      notifier.tick();
      expect(
        container.read(trackingNotifierProvider).durationSeconds,
        equals(0.0),
      );

      notifier.resumeTracking();
      expect(
        container.read(trackingNotifierProvider).status,
        equals(TrackingStatus.recording),
      );

      notifier.tick();
      notifier.tick();
      expect(
        container.read(trackingNotifierProvider).durationSeconds,
        equals(2.0),
      );
    });

    test('discardTracking cleans up resources and resets state', () async {
      final notifier = container.read(trackingNotifierProvider.notifier);
      await notifier.startTracking('running');

      notifier.discardTracking();

      final state = container.read(trackingNotifierProvider);
      expect(state.status, equals(TrackingStatus.idle));
      expect(state.durationSeconds, equals(0.0));
      expect(fakeGpsService.backgroundModeEnabled, isFalse);
    });

    test(
      'stopTracking cleans up, saves workout to Isar, and resets notifier',
      () async {
        final notifier = container.read(trackingNotifierProvider.notifier);
        await notifier.startTracking('running');

        notifier.tick();
        notifier.tick();
        notifier.tick();
        notifier.tick();
        notifier.tick();

        final result = await notifier.stopTracking();
        expect(result.isSuccess, isTrue);

        final workout = result.successOrNullValue!;
        expect(workout.sportType, equals('running'));
        expect(workout.durationSeconds, equals(5.0));
        expect(workout.isCompleted, isTrue);

        // Verify it saved to fake Isar
        final savedWorkouts =
            (fakeIsar.collection<Workout>() as FakeIsarCollection<Workout>)
                .items;
        expect(savedWorkouts.length, equals(1));
        expect(savedWorkouts.first, equals(workout));

        final activeState = container.read(trackingNotifierProvider);
        expect(activeState.status, equals(TrackingStatus.idle));
        expect(activeState.durationSeconds, equals(0.0));
      },
    );

    test('telemetry updates distance and elevation gain correctly', () async {
      final notifier = container.read(trackingNotifierProvider.notifier);
      await notifier.startTracking('running');

      // Emit first GpsPoint (starting location, altitude = 100m)
      final point1 = GpsPoint()
        ..latitude = 37.7749
        ..longitude = -122.4194
        ..altitude = 100.0
        ..speed = 3.0
        ..timestamp = DateTime.now();

      fakeGpsService.emitPoint(point1);
      await Future.microtask(() {}); // let stream listener process

      var state = container.read(trackingNotifierProvider);
      expect(state.gpsPoints.length, equals(1));
      expect(state.distanceMeters, equals(0.0));
      expect(state.elevationGain, equals(0.0));
      expect(state.currentSpeed, equals(3.0));
      expect(state.currentAltitude, equals(100.0));

      // Emit second GpsPoint (approx 11.12 meters north, altitude = 105m)
      final point2 = GpsPoint()
        ..latitude = 37.7750
        ..longitude = -122.4194
        ..altitude = 105.0
        ..speed = 4.0
        ..timestamp = DateTime.now();

      fakeGpsService.emitPoint(point2);
      await Future.microtask(() {});

      state = container.read(trackingNotifierProvider);
      expect(state.gpsPoints.length, equals(2));
      expect(state.distanceMeters, closeTo(11.12, 0.5));
      expect(state.elevationGain, equals(5.0));
      expect(state.currentSpeed, equals(4.0));
      expect(state.currentAltitude, equals(105.0));
    });

    test('setWorkoutName updates state and stopTracking saves it', () async {
      final notifier = container.read(trackingNotifierProvider.notifier);
      await notifier.startTracking('running');

      notifier.setWorkoutName('Morning Run');
      expect(
        container.read(trackingNotifierProvider).name,
        equals('Morning Run'),
      );

      final result = await notifier.stopTracking();
      expect(result.isSuccess, isTrue);

      final workout = result.successOrNullValue!;
      expect(workout.name, equals('Morning Run'));

      final savedWorkouts =
          (fakeIsar.collection<Workout>() as FakeIsarCollection<Workout>).items;
      expect(savedWorkouts.first.name, equals('Morning Run'));
    });

    test('workout writes draft to Isar at start and updates in real-time', () async {
      final notifier = container.read(trackingNotifierProvider.notifier);
      await notifier.startTracking('running');

      final savedWorkouts =
          (fakeIsar.collection<Workout>() as FakeIsarCollection<Workout>).items;
      expect(savedWorkouts.length, equals(1));
      expect(savedWorkouts.first.isCompleted, isFalse);
      expect(savedWorkouts.first.sportType, equals('running'));

      // Check real-time duration updates
      notifier.tick();
      notifier.tick();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(savedWorkouts.first.durationSeconds, equals(2.0));

      // Emit a GPS point
      final point = GpsPoint()
        ..latitude = 37.7749
        ..longitude = -122.4194
        ..altitude = 100.0
        ..speed = 3.0
        ..timestamp = DateTime.now();
      fakeGpsService.emitPoint(point);
      
      // Check points are saved in real-time with a loop
      List<GpsPoint> savedPoints = [];
      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(milliseconds: 10));
        savedPoints = (fakeIsar.collection<GpsPoint>() as FakeIsarCollection<GpsPoint>).items;
        if (savedPoints.length == 1) {
          break;
        }
      }
      expect(savedPoints.length, equals(1));
      expect(savedPoints.first.latitude, equals(37.7749));
    });

    test('pause and resume persist isPaused state to database', () async {
      final notifier = container.read(trackingNotifierProvider.notifier);
      await notifier.startTracking('running');

      final savedWorkouts =
          (fakeIsar.collection<Workout>() as FakeIsarCollection<Workout>).items;
      expect(savedWorkouts.first.isPaused, isFalse);

      notifier.pauseTracking();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(savedWorkouts.first.isPaused, isTrue);

      notifier.resumeTracking();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(savedWorkouts.first.isPaused, isFalse);
    });

    test('active uncompleted workout is restored on start', () async {
      // 1. Manually insert an uncompleted workout into the database
      final draftWorkout = MockWorkout()
        ..sportType = 'cycling'
        ..startTime = DateTime.now()
        ..durationSeconds = 120.0
        ..distanceMeters = 500.0
        ..isCompleted = false
        ..isPaused = true;
      
      final workoutsCollection = fakeIsar.collection<Workout>() as FakeIsarCollection<Workout>;
      await workoutsCollection.put(draftWorkout);

      // Also put a GPS point and attach it
      final point = GpsPoint()
        ..latitude = 37.7749
        ..longitude = -122.4194
        ..altitude = 100.0
        ..speed = 5.0
        ..timestamp = DateTime.now();
      final gpsCollection = fakeIsar.collection<GpsPoint>() as FakeIsarCollection<GpsPoint>;
      await gpsCollection.put(point);
      draftWorkout.gpsPoints.add(point);

      // 2. Initialize a new container to simulate app restart
      final newContainer = ProviderContainer(
        overrides: [
          permissionServiceProvider.overrideWithValue(fakePermissionService),
          gpsServiceProvider.overrideWithValue(fakeGpsService),
          isarProvider.overrideWith((ref) => fakeIsar),
        ],
      );
      
      // Trigger lazy build() and keep it alive
      newContainer.listen(trackingNotifierProvider, (_, __) {});
      
      // Let the initialization delayed future run
      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(milliseconds: 10));
        if (newContainer.read(trackingNotifierProvider).status != TrackingStatus.idle) {
          break;
        }
      }

      final state = newContainer.read(trackingNotifierProvider);
      expect(state.status, equals(TrackingStatus.paused));
      expect(state.sportType, equals('cycling'));
      expect(state.durationSeconds, equals(120.0));
      expect(state.distanceMeters, equals(500.0));
      expect(state.gpsPoints.length, equals(1));
      expect(state.gpsPoints.first.latitude, equals(37.7749));

      newContainer.dispose();
    });
  });
}
