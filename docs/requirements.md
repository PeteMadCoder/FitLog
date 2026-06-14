# FitLog Requirements

FitLog is designed as a **fully free, open-source alternative** to premium fitness tracking apps like Sports Tracker. It focuses on privacy, high-performance tracking, and providing advanced features without paywalls.

## 1. Core Philosophy
*   **Local-Only:** All data is stored exclusively on the user's device. There is no cloud backend, account requirement, or remote tracking.
*   **Offline-First:** Every feature (excluding initial map tile downloads) must function without an internet connection. Calculations for distance, pace, elevation, and analysis are performed on-device.
*   **No Paywalls:** All features, including advanced analytics and sensor support, are free and unlocked.
*   **Privacy by Design:** Since no data leaves the device, user privacy is guaranteed by architecture rather than just policy.
*   **Extensibility:** Support for industry-standard formats (GPX, TCX, FIT) for manual backup and data portability.

---

## 2. App Architecture & Navigation
The app uses a persistent bottom navigation bar for quick access to core modules:
1.  **Home (Dashboard):** Immediate overview of recent activities and progress.
2.  **Training Zone:** The hub for starting and configuring new activities.
3.  **Map / Routes:** Explore local heatmaps and previously tracked routes.
4.  **Diary / Calendar:** Historical view of all activities.
5.  **Profile / Stats:** Long-term analytics and user settings.

---

## 3. Features Detail

### 3.1. Main Dashboard
*   **Last Workout:** Quick view of the most recent activity (Type, Distance, Duration).
*   **Weekly/Monthly Progress:** Visual progress bars grouping activities by type.
*   **Consistency Heatmap:** A "GitHub-style" or dot-based calendar glance showing active days.
*   **Quick Actions:** Large "Start Activity" button and "Log Manual Activity" option.

### 3.2. Activity Tracking (GPS & Sensors)
*   **Multi-Sport Support:** Optimized tracking for Running, Cycling, Walking, Hiking, Indoor Training, etc.
*   **Live Metrics:** Real-time display of:
    *   Duration, Distance, Current Speed, Average Speed.
    *   Altitude (Current, Gain, Loss).
    *   Heart Rate (via external sensors).
    *   Cadence/Steps.
*   **Interactive Map:** Real-time breadcrumb trail on a live map with orientation support.
*   **In-Activity Controls:**
    *   **Auto-Pause:** Configurable thresholds (e.g., pause when < 2km/h).
    *   **Laps/Splits:** Manual or auto-lap (e.g., every 1km).
    *   **Voice Feedback:** Configurable audio announcements for distance, time, and pace.
    *   **Photo Integration:** Take photos within the tracking screen; geotag them to the route.
*   **Ghost Target:** Set a previous activity or a custom pace as a "ghost" to compete against in real-time.

### 3.3. Post-Activity Analysis
*   **Static Summary Map:** High-resolution map with the complete route path.
*   **Metrics Grid:** Detailed breakdown including Calories, TSS (Training Stress Score), METs, and elevation profiles.
*   **Interactive Charts:** Synchronized graphs for Speed vs. Altitude, Heart Rate vs. Pace, etc.
*   **Lap Breakdown:** Detailed table of every segment/lap with specific performance data.
*   **Achievements:** Automatic detection of Personal Bests (Fastest KM, Longest Distance, etc.).

### 3.4. Diary & History
*   **Calendar View:** Filterable by month/year; highlights days with multiple workouts.
*   **Search & Filter:** Find activities by name, type, date range, or specific tags.
*   **Batch Editing:** Ability to update or delete multiple activities at once.

### 3.5. Routes & Discovery
*   **Route Planning:** Basic tool to draw or follow a path on the map.
*   **Heatmaps:** Visualize your most frequent routes over time.
*   **GPX Import/Export:** Full support for importing external routes or exporting your own for use in other devices.

### 3.6. Statistics & Long-term Analytics
*   **Global Totals:** Lifetime distance, time, and calories.
*   **Trend Analysis:** Graphs showing progress over weeks/months/years (e.g., "Monthly Running Volume").
*   **Shoe/Gear Tracker:** Track mileage on specific equipment to know when to replace it.

---

## 4. Technical & Advanced Requirements

### 4.1. Sensor Integration
*   **Bluetooth LE Support:** Support for heart rate monitors, cycling speed/cadence sensors, and power meters.
*   **Wearable Sync:** Integration with Android Wear OS / Apple Watch for secondary display and sensor input.

### 4.2. Offline Capabilities
*   **Offline Maps:** Ability to download map tiles for specific regions to track without data.
*   **Local Processing:** All distance and elevation calculations performed on-device to ensure privacy and offline reliability.

### 4.3. Data & Migration
*   **Backup & Restore:** Simple local backup to a single file.
*   **Sports Tracker Migration:** Tool to import data exported from Sports Tracker (and other major platforms like Strava).

### 4.4. Configuration (Settings)
*   **User Profile:** Age, Weight, Height, Gender (used for calorie and MET calculations).
*   **Unit Customization:** Metric vs. Imperial toggle.
*   **Privacy Zones:** Ability to hide start/end locations (e.g., around home) when sharing maps.
