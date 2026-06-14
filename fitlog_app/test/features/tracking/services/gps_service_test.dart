import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';
import 'package:fitlog_app/features/tracking/services/gps_service.dart';
import 'package:fitlog_app/features/tracking/models/gps_point.dart';

// Simple hand-rolled stub for Location
class FakeLocation implements Location {
  bool backgroundModeEnabled = false;
  LocationAccuracy? lastAccuracy;
  int? lastInterval;
  double? lastDistanceFilter;

  String? lastNotificationTitle;
  String? lastNotificationSubtitle;

  final _controller = StreamController<LocationData>.broadcast();

  void emitLocation(LocationData data) {
    _controller.add(data);
  }

  @override
  Stream<LocationData> get onLocationChanged => _controller.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #changeSettings) {
      lastAccuracy = invocation.namedArguments[#accuracy] as LocationAccuracy?;
      lastInterval = invocation.namedArguments[#interval] as int?;
      lastDistanceFilter =
          invocation.namedArguments[#distanceFilter] as double?;
      return Future.value(true);
    }
    if (invocation.memberName == #enableBackgroundMode) {
      backgroundModeEnabled =
          invocation.namedArguments[#enable] as bool? ?? true;
      return Future.value(true);
    }
    if (invocation.memberName == #changeNotificationOptions) {
      lastNotificationTitle = invocation.namedArguments[#title] as String?;
      lastNotificationSubtitle =
          invocation.namedArguments[#subtitle] as String?;
      return Future.value(null);
    }
    return null;
  }
}

void main() {
  group('GpsService Tests', () {
    late FakeLocation fakeLocation;
    late GpsService gpsService;

    setUp(() {
      fakeLocation = FakeLocation();
      gpsService = GpsService(location: fakeLocation);
    });

    test(
      'configureGpsSettings configures high accuracy location settings',
      () async {
        await gpsService.configureGpsSettings();

        expect(fakeLocation.lastAccuracy, equals(LocationAccuracy.high));
        expect(fakeLocation.lastInterval, equals(1000));
        expect(fakeLocation.lastDistanceFilter, equals(0.0));
      },
    );

    test('enableBackgroundMode calls configuration and enables mode', () async {
      final result = await gpsService.enableBackgroundMode();

      expect(result, isTrue);
      expect(fakeLocation.backgroundModeEnabled, isTrue);
      expect(
        fakeLocation.lastNotificationTitle,
        equals('FitLog Active Activity'),
      );
      expect(fakeLocation.lastNotificationSubtitle, contains('background'));
    });

    test('disableBackgroundMode disables background mode', () async {
      fakeLocation.backgroundModeEnabled = true;

      final result = await gpsService.disableBackgroundMode();

      expect(result, isTrue);
      expect(fakeLocation.backgroundModeEnabled, isFalse);
    });

    test('getGpsPointStream maps LocationData to GpsPoint correctly', () async {
      final gpsStream = gpsService.getGpsPointStream();

      final dateNow = DateTime.now();
      final locationData = LocationData.fromMap({
        'latitude': 37.7749,
        'longitude': -122.4194,
        'accuracy': 4.5,
        'altitude': 120.0,
        'speed': 5.5,
        'time': dateNow.millisecondsSinceEpoch.toDouble(),
      });

      expect(
        gpsStream,
        emits(
          isA<GpsPoint>()
              .having((p) => p.latitude, 'latitude', equals(37.7749))
              .having((p) => p.longitude, 'longitude', equals(-122.4194))
              .having((p) => p.accuracy, 'accuracy', equals(4.5))
              .having((p) => p.altitude, 'altitude', equals(120.0))
              .having((p) => p.speed, 'speed', equals(5.5))
              .having(
                (p) => p.timestamp,
                'timestamp',
                equals(
                  DateTime.fromMillisecondsSinceEpoch(
                    dateNow.millisecondsSinceEpoch,
                  ),
                ),
              ),
        ),
      );

      fakeLocation.emitLocation(locationData);
    });

    test('gpsServiceProvider supplies the service', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(gpsServiceProvider), isA<GpsService>());
    });
  });
}
