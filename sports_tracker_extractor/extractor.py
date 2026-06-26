"""
Extraction module for Sports Tracker GPX files.
Handles logging in via Playwright to extract the session cookie,
fetching the workout list, and downloading workouts one by one.
"""

import getpass
import os
import time
from datetime import datetime, timezone
import requests
from playwright.sync_api import sync_playwright

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
    """Authenticate with Sports Tracker via Playwright to extract the sessionkey cookie."""
    print("Launching browser via Playwright...")
    try:
        with sync_playwright() as p:
            try:
                # Launch a headless chromium browser
                browser = p.chromium.launch(headless=False)
            except Exception as e:
                error_str = str(e).lower()
                if "executable doesn't exist" in error_str or "playwright install" in error_str:
                    print("\n[ERROR] Playwright browser binaries not found.")
                    print("Please install them inside your active virtual environment by running:")
                    print("  playwright install chromium")
                    print("Or if running from outside: python3 -m playwright install chromium\n")
                raise e

            context = browser.new_context(
                viewport={"width": 1280, "height": 800},
                user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
            )
            page = context.new_page()
            
            print("Navigating to Sports Tracker login page...")
            page.goto("https://www.sports-tracker.com/login#reject-all", wait_until="networkidle")
            
            print("Entering credentials...")
            email_input = page.locator('#username')
            password_input = page.locator('#password')
            
            email_input.wait_for(state="visible", timeout=10000)
            email_input.fill(email)
            password_input.fill(password)
            
            print("Clicking login button...")
            submit_button = page.locator('input[type="submit"]')
            submit_button.click()
            
            print("Waiting for login authorization to complete...")
            session_key = None
            for _ in range(25):  # Loop for up to 25 seconds
                cookies = context.cookies()
                for cookie in cookies:
                    if cookie["name"] == "sessionkey":
                        session_key = cookie["value"]
                        break
                if session_key:
                    break
                time.sleep(1.0)
            
            browser.close()
            
            if session_key:
                print("Login successful! Session key extracted.")
                return session_key
            else:
                print("Login failed: sessionkey cookie was not found in browser cookies after login attempt.")
                return None
    except Exception as e:
        print(f"Error during Playwright login: {e}")
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
                time.sleep(0.1)
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

    # Save the workout metadata list to workouts_metadata.json
    os.makedirs(data_dir, exist_ok=True)
    metadata_file_path = os.path.join(data_dir, "workouts_metadata.json")
    try:
        import json
        with open(metadata_file_path, "w", encoding="utf-8") as f:
            json.dump(workouts, f, indent=2)
        print(f"Saved workout metadata list to '{metadata_file_path}'.")
    except Exception as e:
        print(f"Error saving workout metadata list: {e}")

    download_gpx_files(session_key, workouts, data_dir)
    return True
