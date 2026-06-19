import 'package:fitlog_app/features/tracking/models/gps_point.dart';
import 'package:fitlog_app/features/tracking/models/sensor_data.dart';

/// Defines the possible states of active workout tracking.
enum TrackingStatus { idle, recording, paused }

/// Repersents the live data stream of an active workout session.
class TrackingState {
  final TrackingStatus status;
  final int? activeWorkoutId;
  final String? name;
  final String sportType;
  final DateTime? startTime;
  final double durationSeconds;
  final double distanceMeters;
  final List<GpsPoint> gpsPoints;
  final List<SensorData> sensorData;
  final double currentSpeed;
  final double currentAltitude;
  final double elevationGain;

  const TrackingState({
    required this.status,
    this.activeWorkoutId,
    this.name,
    required this.sportType,
    this.startTime,
    this.durationSeconds = 0.0,
    this.distanceMeters = 0.0,
    this.gpsPoints = const [],
    this.sensorData = const [],
    this.currentSpeed = 0.0,
    this.currentAltitude = 0.0,
    this.elevationGain = 0.0,
  });

  /// Factory constructor for initial idle state.
  factory TrackingState.initial() {
    return const TrackingState(
      status: TrackingStatus.idle,
      sportType: 'running',
    );
  }

  TrackingState copyWith({
    TrackingStatus? status,
    int? activeWorkoutId,
    String? name,
    String? sportType,
    DateTime? startTime,
    double? durationSeconds,
    double? distanceMeters,
    List<GpsPoint>? gpsPoints,
    List<SensorData>? sensorData,
    double? currentSpeed,
    double? currentAltitude,
    double? elevationGain,
  }) {
    return TrackingState(
      status: status ?? this.status,
      activeWorkoutId: activeWorkoutId ?? this.activeWorkoutId,
      name: name ?? this.name,
      sportType: sportType ?? this.sportType,
      startTime: startTime ?? this.startTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      gpsPoints: gpsPoints ?? this.gpsPoints,
      sensorData: sensorData ?? this.sensorData,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      currentAltitude: currentAltitude ?? this.currentAltitude,
      elevationGain: elevationGain ?? this.elevationGain,
    );
  }
}
