import 'package:rebs_hrms/core/helpers/company_clock.dart';
import 'package:rebs_hrms/features/leave/models/leave_application_model.dart';
import 'package:rebs_hrms/features/leave/models/leave_balance_model.dart';
import 'package:rebs_hrms/features/leave/models/leave_request_model.dart';
import 'package:rebs_hrms/features/leave/models/leave_request_status.dart';
import 'package:rebs_hrms/features/leave/models/leave_snapshot_model.dart';
import 'package:rebs_hrms/features/leave/models/leave_type.dart';

LeaveRequestModel leaveRequestFixture({
  String id = 'request-1',
  String start = '2026-11-19',
  String end = '2026-11-20',
  LeaveRequestStatus status = LeaveRequestStatus.pending,
}) {
  return LeaveRequestModel(
    id: id,
    employeeId: 'REBS-1042',
    type: LeaveType.casual,
    startDate: start,
    endDate: end,
    reason: 'Family commitments and personal appointments.',
    status: status,
    submittedAt: DateTime.utc(2026, 11, 17, 5),
  );
}

LeaveSnapshotModel leaveSnapshotFixture({
  List<LeaveRequestModel> requests = const [],
}) {
  return LeaveSnapshotModel(
    requests: requests,
    balance: const LeaveBalanceModel(casual: 8, sick: 5),
    savedAt: DateTime.utc(2026, 11, 17, 5),
  );
}

LeaveApplicationModel leaveApplicationFixture({
  String id = 'new-request',
  int offset = 2,
  int days = 1,
  LeaveType type = LeaveType.casual,
  String reason = 'Personal appointments and family commitments.',
}) {
  final company = CompanyClock.inZone(DateTime.now(), 'Asia/Kolkata');
  final start = DateTime.utc(company.year, company.month, company.day + offset);
  final end = start.add(Duration(days: days - 1));
  return LeaveApplicationModel(
    id: id,
    employeeId: 'REBS-1042',
    type: type,
    startDate: start.toIso8601String().substring(0, 10),
    endDate: end.toIso8601String().substring(0, 10),
    reason: reason,
  );
}
