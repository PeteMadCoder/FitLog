import 'package:flutter_test/flutter_test.dart';
import 'package:fitlog_app/core/utils/pace_calculator.dart';

void main() {
  group('PaceCalculator Tests', () {
    group('calculatePaceMinPerKm', () {
      test('calculates pace correctly for standard speeds', () {
        // 5 m/s = 18 km/h. Pace = 60 / 18 = 3.3333 min/km
        final pace = PaceCalculator.calculatePaceMinPerKm(5.0);
        expect(pace, closeTo(3.3333, 0.0001));

        // 2.7778 m/s = 10 km/h. Pace = 60 / 10 = 6 min/km
        final pace10 = PaceCalculator.calculatePaceMinPerKm(2.7778);
        expect(pace10, closeTo(6.0, 0.01));
      });

      test('returns null for very low or zero speed', () {
        expect(PaceCalculator.calculatePaceMinPerKm(0.0), isNull);
        expect(PaceCalculator.calculatePaceMinPerKm(0.04), isNull);
      });
    });

    group('calculateAveragePaceMinPerKm', () {
      test('calculates average pace correctly', () {
        // 10 minutes (600s) to cover 2000m (2km) -> 5 min/km
        final pace = PaceCalculator.calculateAveragePaceMinPerKm(
          const Duration(minutes: 10),
          2000.0,
        );
        expect(pace, closeTo(5.0, 0.0001));
      });

      test('returns null for zero or short distance', () {
        expect(
          PaceCalculator.calculateAveragePaceMinPerKm(
            const Duration(minutes: 10),
            0.0,
          ),
          isNull,
        );
        expect(
          PaceCalculator.calculateAveragePaceMinPerKm(
            const Duration(minutes: 10),
            0.5,
          ),
          isNull,
        );
      });
    });

    group('formatPace', () {
      test('formats valid pace values correctly', () {
        expect(PaceCalculator.formatPace(5.5), equals('5:30'));
        expect(PaceCalculator.formatPace(6.0), equals('6:00'));
        expect(PaceCalculator.formatPace(4.75), equals('4:45'));
      });

      test('handles rounding of seconds correctly', () {
        // 5.999 minutes is ~5:59.94 -> rounds to 6:00
        expect(PaceCalculator.formatPace(5.999), equals('6:00'));
      });

      test('returns placeholder for null or invalid values', () {
        expect(PaceCalculator.formatPace(null), equals('--:--'));
        expect(PaceCalculator.formatPace(double.infinity), equals('--:--'));
        expect(PaceCalculator.formatPace(double.nan), equals('--:--'));
        expect(PaceCalculator.formatPace(-1.0), equals('--:--'));
      });
    });
  });
}
