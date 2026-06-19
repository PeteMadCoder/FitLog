import 'package:isar/isar.dart';
import 'package:location/location.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fitlog_app/features/tracking/models/gps_point.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';

part 'gps_service.g.dart';

/// Service responsible for configuring GPS tracking parameters,
/// requesting background tracking notifications, and streaming location updates.
class GpsService {
  final Location _location;

  GpsService({Location? location}) : _location = location ?? Location();

  /// Retrieves any active, uncompleted workout from the Isar database.
  Future<Workout?> getActiveWorkout(Isar isar) async {
    return await isar.workouts.filter().isCompletedEqualTo(false).findFirst();
  }

  /// Configures the GPS tracking settings to request high-accuracy data
  /// and stream updates every 1 second or every 5 meters.
  Future<void> configureGpsSettings() async {
    await _location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000, // Update every 1000ms (1 second)
      distanceFilter: 0.0, // Set to 0 to capture updates by time and speed
    );
  }

  /// Enables background location recording and registers a foreground
  /// notification for Android to keep the system process alive.
  Future<bool> enableBackgroundMode() async {
    try {
      // Set up native Android background notification parameters
      await _location.changeNotificationOptions(
        title: 'FitLog Active Activity',
        subtitle: 'FitLog is tracking your workout in the background.',
        iconName: 'mipmap/ic_launcher',
        onTapBringToFront: true,
      );

      return await _location.enableBackgroundMode(enable: true);
    } catch (e) {
      // Return false if platform-specific errors prevent enabling background mode
      return false;
    }
  }

  /// Disables background location mode.
  Future<bool> disableBackgroundMode() async {
    try {
      return await _location.enableBackgroundMode(enable: false);
    } catch (e) {
      return false;
    }
  }

  /// Exposes a mapped stream of [GpsPoint] objects derived from raw [LocationData].
  Stream<GpsPoint> getGpsPointStream() {
    return _location.onLocationChanged.map((locationData) {
      final timestamp = locationData.time != null
          ? DateTime.fromMillisecondsSinceEpoch(locationData.time!.toInt())
          : DateTime.now();

      return GpsPoint()
        ..timestamp = timestamp
        ..latitude = locationData.latitude ?? 0.0
        ..longitude = locationData.longitude ?? 0.0
        ..altitude = locationData.altitude
        ..accuracy = locationData.accuracy
        ..speed = locationData.speed;
    });
  }
}

/// Provider exposing the GpsService instance.
@riverpod
GpsService gpsService(GpsServiceRef ref) {
  return GpsService();
}
