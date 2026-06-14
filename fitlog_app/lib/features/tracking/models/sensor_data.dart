import 'package:isar/isar.dart';

part 'sensor_data.g.dart';

/// Represents external BLE sensor data (e.g., heart rate, cadence)
/// recorded concurrently with the GPS path.
@collection
class SensorData {
  Id id = Isar.autoIncrement;

  late DateTime timestamp;
  late String sensorType; // e.g., 'heart_rate', 'cadence'
  late double value;
}
