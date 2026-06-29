import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/home/views/home_screen.dart';
import 'package:fitlog_app/features/analytics/providers/analytics_providers.dart';
import 'package:fitlog_app/features/analytics/views/sport_workouts_screen.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';

void main() {
  testWidgets('HomeScreen displays weekly summary and tapping a sport card navigates to SportWorkoutsScreen', (tester) async {
    // Setup mock data for providers
    final mockLastWorkout = Workout()
      ..id = 1
      ..sportType = 'running'
      ..startTime = DateTime.now().subtract(const Duration(hours: 2))
      ..durationSeconds = 1800
      ..distanceMeters = 5000
      ..name = 'Afternoon Run';

    final mockWeeklyStats = AggregatedStats(
      totalDistanceMeters: 10000,
      totalDuration: const Duration(hours: 1),
      totalCalories: 700,
      workoutCount: 2,
      statsBySport: const {},
    );

    final mockWeeklySummary = WeeklyActivitySummary(
      statsBySport: {
        'running': mockWeeklyStats,
      },
    );

    final mockGoalProgress = WeeklyGoalProgress(
      goalHours: 5.0,
      currentWeekHours: 1.0,
      streakCount: 2,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          latestWorkoutProvider.overrideWith((ref) => Stream.value(mockLastWorkout)),
          weeklyActivitySummaryProvider.overrideWith((ref) => Stream.value(mockWeeklySummary)),
          weeklyGoalProgressProvider.overrideWith((ref) => Stream.value(mockGoalProgress)),
          statsWorkoutsProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    // Verify HomeScreen elements exist
    expect(find.text('Weekly Summary'), findsOneWidget);
    expect(find.text('RUNNING'), findsNWidgets(2));
    expect(find.text('2 activities this week'), findsOneWidget);

    // Tap on the weekly sport card
    await tester.tap(find.text('2 activities this week'));
    await tester.pumpAndSettle();

    // Verify SportWorkoutsScreen is displayed
    expect(find.byType(SportWorkoutsScreen), findsOneWidget);
    expect(find.text('Running Workouts'), findsOneWidget);
  });
}
