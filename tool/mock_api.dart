import 'dart:convert';
import 'dart:io';

import 'package:timezone/timezone.dart' as tz;
import 'package:rebs_hrms/features/attendance/models/attendance_event_model.dart';

import 'services/mock_attendance_service.dart';

import 'package:rebs_hrms/core/helpers/company_clock.dart';

const mockScenarios = {
  'success',
  'empty',
  'slow',
  'timeout',
  'server-error',
  'invalid-response',
  'duplicate-attendance',
  'timeout-after-accept',
};
const todayStatuses = {'not-checked-in', 'checked-in', 'checked-out'};

// Starts the local HTTP API with repeatable dashboard scenarios.
Future<void> main(List<String> arguments) async {
  final options = <String, String>{};
  for (final argument in arguments) {
    final separator = argument.indexOf('=');
    if (!argument.startsWith('--') || separator == -1) {
      stderr.writeln(
        'Use --option=value. See README.md for supported options.',
      );
      exitCode = 64;
      return;
    }
    options[argument.substring(2, separator)] = argument.substring(
      separator + 1,
    );
  }
  try {
    final api = MockApiServer(
      storagePath: options['storage'] ?? '.dart_tool/mock_api/attendance.json',
      scenario: options['scenario'] ?? 'success',
      todayStatus: options['today'] ?? 'not-checked-in',
      timezone: options['timezone'] ?? 'Asia/Kolkata',
      officeLatitude: double.parse(options['office-lat'] ?? '12.9716'),
      officeLongitude: double.parse(options['office-lng'] ?? '77.5946'),
    );
    await api.start(port: int.parse(options['port'] ?? '8080'));
    stdout.writeln('REBS mock API listening on port ${api.port}');
    stdout.writeln(
      'Scenario: ${api.scenario}; today: ${api.todayStatus}; timezone: ${api.timezone}',
    );
    stdout.writeln('Use Ctrl+C to stop.');
  } catch (error) {
    stderr.writeln('Could not start mock API: $error');
    exitCode = 64;
  }
}

class MockApiServer {
  MockApiServer({
    this.scenario = 'success',
    this.todayStatus = 'not-checked-in',
    this.timezone = 'Asia/Kolkata',
    this.officeLatitude = 12.9716,
    this.officeLongitude = 77.5946,
    this.storagePath,
  });

  String scenario;
  String todayStatus;
  final String timezone;
  final double officeLatitude;
  final double officeLongitude;
  final String? storagePath;
  late final MockAttendanceService _attendanceService;
  String? _fixtureKey;
  List<Map<String, dynamic>> _fixtureRecords = [];
  HttpServer? _server;

  int get port => _server!.port;

  // Binds the mock server and validates its configurable fixture settings.
  Future<void> start({int port = 8080}) async {
    if (!mockScenarios.contains(scenario) ||
        !todayStatuses.contains(todayStatus)) {
      throw const FormatException('Unknown scenario or attendance status');
    }
    CompanyClock.inZone(DateTime.now(), timezone);
    _attendanceService = MockAttendanceService(storagePath: storagePath);
    await _attendanceService.initialize();
    _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    _server!.listen(_handle);
  }

  // Closes the HTTP listener for repeatable automated tests.
  Future<void> close() async => _server?.close(force: true);

  // Routes real HTTP requests and applies the selected failure scenario.
  Future<void> _handle(HttpRequest request) async {
    try {
      if (request.uri.path == '/health') {
        _reply(request, {'scenario': scenario, 'today': todayStatus});
        return;
      }
      if (request.uri.path == '/mock/scenario' && request.method == 'POST') {
        final body =
            jsonDecode(await utf8.decoder.bind(request).join())
                as Map<String, dynamic>;
        final nextScenario = body['scenario'] as String? ?? scenario;
        final nextStatus = body['today'] as String? ?? todayStatus;
        if (!mockScenarios.contains(nextScenario) ||
            !todayStatuses.contains(nextStatus)) {
          _reply(request, {
            'message': 'Unknown scenario or attendance status',
          }, status: 400);
          return;
        }
        scenario = nextScenario;
        todayStatus = nextStatus;
        _reply(request, {'scenario': scenario, 'today': todayStatus});
        return;
      }
      if (request.method != 'GET' &&
          !(request.method == 'POST' &&
              request.uri.path == '/attendance/events')) {
        _reply(request, {
          'message': 'Method not implemented in this checkpoint',
        }, status: 405);
        return;
      }
      final selectedScenario = scenario;
      if (selectedScenario == 'slow') {
        await Future<void>.delayed(const Duration(seconds: 3));
      }
      if (selectedScenario == 'timeout') {
        await Future<void>.delayed(const Duration(seconds: 12));
      }
      if (selectedScenario == 'server-error') {
        _reply(request, {'message': 'Simulated server error'}, status: 503);
        return;
      }
      if (selectedScenario == 'invalid-response') {
        _reply(request, {'unexpected': true});
        return;
      }
      if (request.uri.path == '/attendance/events' &&
          request.method == 'POST') {
        final body =
            jsonDecode(await utf8.decoder.bind(request).join())
                as Map<String, dynamic>;
        final event = AttendanceEventModel.fromJson(body);
        final response = await _attendanceService.submit(
          event,
          _fixtures(),
          timezone: timezone,
          officeLatitude: officeLatitude,
          officeLongitude: officeLongitude,
          forceConflict: selectedScenario == 'duplicate-attendance',
        );
        if (selectedScenario == 'timeout-after-accept') {
          await Future<void>.delayed(const Duration(seconds: 12));
        }
        _reply(request, response);
        return;
      }
      switch (request.uri.path) {
        case '/employee/me':
          _reply(request, {
            'id': 'REBS-1042',
            'name': 'Aarav Menon',
            'department': 'Engineering',
            'designation': 'Flutter Developer',
            'office': {
              'name': 'Bengaluru Office',
              'latitude': officeLatitude,
              'longitude': officeLongitude,
              'radius_metres': 200,
              'timezone': timezone,
            },
          });
        case '/attendance':
          var records = _attendanceService.records(
            selectedScenario == 'empty' ? [] : _fixtures(),
          );
          final month = request.uri.queryParameters['month'];
          if (month != null) {
            records = records
                .where((r) => (r['date'] as String).startsWith('$month-'))
                .toList();
          }
          final limit = int.tryParse(
            request.uri.queryParameters['limit'] ?? '5',
          );
          if (limit == null || limit < 1 || limit > 100) {
            _reply(request, {
              'message': 'limit must be between 1 and 100',
            }, status: 400);
            return;
          }
          _reply(request, {'records': records.take(limit).toList()});
        case '/leave/balance':
          _reply(request, {'casual': 8, 'sick': 5});
        default:
          _reply(request, {'message': 'Endpoint not found'}, status: 404);
      }
    } on MockAttendanceException catch (error) {
      _reply(request, {'code': error.code}, status: error.status);
    } catch (_) {
      try {
        _reply(request, {'code': 'invalid_request'}, status: 400);
      } catch (_) {
        return;
      }
    }
  }

  // Generates UTC timestamps from company calendar dates, including month edges.
  List<Map<String, dynamic>> _fixtures() {
    final key =
        '${CompanyClock.dateKey(DateTime.now(), timezone)}|$todayStatus';
    if (_fixtureKey != key) {
      _fixtureRecords = _createFixtures();
      _fixtureKey = key;
    }
    return _fixtureRecords;
  }

  // Creates stable fixture timestamps until the company date or scenario changes.
  List<Map<String, dynamic>> _createFixtures() {
    final now = CompanyClock.inZone(DateTime.now(), timezone);
    final records = <Map<String, dynamic>>[];
    if (todayStatus != 'not-checked-in') {
      final start = now.subtract(const Duration(hours: 1));
      final midnight = tz.TZDateTime(
        now.location,
        now.year,
        now.month,
        now.day,
      );
      records.add({
        'id': 'attendance-today',
        'date': CompanyClock.dateKey(now, timezone),
        'check_in': (start.isBefore(midnight) ? midnight : start)
            .toUtc()
            .toIso8601String(),
        'check_out': todayStatus == 'checked-out'
            ? now.toUtc().toIso8601String()
            : null,
      });
    }
    for (var offset = 1; offset <= 6; offset++) {
      final start = tz.TZDateTime(
        now.location,
        now.year,
        now.month,
        now.day - offset,
        9,
        15,
      );
      final end = tz.TZDateTime(
        now.location,
        start.year,
        start.month,
        start.day,
        17,
        30,
      );
      records.add({
        'id': 'attendance-${CompanyClock.dateKey(start, timezone)}',
        'date': CompanyClock.dateKey(start, timezone),
        'check_in': start.toUtc().toIso8601String(),
        'check_out': end.toUtc().toIso8601String(),
      });
    }
    return records;
  }

  // Sends JSON responses with an explicit HTTP status.
  void _reply(
    HttpRequest request,
    Map<String, dynamic> body, {
    int status = 200,
  }) {
    request.response.statusCode = status;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(body));
    request.response.close().ignore();
  }
}
