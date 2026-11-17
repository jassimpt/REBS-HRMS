import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:rebs_hrms/core/network/api_exception.dart';
import 'package:rebs_hrms/core/network/api_service.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_action.dart';
import '../tool/mock_api.dart';
import 'support/attendance_fixture.dart';

void main() {
  late MockApiServer server;
  late ApiService api;
  setUp(() async {
    server = MockApiServer();
    await server.start(port: 0);
    api = ApiService(baseUrl: 'http://127.0.0.1:${server.port}');
  });
  tearDown(() => server.close());

  test('Repeated and concurrent HTTP submissions create one session', () async {
    final event = attendanceFixture();
    final responses = await Future.wait(
      List.generate(3, (_) => api.post('/attendance/events', event.toJson())),
    );
    expect(
      responses.every((response) => response['event_id'] == event.id),
      isTrue,
    );
    final records = (await api.get('/attendance'))['records'] as List;
    expect(
      records.where((record) => record['date'] == event.companyDate),
      hasLength(1),
    );
    final duplicate = attendanceFixture(id: 'different-event-id');
    await expectLater(
      api.post('/attendance/events', duplicate.toJson()),
      throwsA(
        isA<ApiException>().having((error) => error.statusCode, 'status', 409),
      ),
    );
  });

  test(
    'Server rejects check-out without check-in and invalid office locations',
    () async {
      final checkOut = attendanceFixture(action: AttendanceAction.checkOut);
      await expectLater(
        api.post('/attendance/events', checkOut.toJson()),
        throwsA(
          isA<ApiException>().having(
            (error) => error.code,
            'reason',
            'check_in_required',
          ),
        ),
      );
      final outside = attendanceFixture(latitude: 13.0);
      await expectLater(
        api.post('/attendance/events', outside.toJson()),
        throwsA(
          isA<ApiException>().having(
            (error) => error.code,
            'reason',
            'invalid_location',
          ),
        ),
      );
    },
  );

  test(
    'Online check-out updates the existing session and rejects another checkout',
    () async {
      final checkIn = attendanceFixture(
        at: DateTime.now().toUtc().subtract(const Duration(seconds: 1)),
      );
      await api.post('/attendance/events', checkIn.toJson());
      final checkOut = attendanceFixture(
        id: 'checkout',
        sessionId: checkIn.id,
        action: AttendanceAction.checkOut,
      );
      await api.post('/attendance/events', checkOut.toJson());
      final records = (await api.get('/attendance'))['records'] as List;
      expect(records.first['id'], checkIn.id);
      expect(records.first['check_out'], isNotNull);
      final again = attendanceFixture(
        id: 'another-checkout',
        sessionId: checkIn.id,
        action: AttendanceAction.checkOut,
      );
      await expectLater(
        api.post('/attendance/events', again.toJson()),
        throwsA(isA<ApiException>()),
      );
    },
  );

  test(
    'Server acceptance survives restart and the same event stays idempotent',
    () async {
      await server.close();
      final directory = await Directory.systemTemp.createTemp(
        'rebs-mock-test-',
      );
      try {
        final path = '${directory.path}/attendance.json';
        server = MockApiServer(storagePath: path);
        await server.start(port: 0);
        api = ApiService(baseUrl: 'http://127.0.0.1:${server.port}');
        final event = attendanceFixture();
        await api.post('/attendance/events', event.toJson());
        await server.close();
        server = MockApiServer(storagePath: path);
        await server.start(port: 0);
        api = ApiService(baseUrl: 'http://127.0.0.1:${server.port}');
        expect(
          (await api.post('/attendance/events', event.toJson()))['event_id'],
          event.id,
        );
        expect(
          ((await api.get('/attendance'))['records'] as List).where(
            (record) => record['date'] == event.companyDate,
          ),
          hasLength(1),
        );
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );

  test(
    'Retry after timeout-after-accept returns the original event without duplication',
    () async {
      server.scenario = 'timeout-after-accept';
      final event = attendanceFixture();
      await expectLater(
        api.post('/attendance/events', event.toJson()),
        throwsA(
          isA<ApiException>().having(
            (error) => error.failure,
            'failure',
            ApiFailure.timeout,
          ),
        ),
      );
      server.scenario = 'success';
      expect(
        (await api.post('/attendance/events', event.toJson()))['event_id'],
        event.id,
      );
      expect(
        ((await api.get('/attendance'))['records'] as List).where(
          (record) => record['date'] == event.companyDate,
        ),
        hasLength(1),
      );
    },
  );
}
