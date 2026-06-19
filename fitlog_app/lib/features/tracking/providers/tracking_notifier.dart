import 'dart:async';
import 'dart:math';
import 'package:isar/isar.dart';
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
@riverpod
class TrackingNotifier extends _$TrackingNotifier {
  StreamSubscription<GpsPoint>? _gpsSubscription;
  Timer? _timer;

  @override
  TrackingState build() {
    ref.onDispose(() {
      _gpsSubscription?.cancel();
      _timer?.cancel();
    });

    // Asynchronously restore active workout if there is one in the database
    Future.microtask(() => restoreActiveWorkout());

    return TrackingState.initial();
  }

  /// Restores any active, uncompleted workout from the Isar database.
  Future<void> restoreActiveWorkout() async {
    if (state.status != TrackingStatus.idle) return;
    try {
      final isar = await ref.read(isarProvider.future);
      final activeWorkout = await ref
          .read(gpsServiceProvider)
          .getActiveWorkout(isar);

      if (activeWorkout != null) {
        if (state.status != TrackingStatus.idle) return;
        // Load GPS points
        if (activeWorkout.gpsPoints.isAttached) {
          await activeWorkout.gpsPoints.load();
        }
        final points = activeWorkout.gpsPoints.toList();

        // Load sensor data
        if (activeWorkout.sensorData.isAttached) {
          await activeWorkout.sensorData.load();
        }
        final sensors = activeWorkout.sensorData.toList();

        final restoredStatus = activeWorkout.isPaused
            ? TrackingStatus.paused
            : TrackingStatus.recording;

        state = TrackingState(
          status: restoredStatus,
          activeWorkoutId: activeWorkout.id,
          name: activeWorkout.name,
          sportType: activeWorkout.sportType,
          startTime: activeWorkout.startTime,
          durationSeconds: activeWorkout.durationSeconds,
          distanceMeters: activeWorkout.distanceMeters,
          gpsPoints: points,
          sensorData: sensors,
          currentSpeed: points.isNotEmpty ? (points.last.speed ?? 0.0) : 0.0,
          currentAltitude: points.isNotEmpty ? (points.last.altitude ?? 0.0) : 0.0,
          elevationGain: activeWorkout.elevationGain ?? 0.0,
        );

        if (restoredStatus == TrackingStatus.recording) {
          _startTimer();

          final gpsService = ref.read(gpsServiceProvider);
          await gpsService.configureGpsSettings();
          await gpsService.enableBackgroundMode();

          _gpsSubscription?.cancel();
          _gpsSubscription = gpsService.getGpsPointStream().listen(
            _onGpsPointReceived,
            onError: (e) {},
          );
        }
      }
    } catch (_) {}
  }

  /// Starts tracking a new workout session for [sportType].
  ///
  /// Checks location permission first. If granted, configures GPS settings,
  /// activates background mode, begins location updates streaming, and starts the timer.
  Future<Result<void, AppException>> startTracking(String sportType) async {
    if (state.status != TrackingStatus.idle) {
      return const Success(null);
    }

    final permissionService = ref.read(permissionServiceProvider);

    // Check foreground location permission
    final hasPermission = await permissionService.hasLocationPermission();
    if (!hasPermission) {
      final granted = await permissionService.requestLocationPermission();
      if (!granted) {
        return const Failure(
          PermissionException('Location permission not granted.'),
        );
      }
    }

    // Check background location permission
    final hasBackgroundPermission =
        await permissionService.hasBackgroundLocationPermission();
    if (!hasBackgroundPermission) {
      final granted =
          await permissionService.requestBackgroundLocationPermission();
      if (!granted) {
        return const Failure(
          PermissionException('Background location permission not granted.'),
        );
      }
    }

    final gpsService = ref.read(gpsServiceProvider);
    await gpsService.configureGpsSettings();
    await gpsService.enableBackgroundMode();

    // Create active draft workout in database
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

    _gpsSubscription?.cancel();
    _gpsSubscription = gpsService.getGpsPointStream().listen(
      _onGpsPointReceived,
      onError: (e) {
        // Gracefully ignore stream telemetry errors
      },
    );

    return const Success(null);
  }

  /// Pauses the active tracking session, stopping the timer.
  void pauseTracking() {
    if (state.status != TrackingStatus.recording) return;

    _timer?.cancel();
    state = state.copyWith(status: TrackingStatus.paused);

    // Update isPaused in Isar database
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

    // Update isPaused in Isar database
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

  /// Discards the active tracking session, cancels updates, and resets to idle.
  void discardTracking() {
    final id = state.activeWorkoutId;
    _cleanup();
    state = TrackingState.initial();

    if (id != null) {
      ref.read(isarProvider.future).then((isar) {
        isar.writeTxn(() async {
          final workout = await isar.workouts.get(id);
          if (workout != null) {
            if (workout.gpsPoints.isAttached) {
              await workout.gpsPoints.load();
            }
            final pts = workout.gpsPoints.toList();
            for (final pt in pts) {
              await isar.gpsPoints.delete(pt.id);
            }
            if (workout.sensorData.isAttached) {
              await workout.sensorData.load();
            }
            final sensors = workout.sensorData.toList();
            for (final s in sensors) {
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

  /// Stops tracking, cancels updates, persists the workout session data to Isar database,
  /// and resets the notifier to idle.
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
          workout.distanceMeters = recordedState.distanceMeters;
          workout.elevationGain = recordedState.elevationGain;
          workout.isCompleted = true;
          workout.isPaused = false;

          if (recordedState.durationSeconds > 0) {
            workout.averageSpeed =
                recordedState.distanceMeters / recordedState.durationSeconds;
          }

          if (workout.gpsPoints.isAttached) {
            await workout.gpsPoints.load();
          }
          if (workout.gpsPoints.isNotEmpty) {
            workout.maxSpeed = workout.gpsPoints
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
  void tick() {
    if (state.status == TrackingStatus.recording) {
      final newDuration = state.durationSeconds + 1.0;
      state = state.copyWith(durationSeconds: newDuration);

      final id = state.activeWorkoutId;
      if (id != null) {
        ref.read(isarProvider.future).then((isar) {
          isar.writeTxn(() async {
            final workout = await isar.workouts.get(id);
            if (workout != null) {
              workout.durationSeconds = newDuration;
              await isar.workouts.put(workout);
            }
          }).catchError((_) {});
        }).catchError((_) {});
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      tick();
    });
  }

  void _cleanup() {
    _timer?.cancel();
    _gpsSubscription?.cancel();
    _gpsSubscription = null;

    ref.read(gpsServiceProvider).disableBackgroundMode();
  }

  void _onGpsPointReceived(GpsPoint point) {
    if (state.status != TrackingStatus.recording) return;

    final updatedPoints = List<GpsPoint>.from(state.gpsPoints)..add(point);
    double newDistance = state.distanceMeters;
    double newElevationGain = state.elevationGain;

    if (state.gpsPoints.isNotEmpty) {
      final prevPoint = state.gpsPoints.last;

      // Calculate distance using standard Haversine formula
      final dist = _calculateDistance(
        prevPoint.latitude,
        prevPoint.longitude,
        point.latitude,
        point.longitude,
      );
      newDistance += dist;

      // Accumulate positive elevation difference
      if (point.altitude != null && prevPoint.altitude != null) {
        final diff = point.altitude! - prevPoint.altitude!;
        if (diff > 0) {
          newElevationGain += diff;
        }
      }
    }

    state = state.copyWith(
      gpsPoints: updatedPoints,
      distanceMeters: newDistance,
      elevationGain: newElevationGain,
      currentSpeed: point.speed ?? 0.0,
      currentAltitude: point.altitude ?? 0.0,
    );

    // Save GPS point and update workout metrics in Isar in real-time
    final id = state.activeWorkoutId;
    if (id != null) {
      ref.read(isarProvider.future).then((isar) {
        isar.writeTxn(() async {
          await isar.gpsPoints.put(point);
          final workout = await isar.workouts.get(id);
          if (workout != null) {
            workout.gpsPoints.add(point);
            workout.distanceMeters = newDistance;
            workout.elevationGain = newElevationGain;
            await isar.workouts.put(workout);
            if (workout.gpsPoints.isAttached) {
              await workout.gpsPoints.save();
            }
          }
        }).catchError((_) {});
      }).catchError((_) {});
    }
  }

  /// Computes distance in meters between two lat/lng coordinates using the Haversine formula.
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371000.0; // Earth radius in meters
    final dLat = (lat2 - lat1) * pi / 180.0;
    final dLon = (lon2 - lon1) * pi / 180.0;

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180.0) *
            cos(lat2 * pi / 180.0) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }
}
