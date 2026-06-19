import 'dart:math';
import 'package:fitlog_app/features/tracking/models/gps_point.dart';

/// Model representing a single workout split/lap (usually 1km).
class Split {
  final int index;
  final double distanceMeters;
  final Duration duration;
  final double averageSpeed;

  const Split({
    required this.index,
    required this.distanceMeters,
    required this.duration,
    required this.averageSpeed,
  });

  /// Calculates the average pace in minutes per kilometer.
  double get averagePaceMinPerKm {
    if (distanceMeters <= 0) return 0.0;
    final distanceKm = distanceMeters / 1000.0;
    final minutes = duration.inSeconds / 60.0;
    return minutes / distanceKm;
  }

  /// Returns the average speed in km/h.
  double get averageSpeedKmH => averageSpeed * 3.6;
}

/// Service responsible for analyzing telemetry data and calculating splits.
class SplitCalculator {
  /// Automatically calculates splits from a list of GpsPoints.
  /// Interpolates boundary crossings for precise duration estimations.
  static List<Split> calculateSplits(List<GpsPoint> points, {double splitTargetDistance = 1000.0}) {
    if (points.length < 2) return [];

    // Ensure points are sorted chronologically
    final sortedPoints = List<GpsPoint>.from(points)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final List<Split> splits = [];
    double cumulativeDistance = 0.0;
    double lastBoundaryDistance = 0.0;
    DateTime lastBoundaryTime = sortedPoints.first.timestamp;

    int splitIndex = 1;

    for (int i = 1; i < sortedPoints.length; i++) {
      final prev = sortedPoints[i - 1];
      final curr = sortedPoints[i];

      final segmentDist = _calculateDistance(
        prev.latitude,
        prev.longitude,
        curr.latitude,
        curr.longitude,
      );

      cumulativeDistance += segmentDist;

      // Check if we crossed a 1km boundary
      while (cumulativeDistance >= lastBoundaryDistance + splitTargetDistance) {
        final targetDistance = lastBoundaryDistance + splitTargetDistance;
        final segmentDistCovered =
            cumulativeDistance - (cumulativeDistance - segmentDist);

        // Avoid division by zero if segment distance is negligible
        final segmentFraction = segmentDistCovered > 0
            ? (targetDistance - (cumulativeDistance - segmentDist)) /
                  segmentDistCovered
            : 0.0;

        final segmentDurationMs = curr.timestamp
            .difference(prev.timestamp)
            .inMilliseconds;
        final interpolatedDurationMs = (segmentFraction * segmentDurationMs)
            .round();
        final interpolatedTime = prev.timestamp.add(
          Duration(milliseconds: interpolatedDurationMs),
        );

        final splitDuration = interpolatedTime.difference(lastBoundaryTime);
        final splitDurSec = splitDuration.inMilliseconds / 1000.0;
        final avgSpeed = splitDurSec > 0
            ? splitTargetDistance / splitDurSec
            : 0.0;

        splits.add(
          Split(
            index: splitIndex++,
            distanceMeters: splitTargetDistance,
            duration: splitDuration,
            averageSpeed: avgSpeed,
          ),
        );

        lastBoundaryDistance = targetDistance;
        lastBoundaryTime = interpolatedTime;
      }
    }

    // Add final remaining partial split if any
    final remainingDistance = cumulativeDistance - lastBoundaryDistance;
    if (remainingDistance > 1.0) {
      // Only if more than 1 meter remains
      final finalDuration = sortedPoints.last.timestamp.difference(
        lastBoundaryTime,
      );
      final finalDurSec = finalDuration.inMilliseconds / 1000.0;
      final avgSpeed = finalDurSec > 0 ? remainingDistance / finalDurSec : 0.0;

      if (finalDuration.inSeconds > 0) {
        splits.add(
          Split(
            index: splitIndex,
            distanceMeters: remainingDistance,
            duration: finalDuration,
            averageSpeed: avgSpeed,
          ),
        );
      }
    }

    return splits;
  }

  /// Computes distance in meters between two lat/lng coordinates using the Haversine formula.
  static double _calculateDistance(
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
