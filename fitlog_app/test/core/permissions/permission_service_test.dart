import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/core/permissions/permission_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter.baseflow.com/permissions/methods');

  group('PermissionService Tests', () {
    late PermissionService permissionService;
    late int mockStatusIndex;
    late Map<int, int> mockRequestResults;

    setUp(() {
      mockStatusIndex = 1; // Default to granted (index 1)
      mockRequestResults = {};

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'checkPermissionStatus') {
              return mockStatusIndex;
            } else if (methodCall.method == 'requestPermissions') {
              final List<dynamic> permissions = methodCall.arguments;
              final Map<int, int> results = {};
              for (final permission in permissions) {
                results[permission as int] =
                    mockRequestResults[permission] ?? mockStatusIndex;
              }
              return results;
            } else if (methodCall.method == 'openAppSettings') {
              return true;
            }
            return null;
          });

      permissionService = const PermissionService();
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('hasLocationPermission returns true when granted', () async {
      mockStatusIndex = 1; // granted
      final result = await permissionService.hasLocationPermission();
      expect(result, isTrue);
    });

    test('hasLocationPermission returns false when denied', () async {
      mockStatusIndex = 0; // denied
      final result = await permissionService.hasLocationPermission();
      expect(result, isFalse);
    });

    test('requestLocationPermission requests and returns status', () async {
      mockStatusIndex = 1; // granted
      final result = await permissionService.requestLocationPermission();
      expect(result, isTrue);
    });

    test('hasBackgroundLocationPermission returns status', () async {
      mockStatusIndex = 1; // granted
      final result = await permissionService.hasBackgroundLocationPermission();
      expect(result, isTrue);
    });

    test(
      'requestBackgroundLocationPermission returns true if granted',
      () async {
        mockStatusIndex = 1; // granted
        final result = await permissionService
            .requestBackgroundLocationPermission();
        expect(result, isTrue);
      },
    );

    test(
      'requestBackgroundLocationPermission returns false if foreground is denied',
      () async {
        mockStatusIndex = 0; // denied
        final result = await permissionService
            .requestBackgroundLocationPermission();
        expect(result, isFalse);
      },
    );

    test('hasBluetoothPermission returns status', () async {
      mockStatusIndex = 1; // granted
      final result = await permissionService.hasBluetoothPermission();
      expect(result, isTrue);
    });

    test('requestBluetoothPermission requests and returns status', () async {
      mockStatusIndex = 1; // granted
      final result = await permissionService.requestBluetoothPermission();
      expect(result, isTrue);
    });

    test('openSettings triggers app settings open', () async {
      final result = await permissionService.openSettings();
      expect(result, isTrue);
    });

    test('permissionServiceProvider supplies the service', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(
        container.read(permissionServiceProvider),
        isA<PermissionService>(),
      );
    });
  });
}
