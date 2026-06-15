# FitLog Project Roadmap


## Phase 1: Foundation & Infrastructure

- [x] **1.1. Project Initialization & Cleanup**
    - Remove Flutter boilerplate (counter app).
    - Configure `pubspec.yaml` with all fixed dependencies (Riverpod, Isar, flutter_map, etc.).
    - Create the directory structure as defined in `GEMINI.md` (app, core, data, features, shared).
- [x] **1.2. Core Result Type & Error Handling**
    - Implement a `Result<T, E>` or `Either` type in `lib/core/errors/` to handle failures without exceptions.
    - Create basic `AppException` classes.
- [x] **1.3. Isar Database Setup**
    - Define initial Isar schemas in `lib/features/tracking/models/` (`Workout`, `GpsPoint`, `SensorData`).
    - Create an `IsarProvider` in `lib/app/app_providers.dart` that initializes the database singleton.
- [x] **1.4. App Theme & Navigation Shell**
    - Define `AppTheme` (Light/Dark) in `lib/app/app_theme.dart`.
    - Implement the `MainNavigationShell` with a `BottomNavigationBar` linking the 5 core modules (Home, Tracker, Maps, Diary, Stats).

---

## Phase 2: The Tracking Engine (Core Feature)

- [x] **2.1. Permission Service**
    - Implement `PermissionService` in `lib/core/permissions/` to handle Location (Background/Always) and Bluetooth permissions.
- [x] **2.2. GPS Service**
    - Implement a service using the `location` package to stream `GpsPoint` data.
    - Ensure it handles background execution properly.
- [x] **2.3. Live Tracking Notifier (Riverpod)**
    - Create `TrackingNotifier` using `@riverpod`.
    - Logic for: Start, Pause, Resume, Stop.
    - Accumulate `GpsPoint` objects in state during recording.
- [x] **2.4. Live Map View**
    - Implement `ActiveWorkoutScreen` in `features/tracking/views/`.
    - Use `flutter_map` to show the user's current position and the breadcrumb trail (polyline).
- [x] **2.5. Real-time Metrics Display**
    - Create widgets to show Duration, Distance, and Current Speed during the workout.
    - Implement a basic `PaceCalculator` utility in `lib/core/utils/`.

---

## Phase 3: Persistence & Analysis

- [x] **3.1. Save Workout Logic**
    - Implement the "Stop & Save" flow.
    - Persist the `Workout` and its related `GpsPoint` list to Isar.
- [x] **3.2. Post-Workout Summary Screen**
    - Create `WorkoutDetailScreen` in `features/analytics/views/`.
    - Display a static map of the route and a grid of summary metrics (Total distance, Avg speed, Elevation gain).
- [x] **3.3. Basic Charts**
    - Use `fl_chart` to show an Elevation vs. Distance graph.
    - Show a Speed/Pace over time graph.
- [x] **3.4. Lap/Split Logic**
    - Implement service to automatically calculate 1km splits from a list of GpsPoints.
    - Display a "Laps" table in the detail screen.

---

## Phase 4: Diary & History

- [x] **4.1. Workout History List**
    - Create a provider to stream all workouts from Isar sorted by date.
    - Implement a list view with cards showing workout summaries.
- [ ] **4.2. Calendar View**
    - Implement a calendar-based grid in `features/diary/views/`.
    - Highlight days with activities (using dots or heat indicators).
- [ ] **4.3. Statistics Dashboard**
    - Aggregate data (total distance, time, calories) across different timeframes (Weekly, Monthly, Yearly).

---

## Phase 5: Advanced Features (The "Sports Tracker" Killer)

- [ ] **5.1. Auto-Pause Logic**
    - Implement the `AutoPauseService` that triggers pause/resume based on speed thresholds (e.g., < 0.5 m/s).
- [ ] **5.2. Voice Feedback**
    - Use `flutter_tts` to announce distance and pace at configurable intervals (e.g., every 1km).
- [ ] **5.3. BLE Sensor Integration**
    - Implement `BleSensorService` using `flutter_blue_plus`.
    - Support Heart Rate monitors and store HR data alongside GPS points.
- [ ] **5.4. Ghost Target (The Race)**
    - Implement the algorithm to align a past workout's points with the current live workout by distance.
    - Create a UI overlay to show "Ahead/Behind" status.

---

## Phase 6: Data Portability & Polish

- [ ] **6.1. GPX/TCX Export**
    - Create a service to serialize Isar data into GPX 1.1 XML format.
    - Use `Share` package to allow exporting the file to other apps.
- [ ] **6.2. GPX Import**
    - Implement a parser to read external GPX files and convert them into FitLog `Workout` objects.
- [ ] **6.3. Local Backup & Restore**
    - Implement a "Full Database Export" (copying the Isar file) for manual backup.
- [ ] **6.4. Final UI/UX Polish**
    - Ensure all strings are localized (i18n).
    - Add "Empty States" for when the user has no workouts.
    - Implement custom icons and splash screen.
