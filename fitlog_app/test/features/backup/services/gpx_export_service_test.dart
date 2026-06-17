import 'package:flutter_test/flutter_test.dart';
import 'package:fitlog_app/features/tracking/models/gps_point.dart';
import 'package:fitlog_app/features/backup/services/gpx_export_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xml/xml.dart';

void main() {
  // Ensure Flutter is initialized for compute()
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GpxExportService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('generates valid GPX 1.1 XML string', () async {
      final startTime = DateTime.utc(2026, 6, 17, 10, 0);
      final point1 = GpsPoint()
        ..latitude = 37.7749
        ..longitude = -122.4194
        ..altitude = 10.0
        ..timestamp = startTime.add(const Duration(seconds: 1));

      final point2 = GpsPoint()
        ..latitude = 37.7750
        ..longitude = -122.4195
        ..altitude = 12.0
        ..timestamp = startTime.add(const Duration(seconds: 2));

      final service = container.read(gpxExportServiceProvider.notifier);
      final gpxString = await service.generateGpx(
        name: 'Morning Run',
        sportType: 'running',
        startTime: startTime,
        points: [point1, point2],
      );

      expect(gpxString, contains('<?xml version="1.0" encoding="UTF-8"?>'));
      expect(gpxString, contains('<gpx version="1.1" creator="FitLog"'));
      expect(gpxString, contains('<name>Morning Run</name>'));
      expect(gpxString, contains('<type>running</type>'));
      expect(gpxString, contains('lat="37.7749" lon="-122.4194"'));
      expect(gpxString, contains('<ele>10.0</ele>'));
      expect(gpxString, contains('2026-06-17T10:00:01.000Z'));
      
      // Verify XML is well-formed
      final document = XmlDocument.parse(gpxString);
      expect(document.rootElement.name.local, equals('gpx'));
      expect(document.findAllElements('trkpt').length, equals(2));
    });

    test('handles missing workout name and altitudes', () async {
      final startTime = DateTime.utc(2026, 6, 17, 10, 0);
      final point = GpsPoint()
        ..latitude = 0.0
        ..longitude = 0.0
        ..timestamp = startTime;

      final service = container.read(gpxExportServiceProvider.notifier);
      final gpxString = await service.generateGpx(
        sportType: 'walking',
        startTime: startTime,
        points: [point],
      );

      final document = XmlDocument.parse(gpxString);
      expect(document.findAllElements('name').isEmpty, isTrue);
      expect(document.findAllElements('ele').isEmpty, isTrue);
      expect(document.findAllElements('trkpt').length, equals(1));
    });
  });
}
