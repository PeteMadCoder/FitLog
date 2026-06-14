import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permission_service.g.dart';

/// Service responsible for managing app permissions including Location (GPS)
/// and Bluetooth (sensors).
class PermissionService {
  const PermissionService();

  /// Check if standard foreground location permissions are granted.
  Future<bool> hasLocationPermission() async {
    return await Permission.location.isGranted;
  }

  /// Request standard foreground location permissions.
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Check if background/always location permissions are granted.
  Future<bool> hasBackgroundLocationPermission() async {
    return await Permission.locationAlways.isGranted;
  }

  /// Request background/always location permissions.
  /// 
  /// Note: On Android, the foreground location permission must be granted
  /// first before attempting to request "always" location permission.
  Future<bool> requestBackgroundLocationPermission() async {
    if (!await hasLocationPermission()) {
      final locationGranted = await requestLocationPermission();
      if (!locationGranted) {
        return false;
      }
    }
    final status = await Permission.locationAlways.request();
    return status.isGranted;
  }

  /// Check if BLE Bluetooth permissions are granted.
  Future<bool> hasBluetoothPermission() async {
    if (Platform.isAndroid) {
      // Android 12 (API 31) and higher require scan and connect runtime permissions.
      final scanGranted = await Permission.bluetoothScan.isGranted;
      final connectGranted = await Permission.bluetoothConnect.isGranted;
      return scanGranted && connectGranted;
    }
    // iOS uses a single bluetooth permission request.
    return await Permission.bluetooth.isGranted;
  }

  /// Request BLE Bluetooth permissions.
  Future<bool> requestBluetoothPermission() async {
    if (Platform.isAndroid) {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();
      
      return statuses[Permission.bluetoothScan]?.isGranted == true &&
          statuses[Permission.bluetoothConnect]?.isGranted == true;
    }
    
    final status = await Permission.bluetooth.request();
    return status.isGranted;
  }

  /// Open the system settings page for the app so the user can manually grant permissions.
  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}

/// Provider exposing the PermissionService singleton.
@riverpod
PermissionService permissionService(PermissionServiceRef ref) {
  return const PermissionService();
}
