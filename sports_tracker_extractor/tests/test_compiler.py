import os
import json
import tempfile
import unittest
import math
from datetime import datetime, timezone

from compiler import calculate_distance, parse_sport_type, compile_gpx_to_json


class TestCompiler(unittest.TestCase):
    def test_calculate_distance(self):
        # NY to NY should be 0
        self.assertEqual(calculate_distance(40.7128, -74.0060, 40.7128, -74.0060), 0.0)

        # NY to LA (approx 3936 km)
        distance = calculate_distance(40.7128, -74.0060, 34.0522, -118.2437)
        self.assertTrue(3900000 < distance < 4000000)

        # 0.001 degree latitude change (approx 111 meters)
        distance_lat = calculate_distance(40.7128, -74.0060, 40.7138, -74.0060)
        self.assertTrue(110 < distance_lat < 112)

    def test_parse_sport_type(self):
        self.assertEqual(parse_sport_type("Cycling"), "cycling")
        self.assertEqual(parse_sport_type("Mountain Biking"), "cycling")
        self.assertEqual(parse_sport_type("biking"), "cycling")
        self.assertEqual(parse_sport_type("hike"), "hiking")
        self.assertEqual(parse_sport_type("hiking"), "hiking")
        self.assertEqual(parse_sport_type("walk"), "walking")
        self.assertEqual(parse_sport_type("swimming"), "swimming")
        self.assertEqual(parse_sport_type(None), "running")
        self.assertEqual(parse_sport_type("   Running   "), "running")

    def test_compile_gpx_to_json(self):
        # Create a temporary directory for tests
        with tempfile.TemporaryDirectory() as temp_dir:
            # Create a simple test GPX file
            gpx_content = """<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="Test" xmlns="http://www.topografix.com/GPX/1/1">
  <trk>
    <name>Test Running Workout</name>
    <type>Running</type>
    <trkseg>
      <trkpt lat="40.7128" lon="-74.0060">
        <ele>10.0</ele>
        <time>2026-06-29T10:00:00Z</time>
      </trkpt>
      <trkpt lat="40.7138" lon="-74.0060">
        <ele>12.0</ele>
        <time>2026-06-29T10:00:10Z</time>
      </trkpt>
    </trkseg>
  </trk>
</gpx>
"""
            gpx_file_path = os.path.join(temp_dir, "20260629_100000_testkey.gpx")
            with open(gpx_file_path, "w", encoding="utf-8") as f:
                f.write(gpx_content)

            output_json_path = os.path.join(temp_dir, "workouts_import.json")

            # Compile the GPX to JSON
            success = compile_gpx_to_json(temp_dir, output_json_path)
            self.assertTrue(success)
            self.assertTrue(os.path.exists(output_json_path))

            # Read and verify the compiled JSON (JSON Lines format)
            with open(output_json_path, "r", encoding="utf-8") as f:
                lines = f.readlines()

            self.assertEqual(len(lines), 2)

            # Line 1: Metadata
            meta_data = json.loads(lines[0])
            self.assertEqual(meta_data["type"], "metadata")
            self.assertEqual(meta_data["version"], 1)

            # Line 2: Workout data
            workout_entry = json.loads(lines[1])
            self.assertEqual(workout_entry["type"], "workout")
            workout_data = workout_entry["data"]

            self.assertEqual(workout_data["name"], "Test Running Workout")
            self.assertEqual(workout_data["sportType"], "running")
            self.assertEqual(workout_data["startTime"], "2026-06-29T10:00:00+00:00")
            self.assertEqual(workout_data["endTime"], "2026-06-29T10:00:10+00:00")
            self.assertEqual(workout_data["durationSeconds"], 10.0)
            self.assertAlmostEqual(workout_data["elevationGain"], 2.0)
            self.assertAlmostEqual(workout_data["elevationLoss"], 0.0)
            self.assertTrue(workout_data["isCompleted"])

            # Check that GPS points are mapped
            self.assertEqual(len(workout_data["gpsPoints"]), 2)
            self.assertEqual(workout_data["gpsPoints"][0]["latitude"], 40.7128)
            self.assertEqual(workout_data["gpsPoints"][1]["latitude"], 40.7138)


if __name__ == "__main__":
    unittest.main()
