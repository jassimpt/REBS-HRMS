import 'dart:convert';
import 'dart:io';

import 'package:rebs_hrms/core/helpers/company_clock.dart';
import 'package:rebs_hrms/features/leave/models/leave_application_model.dart';
import 'package:rebs_hrms/features/leave/models/leave_balance_model.dart';
import 'package:rebs_hrms/features/leave/models/leave_request_model.dart';
import 'package:rebs_hrms/features/leave/models/leave_request_status.dart';
import 'package:rebs_hrms/features/leave/models/leave_type.dart';
import 'package:rebs_hrms/features/leave/services/leave_rules_service.dart';

class MockLeaveException implements Exception {
  const MockLeaveException(this.code, {this.status = 422});
  final String code;
  final int status;
}

class MockLeaveService {
  MockLeaveService({required this.timezone, this.storagePath});

  final String timezone;
  final String? storagePath;
  final _rules = LeaveRulesService();
  final _fixtures = <LeaveRequestModel>[];
  Map<String, Map<String, dynamic>> _accepted = {};
  Future<void> _submission = Future.value();

  // Creates status examples and restores submitted requests independently of Hive.
  Future<void> initialize() async {
    final now = DateTime.now().toUtc();
    final company = CompanyClock.inZone(now, timezone);
    String date(int daysAgo) => DateTime.utc(
      company.year,
      company.month,
      company.day - daysAgo,
    ).toIso8601String().substring(0, 10);
    _fixtures.addAll([
      LeaveRequestModel(
        id: 'leave-sample-approved',
        employeeId: 'REBS-1042',
        type: LeaveType.casual,
        startDate: date(12),
        endDate: date(11),
        reason: 'Family commitments and personal appointments.',
        status: LeaveRequestStatus.approved,
        submittedAt: now.subtract(const Duration(days: 15)),
      ),
      LeaveRequestModel(
        id: 'leave-sample-pending',
        employeeId: 'REBS-1042',
        type: LeaveType.sick,
        startDate: date(4),
        endDate: date(4),
        reason: 'Medical consultation and recovery at home.',
        status: LeaveRequestStatus.pending,
        submittedAt: now.subtract(const Duration(days: 5)),
      ),
      LeaveRequestModel(
        id: 'leave-sample-rejected',
        employeeId: 'REBS-1042',
        type: LeaveType.casual,
        startDate: date(7),
        endDate: date(7),
        reason: 'Personal travel and family arrangements.',
        status: LeaveRequestStatus.rejected,
        submittedAt: now.subtract(const Duration(days: 9)),
      ),
    ]);
    if (storagePath == null) return;
    final file = File(storagePath!);
    if (!await file.exists()) return;
    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    _accepted = data.map(
      (key, value) => MapEntry(key, Map<String, dynamic>.from(value as Map)),
    );
  }

  // Returns submitted requests and optional historical status fixtures.
  List<LeaveRequestModel> requests({bool includeFixtures = true}) {
    return [
      ...(includeFixtures ? _fixtures : <LeaveRequestModel>[]),
      ..._accepted.values.map(
        (entry) => LeaveRequestModel.fromJson(
          Map<String, dynamic>.from(entry['request'] as Map),
        ),
      ),
    ]..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  // Reserves calendar days for pending and approved requests only.
  LeaveBalanceModel balance() {
    var casual = 10;
    var sick = 6;
    for (final request in requests()) {
      if (request.status == LeaveRequestStatus.rejected) continue;
      final days = _rules.requestedDays(request.startDate, request.endDate);
      if (request.type == LeaveType.casual) {
        casual -= days;
      } else {
        sick -= days;
      }
    }
    return LeaveBalanceModel(casual: casual, sick: sick);
  }

  // Serializes submissions so balance and overlap checks cannot race.
  Future<Map<String, dynamic>> submit(
    LeaveApplicationModel application, {
    bool forceReject = false,
  }) {
    final result = _submission.then(
      (_) => _accept(application, forceReject: forceReject),
    );
    _submission = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return result;
  }

  // Revalidates using current server state and persists an accepted application.
  Future<Map<String, dynamic>> _accept(
    LeaveApplicationModel application, {
    required bool forceReject,
  }) async {
    final existing = _accepted[application.id];
    if (existing != null) {
      if (jsonEncode(existing['payload']) != jsonEncode(application.toJson())) {
        throw const MockLeaveException('idempotency_mismatch', status: 409);
      }
      return {'request': existing['request'], 'balance': balance().toJson()};
    }
    if (application.id.isEmpty || application.employeeId != 'REBS-1042') {
      throw const MockLeaveException('leave_invalid_employee');
    }
    final errors = _rules.validate(
      type: application.type,
      startDate: application.startDate,
      endDate: application.endDate,
      reason: application.reason,
      balance: balance(),
      requests: requests(),
      timezone: timezone,
    );
    if (errors.isNotEmpty) {
      throw MockLeaveException(_rules.code(errors.values.first));
    }
    if (forceReject) throw const MockLeaveException('leave_policy_rejected');
    final request = LeaveRequestModel(
      id: application.id,
      employeeId: application.employeeId,
      type: application.type,
      startDate: application.startDate,
      endDate: application.endDate,
      reason: application.reason.trim(),
      status: LeaveRequestStatus.pending,
      submittedAt: DateTime.now().toUtc(),
    );
    final next = {
      ..._accepted,
      application.id: {
        'payload': application.toJson(),
        'request': request.toJson(),
      },
    };
    if (storagePath != null) {
      final file = File(storagePath!);
      await file.parent.create(recursive: true);
      final temporary = File('$storagePath.tmp');
      await temporary.writeAsString(jsonEncode(next), flush: true);
      await temporary.rename(file.path);
    }
    _accepted = next;
    return {'request': request.toJson(), 'balance': balance().toJson()};
  }
}
