import 'dart:async';
import 'dart:convert';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:isar/isar.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fitlog_app/features/tracking/models/gps_point.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';
import 'package:fitlog_app/features/tracking/models/sensor_data.dart';

/// Entry point for the background foreground service isolate.
@pragma('vm:entry-point')
void startTrackingService() {
  FlutterForegroundTask.setTaskHandler(TrackingTaskHandler());
}

/// Handles GPS collection and duration tracking in the background isolate.
/// Persists GPS points and elapsed time directly to Isar so the data survives
/// app closure. Sends GPS point JSON to the main isolate for live UI updates.
class TrackingTaskHandler extends TaskHandler {
  StreamSubscription<LocationData>? _locationSub;
  final Location _location = Location();
  Isar? _isar;

  Future<Isar> _openIsar() async {
    if (_isar != null && _isar!.isOpen) return _isar!;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [WorkoutSchema, GpsPointSchema, SensorDataSchema],
      directory: dir.path,
    );
    return _isar!;
  }

  Future<Workout?> _activeWorkout(Isar isar) =>
      isar.workouts.filter().isCompletedEqualTo(false).findFirst();

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Ensure location service is enabled before subscribing.
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    await _location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000,
      distanceFilter: 0.0,
    );

    _locationSub = _location.onLocationChanged.listen((data) async {
      final ts = data.time != null
          ? DateTime.fromMillisecondsSinceEpoch(data.time!.toInt())
          : DateTime.now();

      // Send to main isolate for live UI updates.
      FlutterForegroundTask.sendDataToMain(jsonEncode({
        'timestamp': ts.toIso8601String(),
        'latitude': data.latitude ?? 0.0,
        'longitude': data.longitude ?? 0.0,
        'altitude': data.altitude,
        'accuracy': data.accuracy,
        'speed': data.speed,
      }));

      // Persist GPS point directly to Isar from the background isolate.
      try {
        final isar = await _openIsar();
        final workout = await _activeWorkout(isar);
        if (workout == null) return;

        final point = GpsPoint()
          ..timestamp = ts
          ..latitude = data.latitude ?? 0.0
          ..longitude = data.longitude ?? 0.0
          ..altitude = data.altitude
          ..accuracy = data.accuracy
          ..speed = data.speed;

        await isar.writeTxn(() async {
          await isar.gpsPoints.put(point);
          await workout.gpsPoints.load();
          workout.gpsPoints.add(point);
          await isar.workouts.put(workout);
          await workout.gpsPoints.save();
        });
      } catch (_) {}
    });
  }

  /// Called every second by the foreground service.
  /// Increments durationSeconds in the database so elapsed time survives app closure.
  @override
  void onRepeatEvent(DateTime timestamp) async {
    try {
      final isar = await _openIsar();
      final workout = await _activeWorkout(isar);
      if (workout == null || workout.isPaused) return;

      await isar.writeTxn(() async {
        workout.durationSeconds += 1.0;
        await isar.workouts.put(workout);
      });

      // Keep notification text up to date with elapsed time.
      final secs = workout.durationSeconds.toInt();
      final h = secs ~/ 3600;
      final m = (secs % 3600) ~/ 60;
      final s = secs % 60;
      final timeStr = h > 0
          ? '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
          : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
      FlutterForegroundTask.updateService(
        notificationText: 'Elapsed: $timeStr',
      );
    } catch (_) {}
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _locationSub?.cancel();
    _locationSub = null;
    await _isar?.close();
    _isar = null;
  }
}
