import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:rebs_hrms/core/network/api_exception.dart';
import 'package:rebs_hrms/features/leave/models/leave_request_status.dart';
import 'package:rebs_hrms/features/leave/models/leave_type.dart';
import 'package:rebs_hrms/features/leave/services/leave_balance_service.dart';
import 'package:rebs_hrms/features/leave/services/leave_requests_service.dart';
import '../tool/mock_api.dart';
import 'support/leave_fixture.dart';

void main() {
  late MockApiServer server;
  late LeaveRequestsService requests;
  late LeaveBalanceService balance;
  void connect() {
    final url = 'http://127.0.0.1:${server.port}';
    requests = LeaveRequestsService(baseUrl: url);
    balance = LeaveBalanceService(baseUrl: url);
  }

  setUp(() async {
    server = MockApiServer();
    await server.start(port: 0);
    connect();
  });
  tearDown(() => server.close());

  test(
    'History contains all required statuses and submission reserves the selected balance',
    () async {
      expect(
        (await requests.fetchRequests())
            .map((request) => request.status)
            .toSet(),
        LeaveRequestStatus.values.toSet(),
      );
      final result = await requests.submit(
        leaveApplicationFixture(days: 2, type: LeaveType.sick),
      );
      expect(result.request.status, LeaveRequestStatus.pending);
      expect(result.request.days, 2);
      expect(result.balance.sick, 3);
      expect(result.balance.casual, 8);
      expect((await balance.fetchBalance()).sick, 3);
    },
  );
  test(
    'Unchanged retries create only one application and reserve balance once',
    () async {
      final application = leaveApplicationFixture();
      final results = await Future.wait(
        List.generate(3, (_) => requests.submit(application)),
      );
      expect(
        results.every((result) => result.request.id == application.id),
        isTrue,
      );
      expect(
        (await requests.fetchRequests()).where(
          (request) => request.id == application.id,
        ),
        hasLength(1),
      );
      expect((await balance.fetchBalance()).casual, 7);
    },
  );
  test(
    'Server independently rejects overlapping applications and insufficient balance',
    () async {
      await requests.submit(leaveApplicationFixture());
      await expectLater(
        requests.submit(leaveApplicationFixture(id: 'overlap')),
        throwsA(
          isA<ApiException>().having(
            (error) => error.code,
            'reason',
            'leave_overlap',
          ),
        ),
      );
      await expectLater(
        requests.submit(
          leaveApplicationFixture(
            id: 'too-many',
            offset: 10,
            days: 6,
            type: LeaveType.sick,
          ),
        ),
        throwsA(
          isA<ApiException>().having(
            (error) => error.code,
            'reason',
            'leave_balance_exceeded',
          ),
        ),
      );
    },
  );
  test('Server independently rejects short reasons and past dates', () async {
    await expectLater(
      requests.submit(leaveApplicationFixture(reason: '   short   ')),
      throwsA(
        isA<ApiException>().having(
          (error) => error.code,
          'reason',
          'leave_reason_too_short',
        ),
      ),
    );
    await expectLater(
      requests.submit(leaveApplicationFixture(offset: -1)),
      throwsA(
        isA<ApiException>().having(
          (error) => error.code,
          'reason',
          'leave_start_in_past',
        ),
      ),
    );
  });
  test(
    'Repeatable server-validation scenario rejects a locally valid application',
    () async {
      server.scenario = 'leave-validation-rejection';
      await expectLater(
        requests.submit(leaveApplicationFixture()),
        throwsA(
          isA<ApiException>().having(
            (error) => error.statusCode,
            'status',
            422,
          ),
        ),
      );
      expect(await requests.fetchRequests(), hasLength(3));
    },
  );
  test('Leave submissions and balance survive a mock server restart', () async {
    await server.close();
    final directory = await Directory.systemTemp.createTemp(
      'rebs-leave-server-',
    );
    try {
      final path = '${directory.path}/server.json';
      server = MockApiServer(storagePath: path);
      await server.start(port: 0);
      connect();
      final application = leaveApplicationFixture();
      await requests.submit(application);
      await server.close();
      server = MockApiServer(storagePath: path);
      await server.start(port: 0);
      connect();
      expect(
        (await requests.fetchRequests()).where(
          (request) => request.id == application.id,
        ),
        hasLength(1),
      );
      expect((await requests.submit(application)).balance.casual, 7);
    } finally {
      await directory.delete(recursive: true);
    }
  });
}
