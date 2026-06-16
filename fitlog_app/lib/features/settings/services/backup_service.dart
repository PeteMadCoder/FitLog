import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:xml/xml.dart';
import 'dart:math';

import '../../../app/app_providers.dart';
import '../../tracking/models/workout.dart';
import '../../tracking/models/gps_point.dart';
import '../../tracking/models/sensor_data.dart';
import '../models/user_settings.dart';
import '../providers/settings_provider.dart';

part 'backup_service.g.dart';

class ParsedWorkout {
  final Workout workout;
  final List<GpsPoint> gpsPoints;
  final List<SensorData> sensorData;

  ParsedWorkout({
    required this.workout,
    required this.gpsPoints,
    required this.sensorData,
  });
}

@riverpod
BackupService backupService(BackupServiceRef ref) {
  return BackupService(ref);
}

class BackupService {
  final Ref _ref;

  BackupService(this._ref);

  /// Helper to calculate distance between two coordinates in meters.
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000; // 2 * R; R = 6371 km
  }

  /// Helper to find elements by their local name, ignoring namespaces.
  Iterable<XmlElement> _findElementsByLocalName(XmlNode parent, String localName) {
    return parent.descendants.whereType<XmlElement>().where((e) => e.name.local == localName);
  }

  // --- Database Isolation Layer (Visible for testing to allow mocking) ---

  @visibleForTesting
  Future<List<Workout>> fetchAllWorkouts() async {
    final isar = await _ref.read(isarProvider.future);
    return await isar.workouts.where().findAll();
  }

  @visibleForTesting
  Future<List<GpsPoint>> getGpsPointsForWorkout(Workout workout) async {
    if (workout.gpsPoints.isAttached) {
      await workout.gpsPoints.load();
    }
    return workout.gpsPoints.toList();
  }

  @visibleForTesting
  Future<List<SensorData>> getSensorDataForWorkout(Workout workout) async {
    if (workout.sensorData.isAttached) {
      await workout.sensorData.load();
    }
    return workout.sensorData.toList();
  }

  @visibleForTesting
  Future<bool> workoutExistsAt(DateTime startTime) async {
    final isar = await _ref.read(isarProvider.future);
    final exists = await isar.workouts.filter().startTimeEqualTo(startTime).findFirst();
    return exists != null;
  }

  @visibleForTesting
  Future<void> saveImportedWorkouts(
    List<Workout> workouts,
    List<List<GpsPoint>> gpsPoints,
    List<List<SensorData>> sensorData,
  ) async {
    final isar = await _ref.read(isarProvider.future);
    await isar.writeTxn(() async {
      for (int i = 0; i < workouts.length; i++) {
        final workout = workouts[i];
        final gps = gpsPoints[i];
        final sensors = sensorData[i];

        if (gps.isNotEmpty) {
          await isar.gpsPoints.putAll(gps);
        }
        if (sensors.isNotEmpty) {
          await isar.sensorDatas.putAll(sensors);
        }

        await isar.workouts.put(workout);

        if (gps.isNotEmpty) {
          workout.gpsPoints.addAll(gps);
          await workout.gpsPoints.save();
        }
        if (sensors.isNotEmpty) {
          workout.sensorData.addAll(sensors);
          await workout.sensorData.save();
        }
      }
    });
  }

  // --- Core Business Logic ---

  /// Exports all workouts (including GPS points and sensor data) and settings to a JSON string.
  Future<String> exportToJson() async {
    final workouts = await fetchAllWorkouts();
    final List<Map<String, dynamic>> workoutsJson = [];
    
    for (final workout in workouts) {
      final gpsPoints = await getGpsPointsForWorkout(workout);
      final sensorData = await getSensorDataForWorkout(workout);

      final List<Map<String, dynamic>> gpsJson = gpsPoints.map((p) => {
        'timestamp': p.timestamp.toIso8601String(),
        'latitude': p.latitude,
        'longitude': p.longitude,
        'altitude': p.altitude,
        'accuracy': p.accuracy,
        'speed': p.speed,
      }).toList();

      final List<Map<String, dynamic>> sensorJson = sensorData.map((s) => {
        'timestamp': s.timestamp.toIso8601String(),
        'sensorType': s.sensorType,
        'value': s.value,
      }).toList();

      workoutsJson.add({
        'name': workout.name,
        'sportType': workout.sportType,
        'startTime': workout.startTime.toIso8601String(),
        'endTime': workout.endTime?.toIso8601String(),
        'durationSeconds': workout.durationSeconds,
        'distanceMeters': workout.distanceMeters,
        'averageSpeed': workout.averageSpeed,
        'maxSpeed': workout.maxSpeed,
        'elevationGain': workout.elevationGain,
        'elevationLoss': workout.elevationLoss,
        'averageHeartRate': workout.averageHeartRate,
        'maxHeartRate': workout.maxHeartRate,
        'calories': workout.calories,
        'isCompleted': workout.isCompleted,
        'gpsPoints': gpsJson,
        'sensorData': sensorJson,
      });
    }

    final settings = await _ref.read(settingsStateProvider.future);

    final Map<String, dynamic> exportData = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': settings.toJson(),
      'workouts': workoutsJson,
    };

    return jsonEncode(exportData);
  }

  /// Imports all workouts and settings from a JSON string.
  /// Overwrites settings, and appends workouts that do not exist (matching by startTime).
  Future<void> importFromJson(String jsonString) async {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

    // 1. Import Settings
    if (decoded.containsKey('settings')) {
      final settingsJson = decoded['settings'] as Map<String, dynamic>;
      final settings = UserSettings.fromJson(settingsJson);
      await _ref.read(settingsStateProvider.notifier).importSettings(settings);
    }

    // 2. Import Workouts
    if (decoded.containsKey('workouts')) {
      final workoutsList = decoded['workouts'] as List<dynamic>;
      
      final List<Workout> toInsertWorkouts = [];
      final List<List<GpsPoint>> toInsertGps = [];
      final List<List<SensorData>> toInsertSensors = [];

      for (final workoutRaw in workoutsList) {
        final workoutJson = workoutRaw as Map<String, dynamic>;
        final startTime = DateTime.parse(workoutJson['startTime'] as String);

        // Avoid duplicates
        final exists = await workoutExistsAt(startTime);
        if (exists) {
          continue;
        }

        final workout = Workout()
          ..name = workoutJson['name'] as String?
          ..sportType = workoutJson['sportType'] as String? ?? 'running'
          ..startTime = startTime
          ..endTime = workoutJson['endTime'] != null ? DateTime.parse(workoutJson['endTime'] as String) : null
          ..durationSeconds = (workoutJson['durationSeconds'] as num?)?.toDouble() ?? 0.0
          ..distanceMeters = (workoutJson['distanceMeters'] as num?)?.toDouble() ?? 0.0
          ..averageSpeed = (workoutJson['averageSpeed'] as num?)?.toDouble()
          ..maxSpeed = (workoutJson['maxSpeed'] as num?)?.toDouble()
          ..elevationGain = (workoutJson['elevationGain'] as num?)?.toDouble()
          ..elevationLoss = (workoutJson['elevationLoss'] as num?)?.toDouble()
          ..averageHeartRate = (workoutJson['averageHeartRate'] as num?)?.toDouble()
          ..maxHeartRate = (workoutJson['maxHeartRate'] as num?)?.toDouble()
          ..calories = (workoutJson['calories'] as num?)?.toDouble()
          ..isCompleted = workoutJson['isCompleted'] as bool? ?? false;

        final List<GpsPoint> gpsPointsList = [];
        if (workoutJson.containsKey('gpsPoints')) {
          final gpsList = workoutJson['gpsPoints'] as List<dynamic>;
          for (final gpsRaw in gpsList) {
            final gpsMap = gpsRaw as Map<String, dynamic>;
            final gpsPoint = GpsPoint()
              ..timestamp = DateTime.parse(gpsMap['timestamp'] as String)
              ..latitude = (gpsMap['latitude'] as num).toDouble()
              ..longitude = (gpsMap['longitude'] as num).toDouble()
              ..altitude = (gpsMap['altitude'] as num?)?.toDouble()
              ..accuracy = (gpsMap['accuracy'] as num?)?.toDouble()
              ..speed = (gpsMap['speed'] as num?)?.toDouble();
            gpsPointsList.add(gpsPoint);
          }
        }

        final List<SensorData> sensorDataList = [];
        if (workoutJson.containsKey('sensorData')) {
          final sensorList = workoutJson['sensorData'] as List<dynamic>;
          for (final sRaw in sensorList) {
            final sMap = sRaw as Map<String, dynamic>;
            final sensor = SensorData()
              ..timestamp = DateTime.parse(sMap['timestamp'] as String)
              ..sensorType = sMap['sensorType'] as String? ?? 'heart_rate'
              ..value = (sMap['value'] as num).toDouble();
            sensorDataList.add(sensor);
          }
        }

        toInsertWorkouts.add(workout);
        toInsertGps.add(gpsPointsList);
        toInsertSensors.add(sensorDataList);
      }

      if (toInsertWorkouts.isNotEmpty) {
        await saveImportedWorkouts(toInsertWorkouts, toInsertGps, toInsertSensors);
      }
    }
  }

  /// Copies the raw database file (default.isar) to the destination.
  Future<void> exportDatabase(String destinationPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File('${dir.path}/default.isar');
    if (await dbFile.exists()) {
      await dbFile.copy(destinationPath);
    } else {
      throw Exception('Database file default.isar not found at ${dir.path}');
    }
  }

  /// Reads and returns the raw database file bytes.
  Future<Uint8List> getDatabaseBytes() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File('${dir.path}/default.isar');
    if (await dbFile.exists()) {
      return await dbFile.readAsBytes();
    } else {
      throw Exception('Database file default.isar not found at ${dir.path}');
    }
  }

  /// Overwrites the raw database file (default.isar) with the backup from the specified path.
  Future<void> importDatabase(String sourcePath) async {
    final isar = await _ref.read(isarProvider.future);
    
    // Close current instance
    await isar.close();

    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File('${dir.path}/default.isar');
    final sourceFile = File(sourcePath);
    if (await sourceFile.exists()) {
      await sourceFile.copy(dbFile.path);
    } else {
      throw Exception('Source database file not found at $sourcePath');
    }

    // Invalidate isarProvider so next access opens the new database
    _ref.invalidate(isarProvider);
  }

  /// Parses a GPX XML string into a ParsedWorkout wrapper.
  ParsedWorkout parseGpx(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final gpxElement = document.rootElement;

    // Retrieve metadata/track name
    String workoutName = 'Imported GPX Workout';
    final metadataNode = _findElementsByLocalName(gpxElement, 'metadata').firstOrNull;
    final trkNode = _findElementsByLocalName(gpxElement, 'trk').firstOrNull;

    final metadataName = metadataNode != null ? _findElementsByLocalName(metadataNode, 'name').firstOrNull?.innerText : null;
    final trkName = trkNode != null ? _findElementsByLocalName(trkNode, 'name').firstOrNull?.innerText : null;

    if (trkName != null && trkName.trim().isNotEmpty) {
      workoutName = trkName.trim();
    } else if (metadataName != null && metadataName.trim().isNotEmpty) {
      workoutName = metadataName.trim();
    }

    // Attempt to parse sport type from GPX
    String sportType = 'running';
    final typeElement = trkNode != null ? _findElementsByLocalName(trkNode, 'type').firstOrNull : null;
    if (typeElement != null) {
      final val = typeElement.innerText.toLowerCase();
      if (val.contains('cycle') || val.contains('biking') || val.contains('ride') || val.contains('cycling')) {
        sportType = 'cycling';
      } else if (val.contains('walk')) {
        sportType = 'walking';
      } else if (val.contains('hike') || val.contains('hiking')) {
        sportType = 'hiking';
      } else {
        sportType = val;
      }
    }

    final gpsPointsList = <GpsPoint>[];
    final sensorDataList = <SensorData>[];

    // Find all track points namespace-independently
    final trkpts = _findElementsByLocalName(document, 'trkpt');
    for (final node in trkpts) {
      final latStr = node.getAttribute('lat');
      final lonStr = node.getAttribute('lon');
      if (latStr == null || lonStr == null) continue;

      final lat = double.tryParse(latStr);
      final lon = double.tryParse(lonStr);
      if (lat == null || lon == null) continue;

      final eleElement = _findElementsByLocalName(node, 'ele').firstOrNull;
      final ele = eleElement != null ? double.tryParse(eleElement.innerText) : null;

      final timeElement = _findElementsByLocalName(node, 'time').firstOrNull;
      final timestamp = timeElement != null ? DateTime.tryParse(timeElement.innerText)?.toUtc() : null;

      final point = GpsPoint()
        ..latitude = lat
        ..longitude = lon
        ..altitude = ele
        ..timestamp = timestamp ?? DateTime.now();

      // Look for Extensions like Garmin Heart Rate
      final hrElement = _findElementsByLocalName(node, 'hr').firstOrNull;
      if (hrElement != null) {
        final hrVal = double.tryParse(hrElement.innerText);
        if (hrVal != null) {
          sensorDataList.add(SensorData()
            ..timestamp = point.timestamp
            ..sensorType = 'heart_rate'
            ..value = hrVal);
        }
      }

      gpsPointsList.add(point);
    }

    if (gpsPointsList.isEmpty) {
      throw Exception('No GPS points found in GPX file.');
    }

    // Sort gpsPoints by timestamp just in case
    gpsPointsList.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate Workout summary statistics
    final startTime = gpsPointsList.first.timestamp;
    final endTime = gpsPointsList.last.timestamp;
    final durationSeconds = endTime.difference(startTime).inSeconds.toDouble();

    double distanceMeters = 0.0;
    double elevationGain = 0.0;
    double elevationLoss = 0.0;
    double maxSpeed = 0.0;

    for (int i = 0; i < gpsPointsList.length; i++) {
      final current = gpsPointsList[i];
      if (i > 0) {
        final prev = gpsPointsList[i - 1];
        // Distance
        final segmentDist = _calculateDistance(prev.latitude, prev.longitude, current.latitude, current.longitude);
        distanceMeters += segmentDist;

        // Speed calculation if point doesn't specify speed
        final timeDiff = current.timestamp.difference(prev.timestamp).inSeconds;
        if (timeDiff > 0) {
          final calcSpeed = segmentDist / timeDiff;
          current.speed = calcSpeed;
          if (calcSpeed > maxSpeed) {
            maxSpeed = calcSpeed;
          }
        }

        // Elevation Gain/Loss
        if (prev.altitude != null && current.altitude != null) {
          final diff = current.altitude! - prev.altitude!;
          if (diff > 0) {
            elevationGain += diff;
          } else {
            elevationLoss += diff.abs();
          }
        }
      }
    }

    double? avgHeartRate;
    double? maxHeartRate;
    if (sensorDataList.isNotEmpty) {
      final hrValues = sensorDataList.map((s) => s.value).toList();
      avgHeartRate = hrValues.reduce((a, b) => a + b) / hrValues.length;
      maxHeartRate = hrValues.reduce(max);
    }

    // Compute average speed
    double? averageSpeed;
    if (durationSeconds > 0) {
      averageSpeed = distanceMeters / durationSeconds;
    }

    // Basic calories estimation
    double caloriesVal = 0.0;
    double met = 8.0;
    if (sportType == 'cycling') met = 7.5;
    else if (sportType == 'walking') met = 3.5;
    else if (sportType == 'hiking') met = 6.0;

    double weightKg = 70.0;
    try {
      final settings = _ref.read(settingsStateProvider).value;
      if (settings != null && settings.weight != null) {
        weightKg = settings.weight!;
      }
    } catch (_) {}

    caloriesVal = met * weightKg * (durationSeconds / 3600.0);

    final workout = Workout()
      ..name = workoutName
      ..sportType = sportType
      ..startTime = startTime
      ..endTime = endTime
      ..durationSeconds = durationSeconds
      ..distanceMeters = distanceMeters
      ..averageSpeed = averageSpeed
      ..maxSpeed = maxSpeed > 0 ? maxSpeed : null
      ..elevationGain = elevationGain
      ..elevationLoss = elevationLoss
      ..averageHeartRate = avgHeartRate
      ..maxHeartRate = maxHeartRate
      ..calories = caloriesVal
      ..isCompleted = true;

    return ParsedWorkout(
      workout: workout,
      gpsPoints: gpsPointsList,
      sensorData: sensorDataList,
    );
  }

  /// Parses a TCX XML string into a ParsedWorkout wrapper.
  ParsedWorkout parseTcx(String xmlString) {
    final document = XmlDocument.parse(xmlString);

    // Attempt to parse sport type namespace-independently
    String sportType = 'running';
    final activityNode = _findElementsByLocalName(document, 'Activity').firstOrNull;
    if (activityNode != null) {
      final sportAttr = activityNode.getAttribute('Sport')?.toLowerCase();
      if (sportAttr != null) {
        if (sportAttr.contains('bike') || sportAttr.contains('cycling') || sportAttr.contains('biking')) {
          sportType = 'cycling';
        } else if (sportAttr.contains('running')) {
          sportType = 'running';
        } else if (sportAttr.contains('walking')) {
          sportType = 'walking';
        } else if (sportAttr.contains('hiking')) {
          sportType = 'hiking';
        }
      }
    }

    final gpsPointsList = <GpsPoint>[];
    final sensorDataList = <SensorData>[];

    final trackpoints = _findElementsByLocalName(document, 'Trackpoint');
    for (final node in trackpoints) {
      final timeNode = _findElementsByLocalName(node, 'Time').firstOrNull;
      if (timeNode == null) continue;
      final timestamp = DateTime.tryParse(timeNode.innerText)?.toUtc() ?? DateTime.now();

      // Position (latitude and longitude)
      final posNode = _findElementsByLocalName(node, 'Position').firstOrNull;
      double? lat;
      double? lon;
      if (posNode != null) {
        final latNode = _findElementsByLocalName(posNode, 'LatitudeDegrees').firstOrNull;
        final lonNode = _findElementsByLocalName(posNode, 'LongitudeDegrees').firstOrNull;
        if (latNode != null && lonNode != null) {
          lat = double.tryParse(latNode.innerText);
          lon = double.tryParse(lonNode.innerText);
        }
      }

      final altNode = _findElementsByLocalName(node, 'AltitudeMeters').firstOrNull;
      final alt = altNode != null ? double.tryParse(altNode.innerText) : null;

      if (lat != null && lon != null) {
        final point = GpsPoint()
          ..latitude = lat
          ..longitude = lon
          ..altitude = alt
          ..timestamp = timestamp;
        gpsPointsList.add(point);
      }

      // Heart Rate
      final hrNode = _findElementsByLocalName(node, 'HeartRateBpm').firstOrNull;
      if (hrNode != null) {
        final valNode = _findElementsByLocalName(hrNode, 'Value').firstOrNull;
        if (valNode != null) {
          final hrVal = double.tryParse(valNode.innerText);
          if (hrVal != null) {
            sensorDataList.add(SensorData()
              ..timestamp = timestamp
              ..sensorType = 'heart_rate'
              ..value = hrVal);
          }
        }
      }
    }

    if (gpsPointsList.isEmpty) {
      throw Exception('No GPS points found in TCX file.');
    }

    gpsPointsList.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final startTime = gpsPointsList.first.timestamp;
    final endTime = gpsPointsList.last.timestamp;
    final durationSeconds = endTime.difference(startTime).inSeconds.toDouble();

    double distanceMeters = 0.0;
    double elevationGain = 0.0;
    double elevationLoss = 0.0;
    double maxSpeed = 0.0;

    for (int i = 0; i < gpsPointsList.length; i++) {
      final current = gpsPointsList[i];
      if (i > 0) {
        final prev = gpsPointsList[i - 1];
        final segmentDist = _calculateDistance(prev.latitude, prev.longitude, current.latitude, current.longitude);
        distanceMeters += segmentDist;

        final timeDiff = current.timestamp.difference(prev.timestamp).inSeconds;
        if (timeDiff > 0) {
          final calcSpeed = segmentDist / timeDiff;
          current.speed = calcSpeed;
          if (calcSpeed > maxSpeed) {
            maxSpeed = calcSpeed;
          }
        }

        if (prev.altitude != null && current.altitude != null) {
          final diff = current.altitude! - prev.altitude!;
          if (diff > 0) {
            elevationGain += diff;
          } else {
            elevationLoss += diff.abs();
          }
        }
      }
    }

    double? avgHeartRate;
    double? maxHeartRate;
    if (sensorDataList.isNotEmpty) {
      final hrValues = sensorDataList.map((s) => s.value).toList();
      avgHeartRate = hrValues.reduce((a, b) => a + b) / hrValues.length;
      maxHeartRate = hrValues.reduce(max);
    }

    double? averageSpeed;
    if (durationSeconds > 0) {
      averageSpeed = distanceMeters / durationSeconds;
    }

    // MET calculations
    double met = 8.0;
    if (sportType == 'cycling') met = 7.5;
    else if (sportType == 'walking') met = 3.5;
    else if (sportType == 'hiking') met = 6.0;

    double weightKg = 70.0;
    try {
      final settings = _ref.read(settingsStateProvider).value;
      if (settings != null && settings.weight != null) {
        weightKg = settings.weight!;
      }
    } catch (_) {}

    double caloriesVal = met * weightKg * (durationSeconds / 3600.0);

    final workout = Workout()
      ..name = 'Imported TCX Workout'
      ..sportType = sportType
      ..startTime = startTime
      ..endTime = endTime
      ..durationSeconds = durationSeconds
      ..distanceMeters = distanceMeters
      ..averageSpeed = averageSpeed
      ..maxSpeed = maxSpeed > 0 ? maxSpeed : null
      ..elevationGain = elevationGain
      ..elevationLoss = elevationLoss
      ..averageHeartRate = avgHeartRate
      ..maxHeartRate = maxHeartRate
      ..calories = caloriesVal
      ..isCompleted = true;

    return ParsedWorkout(
      workout: workout,
      gpsPoints: gpsPointsList,
      sensorData: sensorDataList,
    );
  }

  /// Inserts a parsed GPX/TCX workout and its linked points/sensors into the database.
  Future<void> saveWorkout(ParsedWorkout parsed) async {
    await saveImportedWorkouts([parsed.workout], [parsed.gpsPoints], [parsed.sensorData]);
  }
}
