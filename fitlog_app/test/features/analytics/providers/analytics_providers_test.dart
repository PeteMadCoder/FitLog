import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/analytics/providers/analytics_providers.dart';
import 'package:fitlog_app/app/app_providers.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';
import 'package:fitlog_app/features/tracking/models/gps_point.dart';
import 'package:fitlog_app/features/tracking/models/sensor_data.dart';
import 'package:isar/isar.dart';

class FakeIsarLinks<T> extends Fake implements IsarLinks<T> {
  final List<T> _items;
  bool isLoaded = false;
  FakeIsarLinks(this._items);

  @override
  List<T> toList({bool growable = true}) => _items;

  @override
  int get length => _items.length;

  @override
  bool get isEmpty => _items.isEmpty;

  @override
  bool get isNotEmpty => _items.isNotEmpty;

  @override
  Iterator<T> get iterator => _items.iterator;

  @override
  bool get isAttached => true;

  @override
  Future<void> load({bool overrideChanges = true}) async {
    isLoaded = true;
  }

  @override
  Iterable<R> map<R>(R Function(T e) toElement) => _items.map(toElement);
}

class TestWorkout extends Workout {
  @override
  final FakeIsarLinks<GpsPoint> gpsPoints;

  @override
  final FakeIsarLinks<SensorData> sensorData;

  TestWorkout(List<GpsPoint> gps, List<SensorData> sensor)
      : gpsPoints = FakeIsarLinks<GpsPoint>(gps),
        sensorData = FakeIsarLinks<SensorData>(sensor);
}

class FakeIsar extends Fake implements Isar {
  final workoutsCollection = FakeWorkoutsCollection();
  final gpsCollection = FakeGpsCollection();
  final sensorCollection = FakeSensorCollection();

  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) {
    return callback();
  }

  @override
  IsarCollection<T> collection<T>() {
    if (T == Workout) {
      return workoutsCollection as IsarCollection<T>;
    } else if (T == GpsPoint) {
      return gpsCollection as IsarCollection<T>;
    } else if (T == SensorData) {
      return sensorCollection as IsarCollection<T>;
    }
    throw UnimplementedError('No fake collection for $T');
  }

  FakeWorkoutsCollection get workouts => workoutsCollection;
  FakeGpsCollection get gpsPoints => gpsCollection;
  FakeSensorCollection get sensorDatas => sensorCollection;
}

class FakeWorkoutsCollection extends Fake implements IsarCollection<Workout> {
  final Map<int, Workout> items = {};

  @override
  Future<Workout?> get(Id id) async {
    return items[id];
  }

  @override
  Future<bool> delete(Id id) async {
    return items.remove(id) != null;
  }
}

class FakeGpsCollection extends Fake implements IsarCollection<GpsPoint> {
  final List<int> deletedIds = [];

  @override
  Future<int> deleteAll(List<Id> ids) async {
    deletedIds.addAll(ids);
    return ids.length;
  }
}

class FakeSensorCollection extends Fake implements IsarCollection<SensorData> {
  final List<int> deletedIds = [];

  @override
  Future<int> deleteAll(List<Id> ids) async {
    deletedIds.addAll(ids);
    return ids.length;
  }
}

void main() {
  group('SelectedStatsTimeframe Provider', () {
    test('initial state should be weekly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(selectedStatsTimeframeProvider),
        equals(StatsTimeframe.weekly),
      );
    });

    test('setTimeframe should update state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(selectedStatsTimeframeProvider.notifier)
          .setTimeframe(StatsTimeframe.monthly);
      expect(
        container.read(selectedStatsTimeframeProvider),
        equals(StatsTimeframe.monthly),
      );

      container
          .read(selectedStatsTimeframeProvider.notifier)
          .setTimeframe(StatsTimeframe.yearly);
      expect(
        container.read(selectedStatsTimeframeProvider),
        equals(StatsTimeframe.yearly),
      );
    });
  });

  group('AggregatedStats factory', () {
    test('empty factory should return zeroed stats', () {
      final stats = AggregatedStats.empty();
      expect(stats.totalDistanceMeters, equals(0));
      expect(stats.totalDuration, equals(Duration.zero));
      expect(stats.totalCalories, equals(0));
      expect(stats.workoutCount, equals(0));
    });
  });

  group('WorkoutEditor deleteWorkout', () {
    test('deleteWorkout loads relations, deletes telemetry, and deletes workout', () async {
      final fakeIsar = FakeIsar();
      final container = ProviderContainer(
        overrides: [
          isarProvider.overrideWith((ref) => fakeIsar),
        ],
      );
      addTearDown(container.dispose);

      final gpsPoint = GpsPoint()..id = 101;
      final sensorData = SensorData()..id = 202;
      final workout = TestWorkout([gpsPoint], [sensorData]);
      
      fakeIsar.workoutsCollection.items[1] = workout;

      final notifier = container.read(workoutEditorProvider.notifier);
      await notifier.deleteWorkout(1);

      // Verify deletion from workouts collection
      expect(fakeIsar.workoutsCollection.items.containsKey(1), isFalse);
      
      // Verify deletion from other collections
      expect(fakeIsar.gpsCollection.deletedIds, contains(101));
      expect(fakeIsar.sensorCollection.deletedIds, contains(202));

      // Verify that relations were loaded before deletion
      expect((workout.gpsPoints as FakeIsarLinks).isLoaded, isTrue);
      expect((workout.sensorData as FakeIsarLinks).isLoaded, isTrue);
    });
  });
}
