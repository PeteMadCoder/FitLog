import 'package:flutter_test/flutter_test.dart';
import 'package:fitlog_app/features/analytics/providers/analytics_providers.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';

void main() {
  group('Weekly Goal Logic Tests (Streak Edition)', () {
    final now = DateTime(2026, 6, 17); // Wednesday, June 17, 2026

    test('should return zero streak when no workouts', () {
      final result = calculateWeeklyGoalProgress(
        workouts: [],
        goalHours: 5.0,
        now: now,
      );

      expect(result.currentWeekHours, equals(0.0));
      expect(result.streakCount, equals(0));
    });

    test('streak should be 1 if only current week is met', () {
      final workouts = [
        Workout()
          ..startTime = DateTime(2026, 6, 16) // Tuesday
          ..durationSeconds = 10800.0, // 3 hours
      ];

      final result = calculateWeeklyGoalProgress(
        workouts: workouts,
        goalHours: 3.0,
        now: now,
      );

      expect(result.streakCount, equals(1));
    });

    test('streak should include consecutive previous weeks', () {
      final workouts = [
        // Current week (June 15 - 21): 3h
        Workout()
          ..startTime = DateTime(2026, 6, 16)
          ..durationSeconds = 10800.0,
        
        // Last week (June 8 - 14): 4h
        Workout()
          ..startTime = DateTime(2026, 6, 10)
          ..durationSeconds = 14400.0,
          
        // Week before (June 1 - 7): 3h
        Workout()
          ..startTime = DateTime(2026, 6, 3)
          ..durationSeconds = 10800.0,

        // Week before that (May 25 - 31): 2h (GOAL BROKEN)
        Workout()
          ..startTime = DateTime(2026, 5, 27)
          ..durationSeconds = 7200.0,
      ];

      final result = calculateWeeklyGoalProgress(
        workouts: workouts,
        goalHours: 3.0,
        now: now,
      );

      expect(result.streakCount, equals(3));
    });

    test('streak should be maintained from last week even if current week is not yet met', () {
      final workouts = [
        // Current week (June 15 - 21): 1h (Goal 3h not yet met)
        Workout()
          ..startTime = DateTime(2026, 6, 16)
          ..durationSeconds = 3600.0,
        
        // Last week (June 8 - 14): 3h
        Workout()
          ..startTime = DateTime(2026, 6, 10)
          ..durationSeconds = 10800.0,
          
        // Week before (June 1 - 7): 3h
        Workout()
          ..startTime = DateTime(2026, 6, 3)
          ..durationSeconds = 10800.0,
      ];

      final result = calculateWeeklyGoalProgress(
        workouts: workouts,
        goalHours: 3.0,
        now: now,
      );

      // Current week not met (1h), but last week and week before were met.
      // Streak should be 2.
      expect(result.streakCount, equals(2));
    });

    test('streak should be 0 if current week and last week are not met', () {
      final workouts = [
        // Current week: 1h
        Workout()
          ..startTime = DateTime(2026, 6, 16)
          ..durationSeconds = 3600.0,
        
        // Last week: 2h (Goal 3h)
        Workout()
          ..startTime = DateTime(2026, 6, 10)
          ..durationSeconds = 7200.0,
          
        // Week before: 5h (Goal 3h) - Streak is broken by last week
        Workout()
          ..startTime = DateTime(2026, 6, 3)
          ..durationSeconds = 18000.0,
      ];

      final result = calculateWeeklyGoalProgress(
        workouts: workouts,
        goalHours: 3.0,
        now: now,
      );

      expect(result.streakCount, equals(0));
    });
  });
}
