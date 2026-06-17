import 'package:flutter_test/flutter_test.dart';
import 'package:fitlog_app/features/analytics/providers/analytics_providers.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';

void main() {
  group('Weekly Goal Logic Tests', () {
    final now = DateTime(2026, 6, 17); // Wednesday

    test('should return zero progress when no workouts', () {
      final result = calculateWeeklyGoalProgress(
        workouts: [],
        goalHours: 5.0,
        now: now,
      );

      expect(result.currentWeekHours, equals(0.0));
      expect(result.completedWeeksCount, equals(0));
      expect(result.goalHours, equals(5.0));
      expect(result.progressPercentage, equals(0.0));
      expect(result.isGoalMet, isFalse);
    });

    test('should calculate current week progress correctly', () {
      final workouts = [
        Workout()
          ..startTime = DateTime(2026, 6, 16, 10, 0) // Tuesday (this week)
          ..durationSeconds = 3600.0, // 1 hour
        Workout()
          ..startTime = DateTime(2026, 6, 15, 0, 1) // Monday (this week)
          ..durationSeconds = 1800.0, // 0.5 hour
        Workout()
          ..startTime = DateTime(2026, 6, 14, 23, 59) // Sunday (last week)
          ..durationSeconds = 7200.0, // 2 hours
      ];

      final result = calculateWeeklyGoalProgress(
        workouts: workouts,
        goalHours: 3.0,
        now: now,
      );

      expect(result.currentWeekHours, equals(1.5));
      expect(result.goalHours, equals(3.0));
      expect(result.progressPercentage, equals(0.5));
    });

    test('should count completed weeks correctly', () {
      final workouts = [
        // Current week: 2 hours (goal 3) -> Not completed yet
        Workout()
          ..startTime = DateTime(2026, 6, 16)
          ..durationSeconds = 7200.0,
        
        // Last week (Starts June 8): 4 hours -> Completed
        Workout()
          ..startTime = DateTime(2026, 6, 9)
          ..durationSeconds = 14400.0,
          
        // Two weeks ago (Starts June 1): 2.5 hours -> Not completed
        Workout()
          ..startTime = DateTime(2026, 6, 2)
          ..durationSeconds = 9000.0,

        // Three weeks ago (Starts May 25): 3.5 hours -> Completed
        Workout()
          ..startTime = DateTime(2026, 5, 26)
          ..durationSeconds = 12600.0,
      ];

      final result = calculateWeeklyGoalProgress(
        workouts: workouts,
        goalHours: 3.0,
        now: now,
      );

      // Current week is 2h, so 2 completed weeks (June 8 week and May 25 week)
      // Actually, my logic counts ALL weeks including current one if met.
      // In this case current is 2h < 3h, so it doesn't count.
      expect(result.completedWeeksCount, equals(2));
    });

    test('isGoalMet should be true when current week hours >= goal', () {
      final workouts = [
        Workout()
          ..startTime = DateTime(2026, 6, 15)
          ..durationSeconds = 10800.0, // 3 hours
      ];

      final result = calculateWeeklyGoalProgress(
        workouts: workouts,
        goalHours: 3.0,
        now: now,
      );

      expect(result.isGoalMet, isTrue);
      expect(result.progressPercentage, equals(1.0));
    });
  });
}
