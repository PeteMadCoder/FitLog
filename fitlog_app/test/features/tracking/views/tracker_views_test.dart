import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/tracking/views/tracker_screen.dart';
import 'package:fitlog_app/features/tracking/views/active_workout_screen.dart';
import 'package:fitlog_app/features/tracking/services/gps_service.dart';
import 'package:fitlog_app/core/permissions/permission_service.dart';
import 'package:fitlog_app/features/tracking/models/gps_point.dart';

// Mock implementations for testing views
class FakePermissionService implements PermissionService {
  @override
  Future<bool> hasLocationPermission() async => true;
  @override
  Future<bool> requestLocationPermission() async => true;
  @override
  Future<bool> hasBackgroundLocationPermission() async => true;
  @override
  Future<bool> requestBackgroundLocationPermission() async => true;
  @override
  Future<bool> hasBluetoothPermission() async => true;
  @override
  Future<bool> requestBluetoothPermission() async => true;
  @override
  Future<bool> openSettings() async => true;
}

class FakeGpsService implements GpsService {
  @override
  Future<void> configureGpsSettings() async {}
  @override
  Future<bool> enableBackgroundMode() async => true;
  @override
  Future<bool> disableBackgroundMode() async => true;
  @override
  Stream<GpsPoint> getGpsPointStream() => const Stream<GpsPoint>.empty();
}

void main() {
  group('Tracker Views Widget Tests', () {
    late FakePermissionService fakePermission;
    late FakeGpsService fakeGps;

    setUp(() {
      fakePermission = FakePermissionService();
      fakeGps = FakeGpsService();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          permissionServiceProvider.overrideWithValue(fakePermission),
          gpsServiceProvider.overrideWithValue(fakeGps),
        ],
        child: const MaterialApp(home: TrackerScreen()),
      );
    }

    testWidgets('TrackerScreen renders sport selection in idle state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Start Workout'), findsOneWidget);
      expect(find.text('START WORKOUT'), findsOneWidget);
      expect(find.text('Run'), findsOneWidget);
      expect(find.text('Ride'), findsOneWidget);
    });

    testWidgets(
      'Tapping start transitions TrackerScreen to ActiveWorkoutScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Tap START WORKOUT to start recording
        await tester.tap(find.text('START WORKOUT'));
        await tester.pumpAndSettle();

        // Verify that it transitions to ActiveWorkoutScreen
        expect(find.byType(ActiveWorkoutScreen), findsOneWidget);
        expect(find.text('TIME'), findsOneWidget);
        expect(find.text('DISTANCE'), findsOneWidget);
        expect(find.text('SPEED'), findsOneWidget);

        // Verify that the Pause button is present (since we are recording)
        expect(find.byIcon(Icons.pause), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping pause in ActiveWorkoutScreen changes controls to Stop and Play',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Start workout
        await tester.tap(find.text('START WORKOUT'));
        await tester.pumpAndSettle();

        // Tap Pause button
        await tester.tap(find.byIcon(Icons.pause));
        await tester.pumpAndSettle();

        // Verify state changes to Paused and shows Play (resume) and Stop buttons
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
        expect(find.byIcon(Icons.stop), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping stop in ActiveWorkoutScreen shows End Workout dialog with name field',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Start workout
        await tester.tap(find.text('START WORKOUT'));
        await tester.pumpAndSettle();

        // Pause workout
        await tester.tap(find.byIcon(Icons.pause));
        await tester.pumpAndSettle();

        // Tap Stop button
        await tester.tap(find.byIcon(Icons.stop));
        await tester.pumpAndSettle();

        // Verify End Workout dialog is shown
        expect(find.text('End Workout'), findsOneWidget);
        expect(find.text('Workout Name (Optional)'), findsOneWidget);

        // Enter a name
        await tester.enterText(find.byType(TextField), 'My Custom Workout');
        expect(find.text('My Custom Workout'), findsOneWidget);

        expect(find.text('Save Workout'), findsOneWidget);
        expect(find.text('Discard'), findsOneWidget);
      },
    );
  });
}
