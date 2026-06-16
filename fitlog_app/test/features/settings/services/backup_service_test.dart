import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';
import 'package:fitlog_app/features/tracking/models/gps_point.dart';
import 'package:fitlog_app/features/tracking/models/sensor_data.dart';
import 'package:fitlog_app/features/settings/models/user_settings.dart';
import 'package:fitlog_app/features/settings/providers/settings_provider.dart';
import 'package:fitlog_app/features/settings/services/backup_service.dart';

// Test Backup Service subclass that overrides the isolated database methods.
// This completely avoids calling Isar extension methods (which rely on internal query pointers).
class TestBackupService extends BackupService {
  final List<Workout> fakeWorkouts;
  final Map<int, List<GpsPoint>> fakeGpsPoints = {};
  final Map<int, List<SensorData>> fakeSensorData = {};

  TestBackupService(super.ref, this.fakeWorkouts);

  @override
  Future<Uint8List> getDatabaseBytes() async {
    return Uint8List(0);
  }

  @override
  Future<void> importDatabase(String sourcePath) async {
    // Fake database import in unit test
  }

  @override
  Future<List<Workout>> fetchAllWorkouts() async {
    return fakeWorkouts;
  }

  @override
  Future<List<GpsPoint>> getGpsPointsForWorkout(Workout workout) async {
    return fakeGpsPoints[workout.id] ?? [];
  }

  @override
  Future<List<SensorData>> getSensorDataForWorkout(Workout workout) async {
    return fakeSensorData[workout.id] ?? [];
  }

  @override
  Future<bool> workoutExistsAt(DateTime startTime) async {
    return fakeWorkouts.any((w) => w.startTime == startTime);
  }

  @override
  Future<void> saveImportedWorkouts(
    List<Workout> workouts,
    List<List<GpsPoint>> gpsPoints,
    List<List<SensorData>> sensorData,
  ) async {
    for (int i = 0; i < workouts.length; i++) {
      final w = workouts[i];
      // Assign fake ID
      w.id = fakeWorkouts.length + 1;
      fakeWorkouts.add(w);
      fakeGpsPoints[w.id] = gpsPoints[i];
    }
  }
}

class FakeSettingsState extends SettingsState {
  UserSettings _value;

  FakeSettingsState(this._value);

  @override
  Future<UserSettings> build() async {
    return _value;
  }

  @override
  Future<void> updateSettings({
    String? gender,
    double? height,
    double? weight,
  }) async {
    _value = _value.copyWith(
      gender: gender,
      height: height,
      weight: weight,
    );
    state = AsyncValue.data(_value);
  }

  @override
  Future<void> importSettings(UserSettings settings) async {
    _value = settings;
    state = AsyncValue.data(_value);
  }
}

void main() {
  group('BackupService Tests', () {
    late List<Workout> fakeWorkouts;
    late TestBackupService testBackupService;
    late FakeSettingsState fakeSettingsState;
    late ProviderContainer container;

    setUp(() {
      fakeWorkouts = [];
      fakeSettingsState = FakeSettingsState(UserSettings());
      container = ProviderContainer(
        overrides: [
          backupServiceProvider.overrideWith((ref) {
            testBackupService = TestBackupService(ref, fakeWorkouts);
            return testBackupService;
          }),
          settingsStateProvider.overrideWith(() => fakeSettingsState),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('GPX Parsing parses correct fields, speed, and distance', () {
      const gpxContent = '''<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="FitLog Test" xmlns="http://www.topografix.com/GPX/1/1">
  <metadata>
    <name>Test Run Activity</name>
  </metadata>
  <trk>
    <name>Morning Run</name>
    <type>running</type>
    <trkseg>
      <trkpt lat="41.1496" lon="-8.6110">
        <ele>100.0</ele>
        <time>2026-06-16T10:00:00Z</time>
      </trkpt>
      <trkpt lat="41.1500" lon="-8.6120">
        <ele>110.0</ele>
        <time>2026-06-16T10:01:40Z</time>
      </trkpt>
    </trkseg>
  </trk>
</gpx>''';

      // Parse the gpxContent
      final service = container.read(backupServiceProvider);
      final parsed = service.parseGpx(gpxContent);
      final workout = parsed.workout;

      expect(workout.name, equals('Morning Run'));
      expect(workout.sportType, equals('running'));
      expect(workout.startTime, equals(DateTime.parse('2026-06-16T10:00:00Z')));
      expect(workout.endTime, equals(DateTime.parse('2026-06-16T10:01:40Z')));
      expect(workout.durationSeconds, equals(100.0));
      expect(workout.distanceMeters, greaterThan(80.0)); // Portugal Porto coordinates distance ~95m
      expect(parsed.gpsPoints.length, equals(2));
    });

    test('TCX Parsing parses points and heart rate data', () {
      const tcxContent = '''<?xml version="1.0" encoding="UTF-8"?>
<TrainingCenterDatabase xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2">
  <Activities>
    <Activity Sport="Biking">
      <Id>2026-06-16T10:00:00Z</Id>
      <Lap StartTime="2026-06-16T10:00:00Z">
        <Track>
          <Trackpoint>
            <Time>2026-06-16T10:00:00Z</Time>
            <Position>
              <LatitudeDegrees>41.1496</LatitudeDegrees>
              <LongitudeDegrees>-8.6110</LongitudeDegrees>
            </Position>
            <AltitudeMeters>100.0</AltitudeMeters>
            <HeartRateBpm>
              <Value>130</Value>
            </HeartRateBpm>
          </Trackpoint>
          <Trackpoint>
            <Time>2026-06-16T10:00:10Z</Time>
            <Position>
              <LatitudeDegrees>41.1500</LatitudeDegrees>
              <LongitudeDegrees>-8.6120</LongitudeDegrees>
            </Position>
            <AltitudeMeters>95.0</AltitudeMeters>
            <HeartRateBpm>
              <Value>140</Value>
            </HeartRateBpm>
          </Trackpoint>
        </Track>
      </Lap>
    </Activity>
  </Activities>
</TrainingCenterDatabase>''';

      final service = container.read(backupServiceProvider);
      final parsed = service.parseTcx(tcxContent);
      final workout = parsed.workout;

      expect(workout.sportType, equals('cycling'));
      expect(workout.startTime, equals(DateTime.parse('2026-06-16T10:00:00Z')));
      expect(workout.durationSeconds, equals(10.0));
      expect(parsed.gpsPoints.length, equals(2));
      expect(parsed.sensorData.length, equals(2));
    });

    test('JSON Export and Import works perfectly', () async {
      final gpsPt = GpsPoint()
        ..latitude = 40.0
        ..longitude = -8.0
        ..timestamp = DateTime.parse('2026-06-16T12:00:00Z');

      final sensor = SensorData()
        ..sensorType = 'heart_rate'
        ..value = 150
        ..timestamp = DateTime.parse('2026-06-16T12:00:00Z');

      final workout = Workout()
        ..id = 1
        ..name = 'Afternoon Hike'
        ..sportType = 'hiking'
        ..startTime = DateTime.parse('2026-06-16T12:00:00Z')
        ..endTime = DateTime.parse('2026-06-16T13:00:00Z')
        ..distanceMeters = 4000.0
        ..durationSeconds = 3600.0
        ..isCompleted = true;

      final service = container.read(backupServiceProvider) as TestBackupService;

      // Populate fake database in the service
      fakeWorkouts.add(workout);
      service.fakeGpsPoints[1] = [gpsPt];
      service.fakeSensorData[1] = [sensor];

      // Wait for settings state provider to initialize
      await container.read(settingsStateProvider.future);

      // Save some profile settings
      await container.read(settingsStateProvider.notifier).updateSettings(
        gender: 'Male',
        height: 180.0,
        weight: 78.0,
      );

      // Export to JSON
      final jsonString = await service.exportToJson();
      final decoded = jsonDecode(jsonString);

      expect(decoded['version'], equals(1));
      expect(decoded['settings']['gender'], equals('Male'));
      expect(decoded['settings']['height'], equals(180.0));
      expect(decoded['settings']['weight'], equals(78.0));
      expect(decoded['workouts'].length, equals(1));
      expect(decoded['workouts'][0]['name'], equals('Afternoon Hike'));
      expect(decoded['workouts'][0]['sportType'], equals('hiking'));
      expect(decoded['workouts'][0]['gpsPoints'].length, equals(1));
      expect(decoded['workouts'][0]['sensorData'].length, equals(1));

      // Import into a new container/clean test backup service
      final newFakeWorkouts = <Workout>[];
      final newSettingsState = FakeSettingsState(UserSettings());
      final newContainer = ProviderContainer(
        overrides: [
          backupServiceProvider.overrideWith((ref) => TestBackupService(ref, newFakeWorkouts)),
          settingsStateProvider.overrideWith(() => newSettingsState),
        ],
      );

      final newService = newContainer.read(backupServiceProvider);
      // Wait for settings state provider to initialize
      await newContainer.read(settingsStateProvider.future);
      await newService.importFromJson(jsonString);

      // Verify settings imported
      final newSettings = await newContainer.read(settingsStateProvider.future);
      expect(newSettings.gender, equals('Male'));
      expect(newSettings.height, equals(180.0));
      expect(newSettings.weight, equals(78.0));

      // Verify workouts imported
      expect(newFakeWorkouts.length, equals(1));
      expect(newFakeWorkouts[0].name, equals('Afternoon Hike'));
      expect(newFakeWorkouts[0].sportType, equals('hiking'));
      expect(newFakeWorkouts[0].startTime, equals(DateTime.parse('2026-06-16T12:00:00Z')));

      newContainer.dispose();
    });
  });
}
