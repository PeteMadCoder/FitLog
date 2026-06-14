import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';
import 'package:fitlog_app/app/app_providers.dart';
import 'package:fitlog_app/features/analytics/providers/analytics_providers.dart';

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
  final _controller = StreamController<T?>.broadcast();

  @override
  Future<List<Id>> putAll(List<T> objects) async {
    items.addAll(objects);
    return List.generate(objects.length, (index) => index);
  }

  @override
  Future<Id> put(T object) async {
    items.add(object);
    _controller.add(object);
    return items.length - 1;
  }

  @override
  Stream<T?> watchObject(Id id, {bool fireImmediately = false}) async* {
    T? found;
    if (id >= 0 && id < items.length) {
      found = items[id];
    }
    if (fireImmediately) {
      yield found;
    }
    yield* _controller.stream;
  }
}

void main() {
  group('Analytics Providers Tests', () {
    late FakeIsar fakeIsar;
    late ProviderContainer container;

    setUp(() {
      fakeIsar = FakeIsar();
      container = ProviderContainer(
        overrides: [isarProvider.overrideWith((ref) => fakeIsar)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'workoutDetailProvider streams null if workout does not exist',
      () async {
        final stream = container.read(workoutDetailProvider(99).stream);
        final list = await stream.take(1).toList();
        expect(list.first, isNull);
      },
    );

    test('workoutDetailProvider streams the workout if it exists', () async {
      final workout = Workout()
        ..sportType = 'running'
        ..startTime = DateTime.now()
        ..durationSeconds = 1200
        ..distanceMeters = 3000;

      final workoutsCollection =
          fakeIsar.collection<Workout>() as FakeIsarCollection<Workout>;
      await workoutsCollection.put(workout);

      final stream = container.read(workoutDetailProvider(0).stream);
      final list = await stream.take(1).toList();
      expect(list.first, equals(workout));
    });
  });
}
