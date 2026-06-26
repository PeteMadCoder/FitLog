"""
Compilation module for Sports Tracker GPX files.
Parses downloaded GPX files and calculates workout metrics to generate a JSON file
compatible with the FitLog import schema.
"""

import json
import math
import os
from datetime import datetime, timezone
import gpxpy

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

    print(f"Compiling {len(gpx_files)} GPX files into '{output_file}'...")
    compiled_workouts = []

    for i, file_name in enumerate(gpx_files):
        file_path = os.path.join(data_dir, file_name)
        print(f"[{i+1}/{len(gpx_files)}] Parsing {file_name}...")

        try:
            with open(file_path, "r", encoding="utf-8") as f:
                gpx = gpxpy.parse(f)

            for track in gpx.tracks:
                points_data = []
                sensor_data = []

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

                if not points_data:
                    continue

                # Ensure telemetry is strictly chronological
                points_data.sort(key=lambda x: x["timestamp"])

                # Compute performance aggregates
                start_time = datetime.fromisoformat(points_data[0]["timestamp"])
                end_time = datetime.fromisoformat(points_data[-1]["timestamp"])
                duration_seconds = (end_time - start_time).total_seconds()

                distance_meters = 0.0
                elevation_gain = 0.0
                elevation_loss = 0.0
                max_speed = 0.0

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
                        distance_meters += seg_dist

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

                # Heart rate summary stats
                avg_heart_rate = None
                max_heart_rate = None
                if sensor_data:
                    hr_values = [s["value"] for s in sensor_data]
                    avg_heart_rate = sum(hr_values) / len(hr_values)
                    max_heart_rate = max(hr_values)

                # Estimate Calories using MET values
                sport_type = parse_sport_type(track.type)
                met = MET_VALUES.get(sport_type, DEFAULT_MET)
                calories = met * DEFAULT_WEIGHT_KG * (duration_seconds / 3600.0)

                average_speed = (
                    distance_meters / duration_seconds
                    if duration_seconds > 0
                    else 0.0
                )

                # Build workout JSON node
                workout_json = {
                    "name": track.name or f"Imported {sport_type.capitalize()}",
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

    # Build the schema-compliant FitLog import package
    export_structure = {
        "version": 1,
        "exportedAt": datetime.now(timezone.utc).isoformat(),
        "workouts": compiled_workouts,
    }

    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(export_structure, f, indent=2)

    print(f"Compilation finished. Compiled {len(compiled_workouts)} workouts in '{output_file}'.")
    return True
