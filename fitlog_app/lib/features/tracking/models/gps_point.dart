import 'package:isar/isar.dart';

part 'gps_point.g.dart';

/// Represents a single GPS coordinate captured during a workout session.
@collection
class GpsPoint {
  Id id = Isar.autoIncrement;

  late DateTime timestamp;
  late double latitude;
  late double longitude;
  double? altitude;
  double? accuracy;
  double? speed;
}
