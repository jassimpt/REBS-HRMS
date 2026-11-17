# REBS HRMS

An employee workspace for Android and iOS, built with Flutter and Provider.

## Current checkpoint

Implemented: responsive workspace navigation, employee dashboard, company-time attendance summary, latest five attendance records, leave balances, loading/error/empty states, pull-to-refresh, persistent offline dashboard viewing, and GPS attendance check-in/check-out.

Pending: automatic/manual attendance synchronization, leave application/history, remaining assignment tests, final APK, and demonstration video. Leave remains a placeholder. This checkpoint saves offline attendance durably and attempts each new event once; pending retries and reconnect processing belong to the next checkpoint.

## Run locally

```bash
flutter pub get
dart run tool/mock_api.dart
```

Keep the mock API terminal running, then start the app from VS Code or another terminal:

```bash
flutter run
```

Android Emulator uses `http://10.0.2.2:8080`; iOS Simulator uses `http://127.0.0.1:8080`. For a physical device, use the computer's LAN address on the same network:

```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_COMPUTER_IP:8080
```

Allow the local-network prompt on iOS. Android debug builds permit local HTTP traffic. Release deployment should use HTTPS. After adding native plugins, stop and rebuild the VS Code debug session once; hot reload alone cannot register them.

## Mock API

The API uses real HTTP; fixture data lives in `tool/mock_api.dart`, never in widgets. No REBS credentials are needed. The sample employee is Aarav Menon, REBS-1042, Engineering. Casual and sick balances are 8 and 5 days.

| Endpoint | Current purpose |
| --- | --- |
| `GET /employee/me` | Employee, office coordinates, 200-metre radius and company timezone |
| `GET /attendance?limit=5` | Latest attendance sessions, newest first |
| `GET /attendance?month=YYYY-MM&limit=100` | Optional month filtering |
| `POST /attendance/events` | Submit a GPS attendance event using a permanent event ID |
| `GET /leave/balance` | Available casual and sick days |
| `GET /health` | Current mock scenario |
| `POST /mock/scenario` | Switch demonstration scenarios without restarting |

The optional `limit` query allows the dashboard's five recent records to cross month boundaries. The leave submission endpoints will be added in their checkpoint.

Start a repeatable scenario:

```bash
dart run tool/mock_api.dart --scenario=slow --today=checked-in
```

Scenarios: `success`, `empty` (no attendance), `slow` (3 seconds), `timeout` (12 seconds, exceeding the 10-second client timeout), `server-error` (HTTP 503), `invalid-response` (unexpected JSON structure), `duplicate-attendance` (409 on new attendance events), and `timeout-after-accept` (accepts and persists attendance before delaying its response for 12 seconds).

Today's fixtures: `not-checked-in` (default), `checked-in`, `checked-out`. Fixtures use the current company date; today's check-in is one hour before now, bounded by company midnight. Historical sessions run 09:15–17:30 in company time. Real submissions update the attendance history and take precedence over the seed fixtures for their company date. Fixture timestamps remain stable until the configured date/status changes.

Change scenarios while the API runs, then refresh the app:

```bash
curl -X POST http://127.0.0.1:8080/mock/scenario \
  -H 'Content-Type: application/json' \
  -d '{"scenario":"success","today":"checked-out"}'
```

Supported startup options: `--port=8080`, `--timezone=Asia/Kolkata`, `--office-lat=12.9716`, `--office-lng=77.5946`, `--scenario=success`, `--today=not-checked-in`, and `--storage=.dart_tool/mock_api/attendance.json`. Accepted event IDs and session updates persist in this ignored local JSON file across server restarts. Unit tests use an isolated in-memory server or a temporary file.

To test offline viewing: load the dashboard successfully, stop the mock server, refresh, then close/reopen the app. The saved dashboard remains available with a server-unreachable notice. A server outage is not labelled as confirmed device disconnection. Restart the server and refresh to recover. A first launch without a saved snapshot displays an error and retry action.

## Attendance testing

Stop and rebuild the app after adding the location plugin. Only foreground location is requested; no background location permission is needed.

The default office is latitude **12.9716**, longitude **77.5946**, with a **200-metre** radius. Android Emulator: open Extended controls (the three-dot control), select **Location > Single points**, select/search these coordinates, and use **Set location**. See [Android's emulator location controls](https://developer.android.com/studio/run/emulator-extended-controls#location). In iOS Simulator, use its custom simulated-location control to enter the same coordinates. On a physical device, start the server with `--office-lat=YOUR_LATITUDE --office-lng=YOUR_LONGITUDE` and refresh the app before recording attendance.

1. Use the default `not-checked-in` fixture and a fresh company date/session.
2. Open Attendance, tap Check-in, and allow foreground precise location. Verify Checked In and Synced.
3. Tap Check-out. Verify one completed session, and that another check-in is unavailable today. Rapid repeated taps must create only one action.
4. Before a new check-in, simulate an outside point such as latitude 12.9816, longitude 77.5946. Verify attendance is refused.
5. Deny permission, permanently deny it through app settings, or disable device location; verify the corresponding message and settings action.
6. For offline persistence, load employee/office data first, stop the API, then record a valid action. Verify Pending Sync, close/reopen the app, and verify it remains. A checkout following an unsent check-in is saved without sending it out of order. Processing saved actions on reconnect is the next checkpoint.

For independent repeat runs, use a disposable emulator/install and a new mock storage file, for example `--storage=.dart_tool/mock_api/another-session.json`; clear app data on that disposable device so old local attendance does not intentionally block another check-in.

Client validation covers daily sequencing, company-date rollover during GPS capture, coordinates within the office radius and fresh location evidence. The mock server independently repeats employee/session identity, daily uniqueness, check-in-before-checkout, event company date, timestamp ordering, location radius and location-evidence age checks. Server mutations are serialized, and the original event ID and payload return the original acceptance on retry. Production must also authenticate the employee, authorize office configuration, protect server state transactionally, and assess device clock/location tampering; client GPS evidence alone cannot prove physical presence.

## Architecture and storage

Features own their models, services, controllers, states, screens and widgets. Provider controllers manage module state. DashboardService loads employee configuration; AttendanceService loads attendance; LeaveBalanceService loads balances. DashboardCacheService owns dashboard persistence. Shared HTTP, Hive initialization, formatting and reusable UI live in `core`. There are no repositories, dependency injection framework, or application `setState` calls.

Hive stores a typed complete dashboard snapshot. Generated adapters cover OfficeModel (type ID 0), EmployeeModel (1), AttendanceRecordModel (2), LeaveBalanceModel (3), DashboardSnapshotModel (4), AttendanceEventModel (5), AttendanceAction (6), AttendanceSyncStatus (7), and AttendanceLocationModel (8). Type IDs and existing field numbers must remain stable as models evolve. The snapshot is replaced only after all three HTTP calls succeed; failures retain the previous complete snapshot. Storage failures are shown separately from network failures.

Regenerate adapters after changing annotated models:

```bash
dart run build_runner build --delete-conflicting-outputs
```

`hive_generator` and `build_runner` are pinned to compatible versions. Hive's generator currently requires an older analyzer and may print an SDK support warning; the generated models are checked with the project's Dart analyzer and tests. No dependency overrides are used.

Timestamps are UTC. Attendance calendar dates and display times use the office's IANA timezone through `timezone`; `intl` formats dates and durations. A foreground clock updates working duration and refreshes on company-date rollover. The dashboard refreshes when the app resumes. Cached data is labelled with its last-update time and retained during refreshing.

Dependencies: `provider` for state management, `http` for requests, `hive`/`hive_flutter` for typed persistence, `timezone` for company dates, `intl` for formatting, `geolocator` for foreground GPS permissions/location, and `uuid` for stable attendance event IDs. Fixed interface text lives in `text_constants.dart`; colors live in `core/helpers/colors.dart`. The app uses one light theme.

## Validation

```bash
flutter analyze
flutter test
```

Tests cover rapid-tap protection, attendance rules, GPS permission states, geofence boundaries, pending event persistence, server idempotency including timeout-after-accept and server restart, pending-state widgets, real mock HTTP responses and failure classification, typed Hive persistence across close/reopen, company timezone boundaries and daylight saving, loading/error/empty widgets, navigation, and responsive layouts with enlarged text. Android/iOS device checks and the remaining assignment tests are completed at their relevant checkpoints.

## Submission notes

Implementation is assisted by OpenAI Codex, including generated source and tests. Hive adapter source is generated using `hive_generator`. Final limitations, actual implementation time, APK instructions and demo details will be updated after the remaining checkpoints.
