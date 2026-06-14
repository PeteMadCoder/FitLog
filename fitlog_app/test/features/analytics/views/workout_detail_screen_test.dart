import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/analytics/views/workout_detail_screen.dart';
import 'package:fitlog_app/features/analytics/providers/analytics_providers.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';

void main() {
  group('WorkoutDetailScreen Widget Tests', () {
    testWidgets('shows loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutDetailProvider(
              1,
            ).overrideWith((ref) => const Stream<Workout?>.empty()),
          ],
          child: const MaterialApp(home: WorkoutDetailScreen(workoutId: 1)),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows workout not found if stream yields null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutDetailProvider(1).overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(home: WorkoutDetailScreen(workoutId: 1)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Workout not found'), findsOneWidget);
    });

    testWidgets('renders workout details and metrics grid', (
      WidgetTester tester,
    ) async {
      final workout = Workout()
        ..sportType = 'running'
        ..startTime = DateTime(2026, 6, 14, 10, 0)
        ..durationSeconds = 1200
        ..distanceMeters = 3000
        ..averageSpeed = 2.5
        ..maxSpeed = 4.0
        ..elevationGain = 50.0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutDetailProvider(
              1,
            ).overrideWith((ref) => Stream.value(workout)),
          ],
          child: const MaterialApp(home: WorkoutDetailScreen(workoutId: 1)),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header
      expect(find.text('RUNNING WORKOUT'), findsOneWidget);
      expect(find.text('Jun 14, 2026 at 10:00'), findsOneWidget);

      // Verify metrics
      expect(find.text('3.00'), findsOneWidget); // Distance 3.00 km
      expect(
        find.text('20:00'),
        findsOneWidget,
      ); // Duration 20:00 (1200 seconds)
      expect(
        find.text('9.0'),
        findsOneWidget,
      ); // Average speed 9.0 km/h (2.5 * 3.6)
      expect(
        find.text('6:40'),
        findsOneWidget,
      ); // Average pace 6:40 /km (20 mins / 3 km)
      expect(
        find.text('14.4'),
        findsOneWidget,
      ); // Max speed 14.4 km/h (4.0 * 3.6)
      expect(find.text('50'), findsOneWidget); // Elevation gain 50 m

      // Verify map fallback (since gpsPoints is empty)
      expect(find.text('No GPS route recorded'), findsOneWidget);
    });
  });
}
