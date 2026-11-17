# REBS HRMS

A Flutter employee workspace for Android and iOS with attendance, leave applications and offline support.

## Setup

Use a Flutter SDK compatible with Dart `^3.9.2`. Start an Android emulator or iOS simulator, then run these commands from the project root.

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Start the mock API

```bash
dart run tool/mock_api.dart
```

Keep this terminal running. The Dart server listens on port `8080` and stores attendance and leave data in JSON files under `.dart_tool/mock_api/`. Press `Ctrl+C` to stop it. Restart with the same storage files to retain data.

### 3. Run the app

Open another terminal in the project root:

```bash
flutter run
```

Default server addresses:

| Device | Address |
| --- | --- |
| Android Emulator | `http://10.0.2.2:8080` |
| iOS Simulator | `http://127.0.0.1:8080` |

For a physical device, connect it and the computer to the same Wi-Fi and use the computer's LAN address:

```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_COMPUTER_IP:8080
```

### Location configuration

The default office is at latitude **12.9716**, longitude **77.5946**, with a **200-metre** attendance radius. In the emulator's Location controls, select these coordinates and apply the location before checking in. Allow location permission when prompted.

To use different office coordinates or a company timezone, stop the server and restart it with:

```bash
dart run tool/mock_api.dart --office-lat=12.9716 --office-lng=77.5946 --timezone=Asia/Kolkata
```

Refresh the app after changing office configuration.

### Mock scenarios

```bash
dart run tool/mock_api.dart --scenario=slow
```

Available scenarios: `success`, `empty`, `slow`, `timeout`, `server-error`, `duplicate-attendance`, `timeout-after-accept`, `invalid-response` and `leave-validation-rejection`.

## Architecture and folder structure

The project uses feature-based architecture with Provider state management. Controllers manage actions and state; services handle API access, validation and storage. Reusable UI components are separate stateless widgets.

```text
lib/
├── main.dart
├── app/
│   └── app.dart              # App configuration and Provider registration
├── core/
│   ├── config/               # API address and request configuration
│   ├── constants/            # Centralized interface text
│   ├── helpers/              # Colors, company dates and location calculations
│   ├── network/              # HTTP client, errors and connectivity
│   ├── storage/              # Hive initialization and adapter registration
│   ├── theme/                # Shared app theme
│   └── widgets/              # Shared reusable widgets
└── features/
    ├── attendance/
    │   ├── controllers/
    │   ├── models/
    │   ├── screens/
    │   ├── services/
    │   ├── states/
    │   └── widgets/
    ├── dashboard/            # Employee details and daily summary
    ├── leave/                # Applications, balances and request history
    └── workspace/            # App shell and section navigation

tool/
├── mock_api.dart             # Local HTTP server
└── services/                 # Mock attendance and leave processing

test/                        # Unit, API, persistence and widget tests
```

Dashboard and leave use the same feature folders shown for attendance. Workspace contains controllers, screens, states and widgets.

## Packages

| Package | Purpose |
| --- | --- |
| `provider` | State management |
| `http` | HTTP requests to the mock API |
| `hive`, `hive_flutter` | Local storage and Flutter initialization |
| `geolocator` | GPS coordinates and location permissions |
| `connectivity_plus` | Network connectivity changes |
| `uuid` | Unique attendance event and leave request IDs |
| `timezone` | Company timezone calculations |
| `intl` | Date and duration formatting |
| `hive_generator`, `build_runner` | Generate Hive model adapters |
| `flutter_test` | Automated tests |
| `flutter_lints` | Dart and Flutter code analysis rules |

Generated adapters are included in the source. After changing annotated models, regenerate them with:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Assumptions

- One preconfigured employee; no login or manager approval flow.
- One attendance session per company calendar day, with no overnight checkout. Attendance is available on any day because no working-day calendar is configured.
- Company dates use the office timezone; timestamps are stored in UTC.
- Leave includes all calendar days. Pending and Approved requests reserve balance and block overlaps; Rejected requests do not.

## Completed features

- Employee dashboard with attendance summary, leave balance and recent records.
- GPS check-in/out with office-radius validation, permission handling and duplicate-tap protection.
- Cached offline data, persistent attendance events, Sync Now and automatic ordered synchronization with safe retries.
- Leave applications with local/server validation and cached request history.
- Responsive layouts, reusable widgets and loading, empty and error states.
