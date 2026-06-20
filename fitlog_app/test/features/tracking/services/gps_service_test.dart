import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/tracking/services/gps_service.dart';

void main() {
  group('GpsService Tests', () {
    test('gpsServiceProvider supplies a GpsService instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(gpsServiceProvider), isA<GpsService>());
    });
  });
}
