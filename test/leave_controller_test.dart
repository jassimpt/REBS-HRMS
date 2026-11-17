import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:rebs_hrms/core/helpers/company_clock.dart';
import 'package:rebs_hrms/core/network/api_exception.dart';
import 'package:rebs_hrms/core/storage/local_storage_service.dart';
import 'package:rebs_hrms/features/leave/controllers/leave_form_controller.dart';
import 'package:rebs_hrms/features/leave/controllers/leave_requests_controller.dart';
import 'package:rebs_hrms/features/leave/models/leave_snapshot_model.dart';
import 'package:rebs_hrms/features/leave/services/leave_cache_service.dart';
import 'package:rebs_hrms/features/leave/services/leave_balance_service.dart';
import 'package:rebs_hrms/features/leave/services/leave_requests_service.dart';
import 'package:rebs_hrms/features/leave/states/leave_form_state.dart';

import '../tool/mock_api.dart';
import 'support/leave_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final originalOverrides = HttpOverrides.current;
  late Directory directory;
  late MockApiServer server;
  late LeaveFormController form;
  LeaveRequestsController? history;
  late String baseUrl;

  void fillForm() {
    final application = leaveApplicationFixture();
    form.selectStart(CompanyClock.parseCalendarDate(application.startDate));
    form.selectEnd(CompanyClock.parseCalendarDate(application.endDate));
    form.reasonController.text = application.reason;
  }

  setUp(() async {
    HttpOverrides.global = null;
    directory = await Directory.systemTemp.createTemp('rebs-leave-controller-');
    Hive.init(directory.path);
    LocalStorageService.registerAdapters();
    await Hive.openBox<LeaveSnapshotModel>(LeaveCacheService.boxName);
    server = MockApiServer();
    await server.start(port: 0);
    baseUrl = 'http://127.0.0.1:${server.port}';
    form = LeaveFormController(baseUrl: baseUrl);
  });
  tearDown(() async {
    form.dispose();
    history?.dispose();
    history = null;
    await server.close();
    await Hive.close();
    await directory.delete(recursive: true);
    HttpOverrides.global = originalOverrides;
  });

  test(
    'Invalid local input is retained without sending an HTTP submission',
    () async {
      form.reasonController.text = 'short';
      expect(
        await form.submit(
          snapshot: leaveSnapshotFixture(),
          employeeId: 'REBS-1042',
          timezone: 'Asia/Kolkata',
        ),
        isNull,
      );
      expect(
        form.state.errors[LeaveField.reason],
        LeaveValidationIssue.reasonTooShort,
      );
      expect(
        form.state.errors[LeaveField.startDate],
        LeaveValidationIssue.required,
      );
      expect(form.reasonController.text, 'short');
      expect(server.receivedLeaveApplications, isEmpty);
    },
  );

  test(
    'A locally valid application can be rejected by server policy without clearing the form',
    () async {
      fillForm();
      server.scenario = 'leave-validation-rejection';
      final reason = form.state.reason;
      expect(
        await form.submit(
          snapshot: leaveSnapshotFixture(),
          employeeId: 'REBS-1042',
          timezone: 'Asia/Kolkata',
        ),
        isNull,
      );
      expect(form.state.feedback, LeaveFormFeedback.serverRejected);
      expect(form.state.reason, reason);
      expect(form.state.startDate, isNotNull);
      expect(server.receivedLeaveApplications, hasLength(1));
    },
  );

  test(
    'Server overlap validation is shown even when the local history was stale',
    () async {
      await LeaveRequestsService(
        baseUrl: baseUrl,
      ).submit(leaveApplicationFixture());
      fillForm();
      await form.submit(
        snapshot: leaveSnapshotFixture(),
        employeeId: 'REBS-1042',
        timezone: 'Asia/Kolkata',
      );
      expect(
        form.state.errors[LeaveField.endDate],
        LeaveValidationIssue.overlapping,
      );
      expect(form.state.feedback, LeaveFormFeedback.serverRejected);
      expect(form.state.reason, isNotEmpty);
    },
  );

  test(
    'Offline submission keeps the draft and does not queue it in Hive',
    () async {
      fillForm();
      await server.close();
      await form.submit(
        snapshot: leaveSnapshotFixture(),
        employeeId: 'REBS-1042',
        timezone: 'Asia/Kolkata',
      );
      expect(form.state.feedback, LeaveFormFeedback.unavailable);
      expect(form.state.reason, isNotEmpty);
      expect(form.state.isSubmitting, isFalse);
      expect(await LeaveCacheService().read(), isNull);
    },
  );

  test('Rapid taps send one application and success clears the form', () async {
    fillForm();
    server.scenario = 'slow';
    final first = form.submit(
      snapshot: leaveSnapshotFixture(),
      employeeId: 'REBS-1042',
      timezone: 'Asia/Kolkata',
    );
    expect(
      await form.submit(
        snapshot: leaveSnapshotFixture(),
        employeeId: 'REBS-1042',
        timezone: 'Asia/Kolkata',
      ),
      isNull,
    );
    final result = (await first)!;
    expect(server.receivedLeaveApplications, hasLength(1));
    expect(form.state.feedback, LeaveFormFeedback.submitted);
    expect(form.reasonController.text, isEmpty);
    expect(form.state.startDate, isNull);
    server.scenario = 'success';
    history = LeaveRequestsController(baseUrl: baseUrl);
    await waitForHistory(history!);
    await history!.addSubmitted(result);
    expect(history!.state.data!.balance.casual, 7);
    expect(
      (await LeaveCacheService().read())!.requests.where(
        (request) => request.id == result.request.id,
      ),
      hasLength(1),
    );
  });

  test(
    'Cached history remains available offline after closing and reopening Hive',
    () async {
      history = LeaveRequestsController(baseUrl: baseUrl);
      await waitForHistory(history!);
      expect(history!.state.data!.requests, hasLength(3));
      await server.close();
      await history!.load();
      expect(history!.state.failure, ApiFailure.unavailable);
      expect(history!.state.data!.requests, hasLength(3));
      history!.dispose();
      history = null;
      await Hive.close();
      await Hive.openBox<LeaveSnapshotModel>(LeaveCacheService.boxName);
      history = LeaveRequestsController(baseUrl: baseUrl);
      await waitForHistory(history!);
      expect(history!.state.data!.requests, hasLength(3));
      expect(history!.state.failure, ApiFailure.unavailable);
    },
  );

  test(
    'Retrying an unchanged form after an accepted timeout does not duplicate leave',
    () async {
      fillForm();
      form.selectEnd(
        CompanyClock.parseCalendarDate(
          leaveApplicationFixture(days: 8).endDate,
        ),
      );
      server.scenario = 'timeout-after-accept';
      expect(
        await form.submit(
          snapshot: leaveSnapshotFixture(),
          employeeId: 'REBS-1042',
          timezone: 'Asia/Kolkata',
        ),
        isNull,
      );
      expect(form.state.feedback, LeaveFormFeedback.timeout);
      expect(form.state.reason, isNotEmpty);
      server.scenario = 'success';
      final confirmed = LeaveSnapshotModel(
        requests: await LeaveRequestsService(baseUrl: baseUrl).fetchRequests(),
        balance: await LeaveBalanceService(baseUrl: baseUrl).fetchBalance(),
        savedAt: DateTime.now().toUtc(),
      );
      final result = (await form.submit(
        snapshot: confirmed,
        employeeId: 'REBS-1042',
        timezone: 'Asia/Kolkata',
      ))!;
      expect(result.balance.casual, 0);
      expect(
        server.receivedLeaveApplications
            .map((application) => application.id)
            .toSet(),
        hasLength(1),
      );
      expect(
        await LeaveRequestsService(baseUrl: baseUrl).fetchRequests(),
        hasLength(4),
      );
    },
  );
}

Future<void> waitForHistory(LeaveRequestsController controller) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (controller.state.isLoading || controller.state.isRefreshing) {
    if (DateTime.now().isAfter(deadline)) {
      throw StateError('Leave history did not load');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
