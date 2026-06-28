"""
Compilation module for Sports Tracker GPX files.
Parses downloaded GPX files and calculates workout metrics to generate a JSON file
compatible with the FitLog import schema.
"""

import json
import math
import os
from datetime import datetime, timezone, timedelta
import gpxpy

# Map Sports Tracker activityId to FitLog sport type ids
SPORTS_TRACKER_ACTIVITY_MAP = {
    0: "walking",
    1: "running",
    2: "cycling",
    3: "cross_country_skiing",
    4: "other_1",
    10: "mountain_biking",
    11: "hiking",
    12: "roller_skating",
    13: "alpine_skiing",
    14: "paddling",
    15: "rowing",
    16: "golf",
    17: "indoor",
    18: "parkour",
    19: "ball_games",
    20: "outdoor_gym",
    21: "swimming",
    22: "trail_running",
    23: "gym",
    24: "nordic_walking",
    25: "horseback_riding",
    26: "motorsports",
    32: "fitness_class",
    33: "soccer",
    34: "tennis",
    35: "basketball",
    36: "badminton",
    38: "volleyball",
    40: "table_tennis",
    41: "racquetball",
    42: "squash",
    51: "yoga",
    52: "indoor_cycling",
    66: "frisbee_golf",
    67: "futsal",
    68: "multisport",
    69: "circuit_training",
    72: "other_1",
    75: "tennis",
    80: "adventure_racing",
    81: "track_and_field",
    82: "trail_running",
    83: "openwater_swimming",
    84: "nordic_walking",
    85: "snowshoeing",
    92: "swimrun",
    93: "duathlon",
    94: "aquathlon",
    95: "obstacle_racing",
    98: "other_1",
    99: "cycling",
    104: "outdoor_gym",
    121: "yoga",
}

# Standard MET (Metabolic Equivalent of Task) values for calorie calculations
MET_VALUES = {
    "cycling": 7.5,
    "walking": 3.5,
    "hiking": 6.0,
    "running": 8.0,
}
DEFAULT_MET = 8.0
DEFAULT_WEIGHT_KG = 70.0


def calculate_distance(lat1, lon1, lat2, lon2):
    """Calculate the great-circle distance between two points in meters using the Haversine formula."""
    p = math.pi / 180
    a = (
        0.5
        - math.cos((lat2 - lat1) * p) / 2
        + math.cos(lat1 * p)
        * math.cos(lat2 * p)
        * (1 - math.cos((lon2 - lon1) * p))
        / 2
    )
    return 12742 * math.asin(math.sqrt(a)) * 1000


def parse_sport_type(gpx_sport):
    """Normalize the sport type from the GPX into a FitLog-compatible identifier."""
    if not gpx_sport:
        return "running"
    sport = gpx_sport.lower().strip()
    if "cycle" in sport or "biking" in sport or "ride" in sport or "cycling" in sport:
        return "cycling"
    elif "walk" in sport:
        return "walking"
    elif "hike" in sport or "hiking" in sport:
        return "hiking"
    return sport


def compile_gpx_to_json(data_dir, output_file):
    """Parse all GPX files in data_dir and compile them into output_file JSON."""
    if not os.path.exists(data_dir):
        print(f"Data directory '{data_dir}' does not exist. Please extract GPX files first.")
        return False

    gpx_files = [f for f in os.listdir(data_dir) if f.endswith(".gpx")]
    if not gpx_files:
        print(f"No GPX files found in '{data_dir}'.")
        return False

    # Load workouts_metadata.json if available
    metadata_map = {}
    metadata_file = os.path.join(data_dir, "workouts_metadata.json")
    if os.path.exists(metadata_file):
        try:
            with open(metadata_file, "r", encoding="utf-8") as f:
                meta_list = json.load(f)
                metadata_map = {w["workoutKey"]: w for w in meta_list if "workoutKey" in w}
            print(f"Loaded metadata for {len(metadata_map)} workouts from '{metadata_file}'.")
        except Exception as e:
            print(f"Warning: Failed to load workout metadata JSON: {e}")

    print(f"Compiling {len(gpx_files)} GPX files into '{output_file}'...")
    compiled_workouts = []

    for i, file_name in enumerate(gpx_files):
        file_path = os.path.join(data_dir, file_name)
        print(f"[{i+1}/{len(gpx_files)}] Parsing {file_name}...")

        # Extract workoutKey from file name (format: YYYYMMDD_HHMMSS_workoutKey.gpx)
        base_name = os.path.splitext(file_name)[0]
        parts = base_name.split("_")
        workout_key = parts[-1] if len(parts) >= 3 else base_name
        meta_workout = metadata_map.get(workout_key)

        try:
            gpx = None
            parse_failed = False
            try:
                with open(file_path, "r", encoding="utf-8") as f:
                    gpx = gpxpy.parse(f)
            except Exception as pe:
                if meta_workout:
                    print(f"  GPX file {file_name} failed to parse ({pe}), using metadata only.")
                    parse_failed = True
                else:
                    raise pe

            # Determine tracks to process
            tracks_to_process = gpx.tracks if (gpx and not parse_failed) else []

            # If GPX failed to parse or contains no tracks, but we have metadata, synthesize a dummy track
            if not tracks_to_process and meta_workout:
                class DummyTrack:
                    def __init__(self, name, sport_type):
                        self.name = name
                        self.type = sport_type
                        self.segments = []
                
                # Determine sport type
                sport_type = "running"
                act_id = meta_workout.get("activityId")
                if act_id is not None:
                    try:
                        sport_type = SPORTS_TRACKER_ACTIVITY_MAP.get(int(act_id), "running")
                    except (ValueError, TypeError):
                        pass

                track_name = (
                    meta_workout.get("description") or
                    meta_workout.get("name") or
                    meta_workout.get("title") or
                    f"Imported {sport_type.capitalize()}"
                )
                tracks_to_process = [DummyTrack(track_name, sport_type)]

            for track in tracks_to_process:
                points_data = []
                sensor_data = []

                if hasattr(track, 'segments') and track.segments:
                    for segment in track.segments:
                        for pt in segment.points:
                            if pt.time is None:
                                continue

                            # Parse Garmin extension fields for Heart Rate if present
                            hr_val = None
                            for ext in pt.extensions:
                                for child in ext.iter():
                                    if "hr" in child.tag or "HeartRate" in child.tag:
                                        try:
                                            hr_val = float(child.text)
                                        except ValueError:
                                            pass

                            timestamp_str = pt.time.astimezone(timezone.utc).isoformat()
                            points_data.append(
                                {
                                    "timestamp": timestamp_str,
                                    "latitude": pt.latitude,
                                    "longitude": pt.longitude,
                                    "altitude": pt.elevation,
                                    "accuracy": None,
                                    "speed": None,  # Computed below
                                }
                            )

                            if hr_val is not None:
                                sensor_data.append(
                                    {
                                        "timestamp": timestamp_str,
                                        "sensorType": "heart_rate",
                                        "value": hr_val,
                                    }
                                )

                # If no points and no metadata, skip
                if not points_data and not meta_workout:
                    continue

                # Ensure telemetry is strictly chronological
                if points_data:
                    points_data.sort(key=lambda x: x["timestamp"])

                # Determine start time
                start_time = None
                if meta_workout and meta_workout.get("startTime") is not None:
                    try:
                        start_time_ms = float(meta_workout.get("startTime"))
                        start_time = datetime.fromtimestamp(start_time_ms / 1000.0, tz=timezone.utc)
                    except (ValueError, TypeError):
                        pass

                if not start_time:
                    if points_data:
                        start_time = datetime.fromisoformat(points_data[0]["timestamp"])
                    else:
                        # Fallback: parse from filename
                        try:
                            date_part = parts[0] + parts[1]
                            start_time = datetime.strptime(date_part, "%Y%m%d%H%M%S").replace(tzinfo=timezone.utc)
                        except Exception:
                            start_time = datetime.now(timezone.utc)

                # Determine duration
                duration_seconds = 0.0
                if meta_workout and (meta_workout.get("duration") is not None or meta_workout.get("totalTime") is not None):
                    try:
                        duration_seconds = float(meta_workout.get("duration") or meta_workout.get("totalTime") or 0.0)
                    except (ValueError, TypeError):
                        pass
                
                if duration_seconds <= 0.0 and points_data:
                    end_time_gpx = datetime.fromisoformat(points_data[-1]["timestamp"])
                    start_time_gpx = datetime.fromisoformat(points_data[0]["timestamp"])
                    duration_seconds = (end_time_gpx - start_time_gpx).total_seconds()

                end_time = start_time + timedelta(seconds=duration_seconds)

                # Determine distance
                distance_meters = 0.0
                if meta_workout and (meta_workout.get("distance") is not None or meta_workout.get("totalDistance") is not None):
                    try:
                        distance_meters = float(meta_workout.get("distance") or meta_workout.get("totalDistance") or 0.0)
                    except (ValueError, TypeError):
                        pass

                # If distance is still 0 and we have GPX points, calculate it from points
                if distance_meters <= 0.0 and points_data:
                    calculated_dist = 0.0
                    for idx in range(len(points_data)):
                        if idx > 0:
                            prev = points_data[idx - 1]
                            curr = points_data[idx]
                            seg_dist = calculate_distance(
                                prev["latitude"],
                                prev["longitude"],
                                curr["latitude"],
                                curr["longitude"],
                            )
                            calculated_dist += seg_dist
                    distance_meters = calculated_dist

                # Speed and elevation calculation for each point (if points exist)
                max_speed = 0.0
                elevation_gain = 0.0
                elevation_loss = 0.0

                if points_data:
                    for idx in range(len(points_data)):
                        if idx > 0:
                            prev = points_data[idx - 1]
                            curr = points_data[idx]
                            
                            seg_dist = calculate_distance(
                                prev["latitude"],
                                prev["longitude"],
                                curr["latitude"],
                                curr["longitude"],
                            )
                            
                            prev_time = datetime.fromisoformat(prev["timestamp"])
                            curr_time = datetime.fromisoformat(curr["timestamp"])
                            time_diff = (curr_time - prev_time).total_seconds()

                            if time_diff > 0:
                                calc_speed = seg_dist / time_diff
                                curr["speed"] = calc_speed
                                if calc_speed > max_speed:
                                    max_speed = calc_speed

                            if (
                                prev["altitude"] is not None
                                and curr["altitude"] is not None
                            ):
                                diff = curr["altitude"] - prev["altitude"]
                                if diff > 0:
                                    elevation_gain += diff
                                else:
                                    elevation_loss += abs(diff)

                # Overwrite max speed from metadata if available
                max_speed_meta = None
                if meta_workout and (meta_workout.get("maxSpeed") is not None or meta_workout.get("peakSpeed") is not None):
                    try:
                        max_speed_meta = float(meta_workout.get("maxSpeed") or meta_workout.get("peakSpeed"))
                    except (ValueError, TypeError):
                        pass

                if max_speed_meta is not None:
                    max_speed = max_speed_meta

                # Heart rate summary stats
                avg_heart_rate = None
                max_heart_rate = None

                if meta_workout and (meta_workout.get("avgHr") is not None or meta_workout.get("averageHeartRate") is not None):
                    try:
                        avg_heart_rate = float(meta_workout.get("avgHr") or meta_workout.get("averageHeartRate"))
                    except (ValueError, TypeError):
                        pass
                if meta_workout and (meta_workout.get("maxHr") is not None or meta_workout.get("maxHeartRate") is not None):
                    try:
                        max_heart_rate = float(meta_workout.get("maxHr") or meta_workout.get("maxHeartRate"))
                    except (ValueError, TypeError):
                        pass

                # Fallback to GPX sensor data if metadata doesn't have it
                if avg_heart_rate is None and sensor_data:
                    hr_values = [s["value"] for s in sensor_data]
                    avg_heart_rate = sum(hr_values) / len(hr_values)
                if max_heart_rate is None and sensor_data:
                    hr_values = [s["value"] for s in sensor_data]
                    max_heart_rate = max(hr_values)

                # Estimate or retrieve Calories
                calories = 0.0
                if meta_workout and (meta_workout.get("energyConsumption") is not None or meta_workout.get("calories") is not None):
                    try:
                        calories = float(meta_workout.get("energyConsumption") or meta_workout.get("calories") or 0.0)
                    except (ValueError, TypeError):
                        pass
                
                if calories <= 0.0:
                    sport_type = parse_sport_type(track.type)
                    met = MET_VALUES.get(sport_type, DEFAULT_MET)
                    calories = met * DEFAULT_WEIGHT_KG * (duration_seconds / 3600.0)

                average_speed = (
                    distance_meters / duration_seconds
                    if duration_seconds > 0
                    else 0.0
                )

                # Determine sport type
                sport_type = "running"
                if meta_workout and meta_workout.get("activityId") is not None:
                    try:
                        act_id = int(meta_workout.get("activityId"))
                        sport_type = SPORTS_TRACKER_ACTIVITY_MAP.get(act_id)
                        if not sport_type:
                            sport_type = parse_sport_type(meta_workout.get("activityName") or str(act_id))
                    except (ValueError, TypeError):
                        sport_type = parse_sport_type(str(meta_workout.get("activityId")))
                elif track and track.type:
                    sport_type = parse_sport_type(track.type)

                # Build name prioritizing GPX descriptions/names and Sports Tracker metadata description
                gpx_desc = getattr(track, 'description', None) or (gpx.description if gpx else None)
                gpx_name = getattr(track, 'name', None) or (gpx.name if gpx else None)

                # Clean strings
                gpx_desc = gpx_desc.strip() if gpx_desc else None
                gpx_name = gpx_name.strip() if gpx_name else None

                meta_desc = meta_workout.get("description").strip() if (meta_workout and meta_workout.get("description")) else None
                meta_name = (meta_workout.get("name") or meta_workout.get("title")) if meta_workout else None
                if meta_name:
                    meta_name = meta_name.strip()

                workout_name = (
                    gpx_desc or
                    meta_desc or
                    meta_name or
                    gpx_name or
                    f"Imported {sport_type.capitalize()}"
                )

                # Build workout JSON node
                workout_json = {
                    "name": workout_name,
                    "sportType": sport_type,
                    "startTime": start_time.isoformat(),
                    "endTime": end_time.isoformat(),
                    "durationSeconds": duration_seconds,
                    "distanceMeters": distance_meters,
                    "averageSpeed": average_speed,
                    "maxSpeed": max_speed if max_speed > 0 else None,
                    "elevationGain": elevation_gain,
                    "elevationLoss": elevation_loss,
                    "averageHeartRate": avg_heart_rate,
                    "maxHeartRate": max_heart_rate,
                    "calories": calories,
                    "isCompleted": True,
                    "gpsPoints": points_data,
                    "sensorData": sensor_data,
                }
                compiled_workouts.append(workout_json)

        except Exception as e:
            print(f"  Error parsing {file_name}: {e}")

    # Build the schema-compliant FitLog import package in JSON Lines (JSONL) format
    # to support streaming and prevent Out of Memory errors on mobile devices.
    with open(output_file, "w", encoding="utf-8") as f:
        # 1. Write the metadata line
        metadata = {
            "type": "metadata",
            "version": 1,
            "exportedAt": datetime.now(timezone.utc).isoformat(),
            "settings": {}
        }
        f.write(json.dumps(metadata) + "\n")
        
        # 2. Write each workout as its own JSON line
        for workout in compiled_workouts:
            workout_line = {
                "type": "workout",
                "data": workout
            }
            f.write(json.dumps(workout_line) + "\n")

    print(f"Compilation finished. Compiled {len(compiled_workouts)} workouts in JSON Lines format in '{output_file}'.")
    return True
