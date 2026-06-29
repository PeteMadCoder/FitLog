import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:isar/isar.dart';
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
/// Uses a native EventChannel (LocationPlugin) to receive location updates,
/// bypassing the MethodChannel plugin registration issue with Flutter packages.
class TrackingTaskHandler extends TaskHandler {
  static const _locationChannel =
      EventChannel('com.example.fitlog_app/location');

  StreamSubscription? _locationSub;
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
    _locationSub =
        _locationChannel.receiveBroadcastStream().listen((dynamic data) async {
      if (data is! Map) return;

      final accuracy = data['accuracy'] is num ? (data['accuracy'] as num).toDouble() : null;
      if (accuracy == null || accuracy > 35.0) return;

      final ts = data['timestamp'] is int
          ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int)
          : DateTime.now();

      // Send to main isolate for live UI updates.
      FlutterForegroundTask.sendDataToMain(jsonEncode({
        'timestamp': ts.toIso8601String(),
        'latitude': data['latitude'],
        'longitude': data['longitude'],
        'altitude': data['altitude'],
        'accuracy': data['accuracy'],
        'speed': data['speed'],
      }));

      // Persist GPS point directly to Isar.
      try {
        final isar = await _openIsar();
        final workout = await _activeWorkout(isar);
        if (workout == null) return;

        final point = GpsPoint()
          ..timestamp = ts
          ..latitude = (data['latitude'] as num).toDouble()
          ..longitude = (data['longitude'] as num).toDouble()
          ..altitude = (data['altitude'] as num?)?.toDouble()
          ..accuracy = (data['accuracy'] as num?)?.toDouble()
          ..speed = (data['speed'] as num?)?.toDouble();

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

  /// Fires every second. Increments durationSeconds in the DB and updates
  /// the notification text so elapsed time is visible even when app is closed.
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

      final secs = workout.durationSeconds.toInt();
      final h = secs ~/ 3600;
      final m = (secs % 3600) ~/ 60;
      final s = secs % 60;
      final timeStr = h > 0
          ? '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
          : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
      FlutterForegroundTask.updateService(
          notificationText: 'Elapsed: $timeStr');
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
