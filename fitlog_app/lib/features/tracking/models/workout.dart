import 'package:isar/isar.dart';
import 'gps_point.dart';
import 'sensor_data.dart';

part 'workout.g.dart';

/// Represents a workout session (e.g., Run, Ride, Hike) and its summary statistics.
@collection
class Workout {
  Id id = Isar.autoIncrement;

  String? name;
  late String sportType; // e.g., 'running', 'cycling', 'walking', 'hiking'
  late DateTime startTime;
  DateTime? endTime;

  double durationSeconds = 0.0;
  double distanceMeters = 0.0;

  double? averageSpeed;
  double? maxSpeed;
  double? elevationGain;
  double? elevationLoss;
  double? averageHeartRate;
  double? maxHeartRate;
  double? calories;

  bool isCompleted = false;
  bool isPaused = false;

  /// Breadcrumb path for the workout.
  final gpsPoints = IsarLinks<GpsPoint>();

  /// BLE sensor data recorded during this workout.
  final sensorData = IsarLinks<SensorData>();
}
