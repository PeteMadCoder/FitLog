import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/diary/views/diary_screen.dart';
import 'package:fitlog_app/features/diary/providers/diary_providers.dart';
import 'package:fitlog_app/features/analytics/views/workout_detail_screen.dart';
import 'package:fitlog_app/features/analytics/providers/analytics_providers.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';

void main() {
  group('DiaryScreen Widget Tests', () {
    testWidgets('shows loading indicator initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutHistoryProvider.overrideWith(
              (ref) => const Stream<List<Workout>>.empty(),
            ),
          ],
          child: const MaterialApp(home: DiaryScreen()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no workouts are present', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutHistoryProvider.overrideWith(
              (ref) => Stream.value(<Workout>[]),
            ),
          ],
          child: const MaterialApp(home: DiaryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Workouts Recorded'), findsOneWidget);
      expect(
        find.text(
          'Track a session in the tracker tab to view your activity history here.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);
    });

    testWidgets('renders workout cards when workouts are present', (
      WidgetTester tester,
    ) async {
      final now = DateTime(2026, 6, 14, 10, 0);
      final workout1 = Workout()
        ..id = 1
        ..sportType = 'running'
        ..startTime = now
        ..durationSeconds = 1200
        ..distanceMeters = 3000
        ..averageSpeed = 2.5
        ..isCompleted = true;

      final workout2 = Workout()
        ..id = 2
        ..sportType = 'cycling'
        ..startTime = now.subtract(const Duration(days: 1))
        ..durationSeconds = 3600
        ..distanceMeters = 20000
        ..averageSpeed = 5.55
        ..isCompleted = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutHistoryProvider.overrideWith(
              (ref) => Stream.value([workout1, workout2]),
            ),
          ],
          child: const MaterialApp(home: DiaryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify list items
      expect(find.text('RUNNING WORKOUT'), findsOneWidget);
      expect(find.text('CYCLING WORKOUT'), findsOneWidget);

      // Verify date formatting
      expect(find.text('Jun 14, 2026 at 10:00'), findsOneWidget);

      // Verify stats
      expect(find.text('3.00 km'), findsOneWidget);
      expect(find.text('20:00'), findsOneWidget); // 1200 seconds
      expect(find.text('6:40/km'), findsOneWidget);

      expect(find.text('20.00 km'), findsOneWidget);
      expect(find.text('1:00:00'), findsOneWidget); // 3600 seconds
      expect(find.text('20.0 km/h'), findsOneWidget); // 5.55 * 3.6 = 20.0 km/h
    });

    testWidgets('navigates to WorkoutDetailScreen when card is tapped', (
      WidgetTester tester,
    ) async {
      final now = DateTime(2026, 6, 14, 10, 0);
      final workout = Workout()
        ..id = 42
        ..sportType = 'running'
        ..startTime = now
        ..durationSeconds = 1200
        ..distanceMeters = 3000
        ..averageSpeed = 2.5
        ..isCompleted = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutHistoryProvider.overrideWith(
              (ref) => Stream.value([workout]),
            ),
            workoutDetailProvider(
              42,
            ).overrideWith((ref) => Stream.value(workout)),
          ],
          child: const MaterialApp(home: DiaryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on the card
      await tester.tap(find.text('RUNNING WORKOUT'));
      await tester.pumpAndSettle();

      // Verify detail screen is displayed
      expect(find.byType(WorkoutDetailScreen), findsOneWidget);
      expect(find.text('Workout Summary'), findsOneWidget);
    });
  });
}
