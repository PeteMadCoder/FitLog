import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';
import 'tracking_task_handler.dart';

part 'gps_service.g.dart';

/// Service responsible for managing the background GPS foreground service.
class GpsService {
  GpsService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'fitlog_tracking',
        channelName: 'FitLog Tracking',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  /// Retrieves any active, uncompleted workout from the Isar database.
  Future<Workout?> getActiveWorkout(Isar isar) async {
    return isar.workouts.filter().isCompletedEqualTo(false).findFirst();
  }

  /// Starts the GPS foreground service. Survives app closure.
  Future<bool> startForegroundService() async {
    // Request notification permission required on Android 13+.
    final notifPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notifPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    final result = await FlutterForegroundTask.startService(
      serviceId: 1001,
      notificationTitle: 'FitLog Active Workout',
      notificationText: 'Tracking your workout in the background.',
      callback: startTrackingService,
    );
    return result is ServiceRequestSuccess;
  }

  /// Stops the GPS foreground service.
  Future<bool> stopForegroundService() async {
    final result = await FlutterForegroundTask.stopService();
    return result is ServiceRequestSuccess;
  }

  /// Returns whether the foreground service is currently running.
  Future<bool> get isServiceRunning => FlutterForegroundTask.isRunningService;
}

/// Provider exposing the GpsService singleton.
@riverpod
GpsService gpsService(GpsServiceRef ref) {
  return GpsService();
}
