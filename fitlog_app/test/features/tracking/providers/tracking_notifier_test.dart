import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/core/errors/exceptions.dart';
import 'package:fitlog_app/core/permissions/permission_service.dart';
import 'package:fitlog_app/features/tracking/services/gps_service.dart';
import 'package:fitlog_app/features/tracking/models/gps_point.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';
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

  void emitPoint(GpsPoint point) {
    _controller.add(point);
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
    items.addAll(objects);
    return List.generate(objects.length, (index) => index);
  }

  @override
  Future<Id> put(T object) async {
    items.add(object);
    return items.length - 1;
  }
}

void main() {
  group('TrackingNotifier Tests', () {
    late FakePermissionService fakePermissionService;
    late FakeGpsService fakeGpsService;
    late FakeIsar fakeIsar;
    late ProviderContainer container;

    setUp(() {
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
  });
}
