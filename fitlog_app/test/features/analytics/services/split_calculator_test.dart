import 'package:flutter_test/flutter_test.dart';
import 'package:fitlog_app/features/tracking/models/gps_point.dart';
import 'package:fitlog_app/features/analytics/services/split_calculator.dart';

void main() {
  group('SplitCalculator Tests', () {
    test('returns empty list if points are less than 2', () {
      expect(SplitCalculator.calculateSplits([]), isEmpty);

      final point = GpsPoint()
        ..latitude = 0.0
        ..longitude = 0.0
        ..timestamp = DateTime(2026, 6, 14, 10, 0);
      expect(SplitCalculator.calculateSplits([point]), isEmpty);
    });

    test('calculates standard 1km splits and final partial split correctly', () {
      final now = DateTime(2026, 6, 14, 10, 0);

      // We will place points along the equator (0 lat)
      // 0.008983 degrees longitude at the equator is approx 1000 meters.
      // Point 1: 0m
      final p1 = GpsPoint()
        ..latitude = 0.0
        ..longitude = 0.0
        ..altitude = 100.0
        ..speed = 5.0
        ..timestamp = now;

      // Point 2: 500m (0.0044915 deg) at 1 minute
      final p2 = GpsPoint()
        ..latitude = 0.0
        ..longitude = 0.0044915
        ..altitude = 100.0
        ..speed = 5.0
        ..timestamp = now.add(const Duration(minutes: 1));

      // Point 3: 1000m (0.008983 deg) at 2 minutes
      final p3 = GpsPoint()
        ..latitude = 0.0
        ..longitude = 0.008983
        ..altitude = 100.0
        ..speed = 5.0
        ..timestamp = now.add(const Duration(minutes: 2));

      // Point 4: 1500m (0.0134745 deg) at 3 minutes
      final p4 = GpsPoint()
        ..latitude = 0.0
        ..longitude = 0.0134745
        ..altitude = 100.0
        ..speed = 5.0
        ..timestamp = now.add(const Duration(minutes: 3));

      // Point 5: 2300m (0.0206609 deg) at 5 minutes
      final p5 = GpsPoint()
        ..latitude = 0.0
        ..longitude = 0.0206609
        ..altitude = 100.0
        ..speed = 5.0
        ..timestamp = now.add(const Duration(minutes: 5));

      final splits = SplitCalculator.calculateSplits([p1, p2, p3, p4, p5]);

      // Total distance is approx 2300m.
      // Split 1: 1000m, Split 2: 1000m, Split 3 (partial): ~300m.
      expect(splits.length, equals(3));

      // Check Split 1
      expect(splits[0].index, equals(1));
      expect(splits[0].distanceMeters, equals(1000.0));
      expect(splits[0].duration.inMinutes, equals(2));

      // Check Split 2
      expect(splits[1].index, equals(2));
      expect(splits[1].distanceMeters, equals(1000.0));
      // Split 2 boundary is 2000m. 2000m lies between Point 4 (1500m, 3 min) and Point 5 (2300m, 5 min).
      // Interpolated time at 2000m is 3 min + (500/800) * 2 min = 3 min + 75 sec = 4 min 15 sec from start.
      // So Split 2 duration is 4 min 15 sec - 2 min = 2 min 15 sec.
      expect(splits[1].duration.inSeconds, closeTo(135.0, 5.0));

      // Check Split 3 (partial remaining)
      expect(splits[2].index, equals(3));
      expect(splits[2].distanceMeters, closeTo(300.0, 10.0));
      // Remaining duration is 5 min - 4 min 15 sec = 45 sec.
      expect(splits[2].duration.inSeconds, closeTo(45.0, 5.0));
    });
  });
}
