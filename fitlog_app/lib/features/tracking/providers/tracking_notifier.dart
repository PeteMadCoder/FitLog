import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fitlog_app/core/errors/result.dart';
import 'package:fitlog_app/core/errors/exceptions.dart';
import 'package:fitlog_app/core/permissions/permission_service.dart';
import 'package:fitlog_app/features/tracking/services/gps_service.dart';
import 'package:fitlog_app/features/tracking/models/gps_point.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';
import 'package:fitlog_app/features/tracking/models/sensor_data.dart';
import 'package:fitlog_app/app/app_providers.dart';
import 'tracking_state.dart';

part 'tracking_notifier.g.dart';

/// Notifier responsible for managing the active tracking session state
/// and processing real-time telemetry coordinates.
@Riverpod(keepAlive: true)
class TrackingNotifier extends _$TrackingNotifier {
  Timer? _timer;

  @override
  TrackingState build() {
    FlutterForegroundTask.addTaskDataCallback(_onTaskData);

    ref.onDispose(() {
      FlutterForegroundTask.removeTaskDataCallback(_onTaskData);
      _timer?.cancel();
    });

    Future.microtask(() => restoreActiveWorkout());

    return TrackingState.initial();
  }

  /// Parses a GPS point JSON message sent from the background isolate.
  void _onTaskData(Object data) {
    if (data is! String) return;
    if (state.status != TrackingStatus.recording) return;

    final Map<String, dynamic> json = jsonDecode(data);
    final point = GpsPoint()
      ..timestamp = DateTime.parse(json['timestamp'] as String)
      ..latitude = (json['latitude'] as num).toDouble()
      ..longitude = (json['longitude'] as num).toDouble()
      ..altitude = (json['altitude'] as num?)?.toDouble()
      ..accuracy = (json['accuracy'] as num?)?.toDouble()
      ..speed = (json['speed'] as num?)?.toDouble();

    _onGpsPointReceived(point);
  }

  /// Restores any active, uncompleted workout from the Isar database.
  Future<void> restoreActiveWorkout() async {
    if (state.status != TrackingStatus.idle) return;
    try {
      final isar = await ref.read(isarProvider.future);
      final activeWorkout = await ref
          .read(gpsServiceProvider)
          .getActiveWorkout(isar);

      if (activeWorkout == null) return;
      if (state.status != TrackingStatus.idle) return;

      if (activeWorkout.gpsPoints.isAttached) {
        await activeWorkout.gpsPoints.load();
      }
      final points = activeWorkout.gpsPoints.toList();

      if (activeWorkout.sensorData.isAttached) {
        await activeWorkout.sensorData.load();
      }
      final sensors = activeWorkout.sensorData.toList();

      final restoredStatus = activeWorkout.isPaused
          ? TrackingStatus.paused
          : TrackingStatus.recording;

      double restoredDistance = 0.0;
      double restoredElevationGain = 0.0;
      if (points.length >= 2) {
        for (int i = 1; i < points.length; i++) {
          restoredDistance += _calculateDistance(
            points[i - 1].latitude,
            points[i - 1].longitude,
            points[i].latitude,
            points[i].longitude,
          );
          if (points[i].altitude != null && points[i - 1].altitude != null) {
            final diff = points[i].altitude! - points[i - 1].altitude!;
            if (diff > 0) restoredElevationGain += diff;
          }
        }
      } else {
        restoredDistance = activeWorkout.distanceMeters;
        restoredElevationGain = activeWorkout.elevationGain ?? 0.0;
      }

      state = TrackingState(
        status: restoredStatus,
        activeWorkoutId: activeWorkout.id,
        name: activeWorkout.name,
        sportType: activeWorkout.sportType,
        startTime: activeWorkout.startTime,
        durationSeconds: activeWorkout.durationSeconds,
        distanceMeters: restoredDistance,
        gpsPoints: points,
        sensorData: sensors,
        currentSpeed: points.isNotEmpty ? (points.last.speed ?? 0.0) : 0.0,
        currentAltitude:
            points.isNotEmpty ? (points.last.altitude ?? 0.0) : 0.0,
        elevationGain: restoredElevationGain,
      );

      if (restoredStatus == TrackingStatus.recording) {
        _startTimer();
        // Re-attach to the already-running service if it survived app closure.
        final isRunning =
            await ref.read(gpsServiceProvider).isServiceRunning;
        if (!isRunning) {
          await ref.read(gpsServiceProvider).startForegroundService();
        }
      }
    } catch (_) {}
  }

  /// Starts tracking a new workout session for [sportType].
  Future<Result<void, AppException>> startTracking(String sportType) async {
    if (state.status != TrackingStatus.idle) return const Success(null);

    final permissionService = ref.read(permissionServiceProvider);

    final hasPermission = await permissionService.hasLocationPermission();
    if (!hasPermission) {
      final granted = await permissionService.requestLocationPermission();
      if (!granted) {
        return const Failure(
            PermissionException('Location permission not granted.'));
      }
    }

    final hasBackgroundPermission =
        await permissionService.hasBackgroundLocationPermission();
    if (!hasBackgroundPermission) {
      final granted =
          await permissionService.requestBackgroundLocationPermission();
      if (!granted) {
        return const Failure(
            PermissionException('Background location permission not granted.'));
      }
    }

    final isIgnoringBattery =
        await permissionService.hasIgnoreBatteryOptimizationsPermission();
    if (!isIgnoringBattery) {
      await permissionService.requestIgnoreBatteryOptimizationsPermission();
    }

    final workout = Workout()
      ..sportType = sportType
      ..startTime = DateTime.now()
      ..isCompleted = false
      ..isPaused = false
      ..durationSeconds = 0.0
      ..distanceMeters = 0.0
      ..elevationGain = 0.0;

    try {
      final isar = await ref.read(isarProvider.future);
      await isar.writeTxn(() async {
        await isar.workouts.put(workout);
      });
    } catch (e) {
      return Failure(DatabaseException('Failed to initialize workout: $e'));
    }

    state = TrackingState(
      status: TrackingStatus.recording,
      activeWorkoutId: workout.id,
      sportType: sportType,
      startTime: workout.startTime,
    );

    _startTimer();
    await ref.read(gpsServiceProvider).startForegroundService();

    return const Success(null);
  }

  /// Pauses the active tracking session, stopping the timer.
  void pauseTracking() {
    if (state.status != TrackingStatus.recording) return;

    _timer?.cancel();
    state = state.copyWith(status: TrackingStatus.paused);

    final id = state.activeWorkoutId;
    if (id != null) {
      ref.read(isarProvider.future).then((isar) {
        isar.writeTxn(() async {
          final workout = await isar.workouts.get(id);
          if (workout != null) {
            workout.isPaused = true;
            await isar.workouts.put(workout);
          }
        }).catchError((_) {});
      }).catchError((_) {});
    }
  }

  /// Resumes the paused tracking session and restarts the timer.
  void resumeTracking() {
    if (state.status != TrackingStatus.paused) return;

    state = state.copyWith(status: TrackingStatus.recording);
    _startTimer();

    final id = state.activeWorkoutId;
    if (id != null) {
      ref.read(isarProvider.future).then((isar) {
        isar.writeTxn(() async {
          final workout = await isar.workouts.get(id);
          if (workout != null) {
            workout.isPaused = false;
            await isar.workouts.put(workout);
          }
        }).catchError((_) {});
      }).catchError((_) {});
    }
  }

  /// Discards the active tracking session and resets to idle.
  void discardTracking() {
    final id = state.activeWorkoutId;
    _cleanup();
    state = TrackingState.initial();

    if (id != null) {
      ref.read(isarProvider.future).then((isar) {
        isar.writeTxn(() async {
          final workout = await isar.workouts.get(id);
          if (workout != null) {
            if (workout.gpsPoints.isAttached) await workout.gpsPoints.load();
            for (final pt in workout.gpsPoints.toList()) {
              await isar.gpsPoints.delete(pt.id);
            }
            if (workout.sensorData.isAttached) await workout.sensorData.load();
            for (final s in workout.sensorData.toList()) {
              await isar.sensorDatas.delete(s.id);
            }
            await isar.workouts.delete(id);
          }
        }).catchError((_) {});
      }).catchError((_) {});
    }
  }

  /// Sets the custom name for the active workout session.
  void setWorkoutName(String name) {
    state = state.copyWith(name: name);
  }

  /// Stops tracking, persists final workout data, and resets to idle.
  Future<Result<Workout, AppException>> stopTracking() async {
    final recordedState = state;
    _cleanup();
    state = TrackingState.initial();

    final id = recordedState.activeWorkoutId;
    if (id == null) {
      return Failure(DatabaseException('No active workout to stop.'));
    }

    try {
      final isar = await ref.read(isarProvider.future);
      Workout? finalWorkout;
      await isar.writeTxn(() async {
        final workout = await isar.workouts.get(id);
        if (workout != null) {
          workout.name = recordedState.name;
          workout.endTime = DateTime.now();
          workout.durationSeconds = recordedState.durationSeconds;
          
          if (workout.gpsPoints.isAttached) await workout.gpsPoints.load();
          final points = workout.gpsPoints.toList();

          double finalDistance = 0.0;
          double finalElevationGain = 0.0;
          if (points.isNotEmpty) {
            for (int i = 1; i < points.length; i++) {
              finalDistance += _calculateDistance(
                points[i - 1].latitude,
                points[i - 1].longitude,
                points[i].latitude,
                points[i].longitude,
              );
              if (points[i].altitude != null && points[i - 1].altitude != null) {
                final diff = points[i].altitude! - points[i - 1].altitude!;
                if (diff > 0) finalElevationGain += diff;
              }
            }
          }

          workout.distanceMeters = finalDistance;
          workout.elevationGain = finalElevationGain;
          workout.isCompleted = true;
          workout.isPaused = false;

          if (recordedState.durationSeconds > 0) {
            workout.averageSpeed =
                finalDistance / recordedState.durationSeconds;
          }

          if (points.isNotEmpty) {
            workout.maxSpeed = points
                .map((p) => p.speed ?? 0.0)
                .fold<double>(0.0, (maxVal, speed) => max(maxVal, speed));
          }

          await isar.workouts.put(workout);
          finalWorkout = workout;
        }
      });

      if (finalWorkout == null) {
        return Failure(DatabaseException('Workout not found in database.'));
      }

      return Success(finalWorkout!);
    } catch (e) {
      return Failure(DatabaseException('Failed to save workout: $e'));
    }
  }

  /// Increments the active workout duration by 1 second if currently recording.
  /// Updates in-memory state only; the background isolate persists to Isar.
  void tick() {
    if (state.status == TrackingStatus.recording) {
      state = state.copyWith(durationSeconds: state.durationSeconds + 1.0);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  void _cleanup() {
    _timer?.cancel();
    _timer = null;
    ref.read(gpsServiceProvider).stopForegroundService();
  }

  /// For testing only: directly process a GPS point without going through
  /// the foreground task channel.
  @visibleForTesting
  void processGpsPointForTesting(GpsPoint point) {
    if (state.status != TrackingStatus.recording) return;
    _onGpsPointReceived(point);
  }

  void _onGpsPointReceived(GpsPoint point) {
    if (point.accuracy == null || point.accuracy! > 35.0) {
      return;
    }
    final updatedPoints = List<GpsPoint>.from(state.gpsPoints)..add(point);
    double newDistance = state.distanceMeters;
    double newElevationGain = state.elevationGain;

    if (state.gpsPoints.isNotEmpty) {
      final prevPoint = state.gpsPoints.last;

      newDistance += _calculateDistance(
        prevPoint.latitude,
        prevPoint.longitude,
        point.latitude,
        point.longitude,
      );

      if (point.altitude != null && prevPoint.altitude != null) {
        final diff = point.altitude! - prevPoint.altitude!;
        if (diff > 0) newElevationGain += diff;
      }
    }

    // Update in-memory state only. Persistence is handled by the background
    // isolate (TrackingTaskHandler) to avoid duplicate writes and contention.
    state = state.copyWith(
      gpsPoints: updatedPoints,
      distanceMeters: newDistance,
      elevationGain: newElevationGain,
      currentSpeed: point.speed ?? 0.0,
      currentAltitude: point.altitude ?? 0.0,
    );
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    final dLat = (lat2 - lat1) * pi / 180.0;
    final dLon = (lon2 - lon1) * pi / 180.0;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180.0) *
            cos(lat2 * pi / 180.0) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }
}
