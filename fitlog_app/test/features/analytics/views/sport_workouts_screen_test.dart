import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/analytics/views/sport_workouts_screen.dart';
import 'package:fitlog_app/features/analytics/views/stats_screen.dart';
import 'package:fitlog_app/features/analytics/providers/analytics_providers.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';
import 'package:fitlog_app/features/analytics/views/workout_detail_screen.dart';

void main() {
  testWidgets('SportWorkoutsScreen displays workouts of the correct sport type', (tester) async {
    final mockWorkout1 = Workout()
      ..id = 1
      ..sportType = 'running'
      ..startTime = DateTime(2026, 6, 28, 10, 0)
      ..durationSeconds = 1800
      ..distanceMeters = 5000
      ..name = 'Morning Run';

    final mockWorkout2 = Workout()
      ..id = 2
      ..sportType = 'running'
      ..startTime = DateTime(2026, 6, 29, 8, 0)
      ..durationSeconds = 2400
      ..distanceMeters = 6000
      ..name = 'Tempo Run';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statsWorkoutsProvider.overrideWith((ref) => Stream.value([mockWorkout1, mockWorkout2])),
        ],
        child: const MaterialApp(
          home: SportWorkoutsScreen(sportId: 'running'),
        ),
      ),
    );

    await tester.pump(); // Start stream
    await tester.pump(); // Render data

    // Verify Title
    expect(find.text('Running Workouts'), findsOneWidget);

    // Verify list items
    expect(find.text('Morning Run'), findsOneWidget);
    expect(find.text('Tempo Run'), findsOneWidget);
    expect(find.text('5.00 km'), findsOneWidget);
    expect(find.text('6.00 km'), findsOneWidget);
  });

  testWidgets('SportWorkoutsScreen displays empty state when no workouts match', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statsWorkoutsProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const MaterialApp(
          home: SportWorkoutsScreen(sportId: 'cycling'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    // Verify empty state is displayed
    expect(find.text('No Cycling Workouts'), findsOneWidget);
    expect(find.text('There are no workouts of this type recorded in the selected timeframe.'), findsOneWidget);
  });

  testWidgets('Tapping a workout card in SportWorkoutsScreen navigates to WorkoutDetailScreen', (tester) async {
    final mockWorkout = Workout()
      ..id = 100
      ..sportType = 'running'
      ..startTime = DateTime(2026, 6, 28, 10, 0)
      ..durationSeconds = 1800
      ..distanceMeters = 5000
      ..name = 'My Run';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statsWorkoutsProvider.overrideWith((ref) => Stream.value([mockWorkout])),
          workoutDetailProvider(100).overrideWith((ref) => Stream.value(mockWorkout)),
        ],
        child: const MaterialApp(
          home: SportWorkoutsScreen(sportId: 'running'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    // Tap on the workout card
    await tester.tap(find.text('My Run'));
    await tester.pumpAndSettle();

    // Verify WorkoutDetailScreen was pushed
    expect(find.byType(WorkoutDetailScreen), findsOneWidget);
  });

  testWidgets('StatsScreen navigates to SportWorkoutsScreen when sport breakdown card is tapped', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    await binding.setSurfaceSize(const Size(800, 1200));

    final sportStats = AggregatedStats(
      totalDistanceMeters: 5000,
      totalDuration: const Duration(minutes: 30),
      totalCalories: 350,
      workoutCount: 2,
      statsBySport: const {},
    );
    final stats = AggregatedStats(
      totalDistanceMeters: 5000,
      totalDuration: const Duration(minutes: 30),
      totalCalories: 350,
      workoutCount: 2,
      statsBySport: {
        'running': sportStats,
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardStatsProvider.overrideWith((ref) => Stream.value(stats)),
          statsWorkoutsProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const MaterialApp(home: StatsScreen()),
      ),
    );

    await tester.pump();
    await tester.pump();

    // Verify breakdown section exists
    expect(find.text('Breakdown by Sport'), findsOneWidget);
    expect(find.text('RUNNING'), findsOneWidget);

    // Tap the RUNNING card to trigger navigation
    await tester.tap(find.text('RUNNING'));
    await tester.pumpAndSettle();

    // Verify SportWorkoutsScreen is displayed
    expect(find.byType(SportWorkoutsScreen), findsOneWidget);
    expect(find.text('Running Workouts'), findsOneWidget);

    await binding.setSurfaceSize(null);
  });
}
