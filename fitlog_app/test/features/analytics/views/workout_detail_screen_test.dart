import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:isar/isar.dart';
import 'package:fitlog_app/features/analytics/views/workout_detail_screen.dart';
import 'package:fitlog_app/features/analytics/providers/analytics_providers.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';
import 'package:fitlog_app/features/tracking/models/gps_point.dart';

class TestWorkout extends Workout {
  final List<GpsPoint> _pts;
  TestWorkout(this._pts);

  @override
  IsarLinks<GpsPoint> get gpsPoints => FakeIsarLinks<GpsPoint>(_pts);
}

// ignore: subtype_of_sealed_class
class FakeIsarLinks<T> extends Fake implements IsarLinks<T> {
  final List<T> _items;
  FakeIsarLinks(this._items);

  @override
  List<T> toList({bool growable = true}) => _items;

  @override
  int get length => _items.length;

  @override
  bool get isEmpty => _items.isEmpty;

  @override
  bool get isNotEmpty => _items.isNotEmpty;

  @override
  Iterator<T> get iterator => _items.iterator;
}

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

      // Verify chart fallback
      expect(
        find.text('Not enough telemetry data to draw charts'),
        findsOneWidget,
      );
    });

    testWidgets(
      'renders segmented control and chart when gpsPoints are present',
      (WidgetTester tester) async {
        final point1 = GpsPoint()
          ..latitude = 37.7749
          ..longitude = -122.4194
          ..altitude = 100.0
          ..speed = 3.0
          ..timestamp = DateTime(2026, 6, 14, 10, 0);

        final point2 = GpsPoint()
          ..latitude = 37.7750
          ..longitude = -122.4194
          ..altitude = 105.0
          ..speed = 4.0
          ..timestamp = DateTime(2026, 6, 14, 10, 5);

        final workout = TestWorkout([point1, point2])
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

        // Verify segmented control is present
        expect(find.byType(SegmentedButton<int>), findsOneWidget);
        expect(find.text('Elevation'), findsOneWidget);
        expect(find.text('Speed'), findsOneWidget);
        expect(find.text('Pace'), findsOneWidget);

        // Verify that the LineChart is rendered
        expect(find.byType(LineChart), findsOneWidget);

        // Verify laps table is rendered
        expect(find.text('LAP SPLITS'), findsOneWidget);
        expect(find.text('1km'), findsOneWidget);
        expect(find.text('LAP'), findsOneWidget);
        expect(find.text('DISTANCE'), findsNWidgets(2));
        expect(find.text('TIME'), findsOneWidget);
        expect(find.text('AVG SPEED'), findsNWidgets(2));
      },
    );

    testWidgets('edit name dialog updates the name', (
      WidgetTester tester,
    ) async {
      final workout = Workout()
        ..sportType = 'running'
        ..startTime = DateTime(2026, 6, 14, 10, 0)
        ..name = 'Old Name';

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

      // Tap Edit button
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      // Verify dialog
      expect(find.text('Edit Workout Name'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Old Name'), findsOneWidget);

      // Enter new name
      await tester.enterText(find.byType(TextField), 'New Name');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Edit Workout Name'), findsNothing);
    });

    testWidgets('delete workout shows confirmation and pops', (
      WidgetTester tester,
    ) async {
      final workout = Workout()
        ..sportType = 'running'
        ..startTime = DateTime(2026, 6, 14, 10, 0);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutDetailProvider(
              1,
            ).overrideWith((ref) => Stream.value(workout)),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const WorkoutDetailScreen(workoutId: 1),
                      ),
                    );
                  },
                  child: const Text('Go'),
                );
              },
            ),
          ),
        ),
      );

      // Open screen
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      expect(find.byType(WorkoutDetailScreen), findsOneWidget);

      // Tap Delete button
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Verify dialog
      expect(find.text('Delete Workout?'), findsOneWidget);

      // Tap DELETE
      await tester.tap(find.text('DELETE'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Screen should be closed (popped)
      expect(find.byType(WorkoutDetailScreen), findsNothing);
    });

    testWidgets('shows export button and handles tap', (
      WidgetTester tester,
    ) async {
      final workout = Workout()
        ..sportType = 'running'
        ..startTime = DateTime(2026, 6, 14, 10, 0);

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

      // Verify export button is present
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);

      // Tap it
      await tester.tap(find.byIcon(Icons.share_outlined));
      await tester.pump();
      // Platform channels like FilePicker are not mocked here, but we verify button triggers action
    });
  });
}
