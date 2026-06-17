import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:xml/xml.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';
import 'package:fitlog_app/features/tracking/models/gps_point.dart';

part 'gpx_export_service.g.dart';

/// Service responsible for exporting [Workout] data to GPX format.
@riverpod
class GpxExportService extends _$GpxExportService {
  @override
  void build() {}

  /// Exports a [Workout] to a GPX 1.1 formatted string.
  /// Uses [compute] to perform the XML generation in a background isolate.
  Future<String> exportToGpx(Workout workout) async {
    // In Isar, we must ensure the list is ready if it's coming from IsarLinks
    final points = workout.gpsPoints.toList();

    return generateGpx(
      name: workout.name,
      sportType: workout.sportType,
      startTime: workout.startTime,
      points: points,
    );
  }

  /// Generates a GPX 1.1 string from provided workout metadata and points.
  Future<String> generateGpx({
    String? name,
    required String sportType,
    required DateTime startTime,
    required List<GpsPoint> points,
  }) async {
    final workoutData = _WorkoutExportData(
      name: name,
      sportType: sportType,
      startTime: startTime,
      points: points
          .map((p) => _GpsPointExportData(
                latitude: p.latitude,
                longitude: p.longitude,
                altitude: p.altitude,
                timestamp: p.timestamp,
              ))
          .toList(),
    );

    return compute(_generateGpx, workoutData);
  }
}

/// Simplified data structure for GPX generation in an isolate.
class _WorkoutExportData {
  final String? name;
  final String sportType;
  final DateTime startTime;
  final List<_GpsPointExportData> points;

  _WorkoutExportData({
    this.name,
    required this.sportType,
    required this.startTime,
    required this.points,
  });
}

class _GpsPointExportData {
  final double latitude;
  final double longitude;
  final double? altitude;
  final DateTime timestamp;

  _GpsPointExportData({
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.timestamp,
  });
}

/// Top-level function for [compute] to generate the GPX XML.
String _generateGpx(_WorkoutExportData data) {
  final builder = XmlBuilder();
  builder.processing('xml', 'version="1.0" encoding="UTF-8"');
  builder.element('gpx', attributes: {
    'version': '1.1',
    'creator': 'FitLog',
    'xmlns': 'http://www.topografix.com/GPX/1/1',
    'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
    'xsi:schemaLocation': 'http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd',
  }, nest: () {
    builder.element('metadata', nest: () {
      if (data.name != null && data.name!.isNotEmpty) {
        builder.element('name', nest: data.name);
      }
      builder.element('time', nest: data.startTime.toUtc().toIso8601String());
    });

    builder.element('trk', nest: () {
      if (data.name != null && data.name!.isNotEmpty) {
        builder.element('name', nest: data.name);
      }
      builder.element('type', nest: data.sportType);
      builder.element('trkseg', nest: () {
        for (final point in data.points) {
          builder.element('trkpt', attributes: {
            'lat': point.latitude.toString(),
            'lon': point.longitude.toString(),
          }, nest: () {
            if (point.altitude != null) {
              builder.element('ele', nest: point.altitude.toString());
            }
            builder.element('time', nest: point.timestamp.toUtc().toIso8601String());
          });
        }
      });
    });
  });

  return builder.buildDocument().toXmlString(pretty: true);
}
