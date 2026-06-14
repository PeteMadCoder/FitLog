import 'dart:async';
import 'dart:math';
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
    return TrackingState.initial();
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

    final gpsService = ref.read(gpsServiceProvider);
    await gpsService.configureGpsSettings();
    await gpsService.enableBackgroundMode();

    state = TrackingState(
      status: TrackingStatus.recording,
      sportType: sportType,
      startTime: DateTime.now(),
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
  }

  /// Resumes the paused tracking session and restarts the timer.
  void resumeTracking() {
    if (state.status != TrackingStatus.paused) return;

    state = state.copyWith(status: TrackingStatus.recording);
    _startTimer();
  }

  /// Discards the active tracking session, cancels updates, and resets to idle.
  void discardTracking() {
    _cleanup();
    state = TrackingState.initial();
  }

  /// Stops tracking, cancels updates, persists the workout session data to Isar database,
  /// and resets the notifier to idle.
  Future<Result<Workout, AppException>> stopTracking() async {
    final recordedState = state;
    _cleanup();
    state = TrackingState.initial();

    final workout = Workout()
      ..sportType = recordedState.sportType
      ..startTime = recordedState.startTime ?? DateTime.now()
      ..endTime = DateTime.now()
      ..durationSeconds = recordedState.durationSeconds
      ..distanceMeters = recordedState.distanceMeters
      ..elevationGain = recordedState.elevationGain
      ..isCompleted = true;

    if (recordedState.durationSeconds > 0) {
      workout.averageSpeed =
          recordedState.distanceMeters / recordedState.durationSeconds;
    }

    if (recordedState.gpsPoints.isNotEmpty) {
      workout.maxSpeed = recordedState.gpsPoints
          .map((p) => p.speed ?? 0.0)
          .fold<double>(0.0, (maxVal, speed) => max(maxVal, speed));
    }

    try {
      final isar = await ref.read(isarProvider.future);
      await isar.writeTxn(() async {
        final gpsPointsToInsert = recordedState.gpsPoints;
        await isar.gpsPoints.putAll(gpsPointsToInsert);

        final sensorDatasToInsert = recordedState.sensorData;
        if (sensorDatasToInsert.isNotEmpty) {
          await isar.sensorDatas.putAll(sensorDatasToInsert);
        }

        await isar.workouts.put(workout);

        workout.gpsPoints.addAll(gpsPointsToInsert);
        if (sensorDatasToInsert.isNotEmpty) {
          workout.sensorData.addAll(sensorDatasToInsert);
        }

        if (workout.gpsPoints.isAttached) {
          await workout.gpsPoints.save();
        }
        if (sensorDatasToInsert.isNotEmpty && workout.sensorData.isAttached) {
          await workout.sensorData.save();
        }
      });
      return Success(workout);
    } catch (e) {
      return Failure(DatabaseException('Failed to save workout: $e'));
    }
  }

  /// Increments the active workout duration by 1 second if currently recording.
  void tick() {
    if (state.status == TrackingStatus.recording) {
      state = state.copyWith(durationSeconds: state.durationSeconds + 1.0);
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
