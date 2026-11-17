import 'package:flutter_test/flutter_test.dart';
import 'package:rebs_hrms/core/network/api_exception.dart';
import 'package:rebs_hrms/core/network/api_service.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_record_model.dart';
import 'package:rebs_hrms/features/dashboard/models/employee_model.dart';
import 'package:rebs_hrms/features/leave/models/leave_balance_model.dart';
import '../tool/mock_api.dart';

void main() {
  late MockApiServer server;
  late ApiService api;
  setUp(() async {
    server = MockApiServer();
    await server.start(port: 0);
    api = ApiService(baseUrl: 'http://127.0.0.1:${server.port}');
  });
  tearDown(() async => server.close());
  test(
    'HTTP endpoints return typed employee, balance and five ordered records',
    () async {
      final employee = EmployeeModel.fromJson(await api.get('/employee/me'));
      final balance = LeaveBalanceModel.fromJson(
        await api.get('/leave/balance'),
      );
      final history = await api.get('/attendance', query: {'limit': '5'});
      final records = (history['records'] as List)
          .map((item) => AttendanceRecordModel.fromJson(item))
          .toList();
      expect(employee.office.radiusMetres, 200);
      expect(balance.total, 13);
      expect(records, hasLength(5));
      expect(records.first.checkIn.isAfter(records.last.checkIn), isTrue);
      expect(records.every((record) => record.checkIn.isUtc), isTrue);
    },
  );
  test('Empty attendance scenario preserves employee and leave data', () async {
    server.scenario = 'empty';
    expect((await api.get('/attendance'))['records'], isEmpty);
    expect((await api.get('/employee/me'))['id'], 'REBS-1042');
    expect((await api.get('/leave/balance'))['casual'], 8);
  });
  test(
    'Checked-in and checked-out fixtures expose the correct timestamps',
    () async {
      server.todayStatus = 'checked-in';
      var history = await api.get('/attendance');
      expect(history['records'][0]['check_out'], isNull);
      server.todayStatus = 'checked-out';
      history = await api.get('/attendance');
      expect(history['records'][0]['check_out'], isNotNull);
    },
  );
  test('Server errors are distinct from an unreachable API', () async {
    server.scenario = 'server-error';
    await expectLater(
      api.get('/employee/me'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.failure, 'failure', ApiFailure.server)
            .having((error) => error.statusCode, 'status', 503),
      ),
    );
    await server.close();
    await expectLater(
      api.get('/employee/me'),
      throwsA(
        isA<ApiException>().having(
          (error) => error.failure,
          'failure',
          ApiFailure.unavailable,
        ),
      ),
    );
  });
}
