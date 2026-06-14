# FitLog – AI Coding Standards & Guidelines

## 1. Core Principles (For AI & Human Developer)

- **Offline‑first & zero cloud** – Never assume network availability. Do not add `http` calls, Firebase, or any form of remote sync. All user data is persisted **only** on the device.
- **Local‑only by physics** – Privacy is guaranteed by the absence of data transmission. No analytics, crash reporting, or third‑party SDKs that phone home (except map tiles – see 4.4).
- **Performance first** – Fitness tracking runs on the CPU continuously. Avoid blocking the UI thread. Use `compute()` for heavy parsing (GPX, TCX) and background isolates if needed.
- **Resilience** – Because there is no cloud, implement robust import/export, automatic backups, and crash recovery.

## 2. Technology Stack (Fixed)

| Area               | Choice                                                                 |
| ------------------ | ---------------------------------------------------------------------- |
| **Framework**      | Flutter (latest stable) + Dart (sound null safety)                     |
| **State Mgmt**     | [Riverpod](https://riverpod.dev) (using `@riverpod` code generation)   |
| **Local DB**       | [Isar](https://isar.dev) (high performance, offline‑first, typed)      |
| **Map Tiles**      | `flutter_map` + vector tiles (e.g., `vector_map_tiles`) – online only  |
| **GPS**            | `location` (with background permission)                                |
| **BLE Sensors**    | `flutter_blue_plus`                                                    |
| **Charting**       | `fl_chart`                                                             |
| **File parsing**   | `xml` (for GPX/TCX) + `path_provider` + `file_picker`                  |
| **Code Gen**       | `build_runner` + Riverpod generator + Isar generator                   |

## 3. Project Structure

```
lib/
├── main.dart                         # App entry, providers setup
├── app/                              # App‑wide configuration
│   ├── app_providers.dart            # Global providers (DB, settings)
│   └── app_theme.dart                # Light/dark theme
├── core/                             # Truly reusable utilities
│   ├── errors/                       # Custom exceptions, result types
│   ├── permissions/                  # Permission request helpers
│   ├── storage/                      # Isar box init, migration logic
│   └── utils/                        # Date helpers, math (MET, pace calc)
├── features/                         # Feature‑based modules
│   ├── tracking/                     # Live workout recording
│   │   ├── models/                   # WorkoutData, GpsPoint, SensorData
│   │   ├── providers/                # TrackingProvider, GPSProvider, BLEProvider
│   │   ├── views/                    # ActiveWorkoutScreen, widgets
│   │   └── services/                 # GPX recorder, auto‑pause logic
│   ├── analytics/                    # Post‑workout charts & stats
│   │   ├── providers/                # WorkoutAnalysisProvider
│   │   ├── views/                    # WorkoutDetailScreen, LapBreakdown
│   │   └── services/                 # MET calculator, elevation gain
│   ├── diary/                        # Calendar & workout history
│   │   ├── models/                   # DiaryEntry (summary)
│   │   ├── providers/                # DiaryProvider
│   │   └── views/                    # CalendarView, MonthGrid
│   ├── ghosts/                       # Ghost Target feature
│   │   ├── providers/                # GhostComparisonProvider
│   │   └── services/                 # Alignment of past vs live route
│   ├── heatmaps/                     # Personal heatmap
│   │   ├── providers/                # HeatmapTileProvider
│   │   └── views/                    # HeatmapOverlay
│   └── backup/                       # Import/export
│       ├── services/                 # GPX/TCX parser, exporter
│       └── views/                    # BackupSettingsScreen
├── shared/                           # Cross‑feature widgets & helpers
│   ├── widgets/                      # Custom buttons, loaders, dialogs
│   ├── providers/                    # Shared providers (e.g., settings)
│   └── extensions/                   # Dart extensions (e.g., Duration formatting)
└── generated/                        # Codegen output (do not edit manually)
```

## 4. Code & Style Conventions

### 4.1 Dart Style
- Follow official [Dart style guide](https://dart.dev/guides/language/effective-dart/style).
- **Formatting**: Use `dart format` with default line length (80).
- **Naming**:
  - Classes: `UpperCamelCase`
  - Variables, methods, parameters: `lowerCamelCase`
  - Constants: `lowerCamelCase` (avoid `SCREAMING_SNAKE` except for truly global constants)
  - Private members: prefix with `_`
- **Imports**: Use `package:fitlog/...` absolute imports. Group: `dart:` → `package:flutter` → external packages → internal `package:fitlog`.

### 4.2 Riverpod Usage
- Always use **code‑generated providers** (`@riverpod` annotation).
- Keep providers **testable** – inject dependencies via ref.watch/read.
- Never instantiate `ProviderContainer` manually except in tests.
- Prefer `AsyncNotifier` for state that requires async initialisation (e.g., DB loading).

```dart
// Good
@riverpod
class TrackingNotifier extends _$TrackingNotifier {
  @override
  Future<TrackingState> build() async { ... }
  Future<void> startWorkout() async { ... }
}

// Avoid manual Provider classes
```

### 4.3 Isar Database
- Define schemas as `@collection` classes inside `models/`.
- Use `Isar` as a **singleton** – provide it via a Riverpod provider.
- Keep queries close to the UI: expose streams via Riverpod (`ref.watch(workoutStreamProvider(id))`).
- Never use `Isar` directly inside UI widgets – always go through a provider or service.

### 4.4 Map Tiles & Offline
- `flutter_map` tiles are the **only** feature needing internet. Document this clearly.
- Cache tiles locally using `cached_network_image` or tile provider caching, but do **not** implement full offline map download unless specified.
- The GPS route is always recorded locally – map is just a visual layer.

### 4.5 Error Handling
- Use custom `Result<T, E>` type (or `Either`) for expected failures (e.g., permission denied, parse error).
- Unexpected errors should be caught at the UI boundary and shown with a user‑friendly message.
- Log errors to `debugPrint` only – no remote logging.

### 4.6 Concurrency & Performance
- Heavy computations (parsing GPX, calculating heatmap) → `compute()` or `Isolate`.
- Avoid `async` in `build()` – use `FutureBuilder` or Riverpod's `.when()`.
- Use `const` constructors for static widgets.
- Keep rebuild granular: watch only the specific provider fields needed.

## 5. AI‑Specific Interaction Instructions

When you, the AI, are asked to write or modify code for FitLog, you must:

1. **Never introduce cloud dependencies** – Reject any suggestion that adds `http`, Firebase, AWS, or any remote sync. If the user asks for “sync”, remind them it’s forbidden.
2. **Assume offline environment** – All features must work without internet (except map tiles). Test for missing network gracefully.
3. **Write tests with every feature** – At minimum a unit test for business logic (e.g., pace calculation) and a widget test for critical user flows.
4. **Use existing architecture** – Follow the folder structure, Riverpod + Isar pattern. If unsure, ask or deduce from similar existing files.
5. **Document your reasoning** – When you choose an algorithm (e.g., “ghost alignment”) or a performance optimisation, add a comment explaining why.
6. **Add TODO markers** – If a task is incomplete (e.g., BLE reconnection logic), write `// TODO(AI): ...` with a clear description.
7. **Provide runnable code** – All code snippets must be complete: include needed imports, proper `@riverpod` annotations, and correct `part` files.
8. **Respect privacy** – Never ask the user to grant unnecessary permissions. Request location, BLE, and notifications only when the feature is about to be used.

## 6. Key Functional Guidelines (For AI Reference)

### 6.1 GPS Tracking
- Use `location` package with `AndroidSettings` / `iOSSettings` for optimal battery/power trade‑off.
- Record points every 1 second or every 5 meters, whichever is more frequent.
- Store each `GpsPoint` (timestamp, lat, lng, alt, accuracy, speed) in Isar as a separate object linked to a `Workout`.
- Implement auto‑pause when speed drops below 0.5 m/s for >5 seconds.

### 6.2 BLE Sensors
- Use `flutter_blue_plus` to scan and connect to heart rate (HR) and cadence sensors.
- Support standard GATT services: Heart Rate (0x180D), Cycling Cadence (0x1816).
- Store sensor data interleaved with GPS points (same timestamp).

### 6.3 Ghost Target
- Load a past workout route from Isar.
- Align it with current position using **time‑normalised distance** (not absolute time).
- Display ghost as a semi‑transparent line ahead/behind on the map.
- Provide audio feedback when ghost is overtaken or falling behind.

### 6.4 Import / Export
- Support GPX **1.0 and 1.1**, TCX **2.0**.
- On import: validate, show preview (date, distance, duration), then save to Isar.
- On export: allow user to select a single workout or entire history, choose format, and share to Files / other apps.

## 7. Testing Requirements

- **Unit tests** (`test/unit/`): Algorithms (MET, pace, elevation gain), parsers, auto‑pause logic.
- **Widget tests** (`test/widget/`): Each major screen (active workout, diary, import/export) with mocked providers.
- **Integration test** (`integration_test/`): A full fake workout recording + import/export cycle using `IntegrationTestWidgetsFlutterBinding`.
- Coverage target: >80% for core business logic (`lib/features/*/services` and `lib/core/utils`).

## 8. Documentation & Comments

- Every public method and class must have a `///` doc comment explaining its purpose.
- For complex algorithms (e.g., elevation smoothing, ghost alignment), include a short ASCII diagram or reference to a known paper.
- Keep `README.md` updated with setup steps, build instructions, and a privacy statement (“zero data leaves the device”).

## 9. Version Control & AI Workflow

- The AI should never commit directly – it provides code changes.
- Use conventional commits: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`.
- Keep PRs small (max 400 lines changed) – ask AI to break large features into multiple steps.
- Always run `dart format .` and `flutter analyze` before submitting code.

---

**Last updated**: 2026‑06‑14  
**Applies to**: All AI‑generated code for FitLog.  
**When in doubt, ask first, then prioritise privacy, offline operation, and user ownership of data.**