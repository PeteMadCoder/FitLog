import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/tracking/views/tracker_screen.dart';
import 'package:fitlog_app/features/tracking/views/active_workout_screen.dart';
import 'package:fitlog_app/features/tracking/services/gps_service.dart';
import 'package:fitlog_app/core/permissions/permission_service.dart';
import 'package:fitlog_app/features/tracking/models/gps_point.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';
import 'package:fitlog_app/features/tracking/models/sensor_data.dart';
import 'package:fitlog_app/app/app_providers.dart';
import 'package:fitlog_app/features/tracking/models/sport_type.dart';
import 'package:fitlog_app/features/tracking/providers/recent_sports_provider.dart';
import 'package:isar/isar.dart';

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
  Future<Workout?> getActiveWorkout(Isar isar) async => null;

  @override
  Future<bool> startForegroundService() async => true;

  @override
  Future<bool> stopForegroundService() async => true;

  @override
  Future<bool> get isServiceRunning async => false;
}

class FakeIsar extends Fake implements Isar {
  final collections = <Type, FakeIsarCollection<dynamic>>{};

  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) {
    return callback();
  }

  @override
  IsarCollection<T> collection<T>() {
    return collections.putIfAbsent(T, () => FakeIsarCollection<T>())
        as IsarCollection<T>;
  }
}

class FakeIsarCollection<T> extends Fake implements IsarCollection<T> {
  final List<T> items = [];

  @override
  Future<List<Id>> putAll(List<T> objects) async {
    final List<Id> ids = [];
    for (final obj in objects) {
      ids.add(await put(obj));
    }
    return ids;
  }

  @override
  Future<Id> put(T object) async {
    int? existingId;
    if (object is Workout) {
      if (object.id != Isar.autoIncrement && object.id > 0) {
        existingId = object.id;
      }
    } else if (object is GpsPoint) {
      if (object.id != Isar.autoIncrement && object.id > 0) {
        existingId = object.id;
      }
    } else if (object is SensorData) {
      if (object.id != Isar.autoIncrement && object.id > 0) {
        existingId = object.id;
      }
    }

    if (existingId != null) {
      final idx = items.indexWhere((item) {
        if (item is Workout && item.id == existingId) return true;
        if (item is GpsPoint && item.id == existingId) return true;
        if (item is SensorData && item.id == existingId) return true;
        return false;
      });
      if (idx != -1) {
        items[idx] = object;
        return existingId;
      }
    }

    final int nextId = items.length + 1;
    if (object is Workout) {
      object.id = nextId;
    } else if (object is GpsPoint) {
      object.id = nextId;
    } else if (object is SensorData) {
      object.id = nextId;
    }
    items.add(object);
    return nextId;
  }

  @override
  Future<T?> get(Id id) async {
    for (final item in items) {
      if (item is Workout && item.id == id) {
        return item as T;
      } else if (item is GpsPoint && item.id == id) {
        return item as T;
      } else if (item is SensorData && item.id == id) {
        return item as T;
      }
    }
    return null;
  }

  @override
  Future<bool> delete(Id id) async {
    final initialLength = items.length;
    items.removeWhere((item) {
      if (item is Workout && item.id == id) return true;
      if (item is GpsPoint && item.id == id) return true;
      if (item is SensorData && item.id == id) return true;
      return false;
    });
    return items.length < initialLength;
  }

  @override
  QueryBuilder<T, T, QFilterCondition> filter() {
    return FakeQueryBuilder<T>(this) as QueryBuilder<T, T, QFilterCondition>;
  }
}

class FakeQueryBuilder<T> extends Fake implements QueryBuilder<T, T, QFilterCondition> {
  final FakeIsarCollection<T> collection;
  FakeQueryBuilder(this.collection);

  FakeQueryBuilder<T> isCompletedEqualTo(bool value) {
    return this;
  }

  Future<T?> findFirst() async {
    if (T == Workout) {
      final list = collection.items as List<Workout>;
      final index = list.indexWhere((w) => !w.isCompleted);
      if (index != -1) {
        return list[index] as T?;
      }
      return null;
    }
    return collection.items.isNotEmpty ? collection.items.first : null;
  }
}

void main() {
  group('Tracker Views Widget Tests', () {
    late FakePermissionService fakePermission;
    late FakeGpsService fakeGps;
    late FakeIsar fakeIsar;

    setUp(() {
      fakePermission = FakePermissionService();
      fakeGps = FakeGpsService();
      fakeIsar = FakeIsar();
    });

    Widget createTestWidget({List<SportType> recent = const []}) {
      return ProviderScope(
        overrides: [
          permissionServiceProvider.overrideWithValue(fakePermission),
          gpsServiceProvider.overrideWithValue(fakeGps),
          isarProvider.overrideWith((ref) => fakeIsar),
          recentSportsProvider.overrideWith((ref) => Stream.value(recent)),
        ],
        child: const MaterialApp(home: TrackerScreen()),
      );
    }

    testWidgets('TrackerScreen renders sport selection in idle state and supports searchable picker', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Start Workout'), findsOneWidget);
      expect(find.text('START WORKOUT'), findsOneWidget);
      
      // Default sport is 'Running'
      expect(find.text('Running'), findsOneWidget);
      expect(find.text('Tap to change sport'), findsOneWidget);

      // Open bottom sheet sport picker
      await tester.tap(find.text('Tap to change sport'));
      await tester.pumpAndSettle();

      // Check bottom sheet elements
      expect(find.text('Select Sport'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Search for "cycling"
      await tester.enterText(find.byType(TextField), 'cycling');
      await tester.pumpAndSettle();

      // Tap the Cycling tile in the search results
      await tester.tap(find.text('Cycling').first);
      await tester.pumpAndSettle();

      // Bottom sheet should be dismissed, and selection updated
      expect(find.text('Select Sport'), findsNothing);
      expect(find.text('Cycling'), findsOneWidget);
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

    testWidgets('SportPickerSheet displays recent sports and divider when recent sports exist', (
      WidgetTester tester,
    ) async {
      final recent = [
        SportType.fromId('cycling'),
        SportType.fromId('walking'),
      ];

      await tester.pumpWidget(createTestWidget(recent: recent));
      await tester.pumpAndSettle();

      // Open bottom sheet
      await tester.tap(find.text('Tap to change sport'));
      await tester.pumpAndSettle();

      // Verify that "Recent Activities" header is displayed
      expect(find.text('RECENT ACTIVITIES'), findsOneWidget);

      // Verify that "All Activities" header is displayed
      expect(find.text('ALL ACTIVITIES'), findsOneWidget);

      // Verify that recent sports are shown
      expect(find.text('Cycling'), findsAtLeastNWidgets(1));
      expect(find.text('Walking'), findsAtLeastNWidgets(1));

      // Tap on Cycling
      await tester.tap(find.text('Cycling').first);
      await tester.pumpAndSettle();

      // Verify selection update
      expect(find.text('Select Sport'), findsNothing);
      expect(find.text('Cycling'), findsOneWidget);
    });
  });
}
