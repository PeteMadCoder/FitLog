"""
Extraction module for Sports Tracker GPX files.
Handles logging in, fetching the workout list, and downloading workouts one by one.
"""

import getpass
import os
import time
from datetime import datetime, timezone
import requests

BASE_URL = "https://api.sports-tracker.com/apiserver/v1"
LOGIN_URL = f"{BASE_URL}/login"
WORKOUTS_URL = f"{BASE_URL}/workouts"
EXPORT_GPX_URL = f"{BASE_URL}/workout/exportGpx"

# Use browser-like headers to avoid CDN / WAF blocking
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    "Accept": "application/json",
}


def get_credentials():
    """Prompt the user for their credentials securely without persisting them."""
    print("=== Sports Tracker Authentication ===")
    email = input("Email: ").strip()
    password = getpass.getpass("Password: ")
    return email, password


def login(email, password):
    """Authenticate with Sports Tracker API (via URL parameters) and return the session key."""
    print("Logging into Sports Tracker...")
    params = {
        "l": "en",
        "u": email,
        "p": password,
    }
    payload = {
        "username": email,
        "password": password,
    }

    try:
        response = requests.post(LOGIN_URL, params=params, json=payload, headers=HEADERS)
        if response.status_code != 200:
            print(f"Login failed: HTTP {response.status_code}")
            try:
                print(f"Server response: {response.text}")
            except Exception:
                pass
            return None

        data = response.json()
        session_key = data.get("sessionkey")
        if not session_key:
            print("Login failed: Session key not found in response.")
            return None

        print("Login successful!")
        return session_key
    except Exception as e:
        print(f"Error during login: {e}")
        return None


def fetch_workout_list(session_key):
    """Fetch the list of all workout metadata from the API."""
    print("Fetching workout list...")
    headers = {**HEADERS, "STTAuthorization": session_key}
    workouts = []
    limit = 100
    offset = 0

    while True:
        params = {"limit": limit, "offset": offset}
        try:
            response = requests.get(WORKOUTS_URL, headers=headers, params=params)
            if response.status_code != 200:
                print(f"Failed to fetch workouts: HTTP {response.status_code}")
                break

            batch = response.json().get("payload", [])
            if not batch:
                break

            workouts.extend(batch)
            print(f"Retrieved {len(workouts)} workout summaries...")
            if len(batch) < limit:
                break

            offset += limit
        except Exception as e:
            print(f"Error fetching workouts list: {e}")
            break

    return workouts


def download_gpx_files(session_key, workouts, data_dir):
    """Download GPX files for all workouts that are not already cached."""
    os.makedirs(data_dir, exist_ok=True)
    headers = {**HEADERS, "STTAuthorization": session_key}
    download_count = 0

    print(f"Starting extraction of {len(workouts)} workouts into '{data_dir}' folder...")
    for i, workout in enumerate(workouts):
        workout_key = workout.get("workoutKey")
        if not workout_key:
            continue

        # Use activity date/time or key to name the file
        start_time_ms = workout.get("startTime")
        if start_time_ms:
            # Handle timestamps in milliseconds, converting safely to UTC datetime
            dt = datetime.fromtimestamp(start_time_ms / 1000.0, tz=timezone.utc)
            date_str = dt.strftime("%Y%m%d_%H%M%S")
        else:
            date_str = "workout"

        file_name = f"{date_str}_{workout_key}.gpx"
        file_path = os.path.join(data_dir, file_name)

        if os.path.exists(file_path):
            # Already cached
            continue

        print(f"[{i+1}/{len(workouts)}] Downloading GPX for workout {workout_key}...")
        try:
            url = f"{EXPORT_GPX_URL}/{workout_key}"
            response = requests.get(url, headers=headers)
            if response.status_code == 200:
                with open(file_path, "wb") as f:
                    f.write(response.content)
                download_count += 1
                # Delay slightly to prevent rate limits
                time.sleep(1.0)
            else:
                print(f"  Failed to download {workout_key}: HTTP {response.status_code}")
        except Exception as e:
            print(f"  Error downloading {workout_key}: {e}")

    print(f"Extraction completed. Downloaded {download_count} new GPX files.")


def run_extraction(data_dir):
    """Executes the full extraction process by prompting for credentials, logging in, and downloading GPX files."""
    email, password = get_credentials()
    if not email or not password:
        print("Credentials cannot be empty.")
        return False

    session_key = login(email, password)
    if not session_key:
        return False

    workouts = fetch_workout_list(session_key)
    if not workouts:
        print("No workouts found on account or failed to retrieve.")
        return False

    download_gpx_files(session_key, workouts, data_dir)
    return True
