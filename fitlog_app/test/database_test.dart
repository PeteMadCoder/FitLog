import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';
import 'package:fitlog_app/features/tracking/models/gps_point.dart';
import 'package:fitlog_app/features/tracking/models/sensor_data.dart';
import 'package:fitlog_app/app/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Isar Model Tests', () {
    test('Workout model can be instantiated and modified', () {
      final startTime = DateTime(2026, 6, 14, 10, 0);
      final workout = Workout()
        ..name = 'Morning Run'
        ..sportType = 'running'
        ..startTime = startTime
        ..durationSeconds = 1800.0
        ..distanceMeters = 5000.0
        ..averageSpeed = 2.78
        ..maxSpeed = 3.5
        ..averageHeartRate = 150.0
        ..maxHeartRate = 175.0
        ..calories = 350.0
        ..isCompleted = true;

      expect(workout.name, equals('Morning Run'));
      expect(workout.sportType, equals('running'));
      expect(workout.startTime, equals(startTime));
      expect(workout.durationSeconds, equals(1800.0));
      expect(workout.distanceMeters, equals(5000.0));
      expect(workout.averageSpeed, equals(2.78));
      expect(workout.maxSpeed, equals(3.5));
      expect(workout.averageHeartRate, equals(150.0));
      expect(workout.maxHeartRate, equals(175.0));
      expect(workout.calories, equals(350.0));
      expect(workout.isCompleted, isTrue);
    });

    test('GpsPoint model can be instantiated and modified', () {
      final now = DateTime.now();
      final point = GpsPoint()
        ..timestamp = now
        ..latitude = 37.7749
        ..longitude = -122.4194
        ..altitude = 15.0
        ..accuracy = 5.0
        ..speed = 3.2;

      expect(point.timestamp, equals(now));
      expect(point.latitude, equals(37.7749));
      expect(point.longitude, equals(-122.4194));
      expect(point.altitude, equals(15.0));
      expect(point.accuracy, equals(5.0));
      expect(point.speed, equals(3.2));
    });

    test('SensorData model can be instantiated and modified', () {
      final now = DateTime.now();
      final sensor = SensorData()
        ..timestamp = now
        ..sensorType = 'heart_rate'
        ..value = 145.0;

      expect(sensor.timestamp, equals(now));
      expect(sensor.sensorType, equals('heart_rate'));
      expect(sensor.value, equals(145.0));
    });
  });

  group('Isar Provider Tests', () {
    test(
      'isarProvider is defined and returns a FutureProvider in loading state initially',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final subscription = container.listen(
          isarProvider,
          (previous, next) {},
        );

        expect(subscription.read(), const AsyncValue<Isar>.loading());
      },
    );
  });
}
