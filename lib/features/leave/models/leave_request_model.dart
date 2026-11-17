import 'package:hive/hive.dart';

import '../../../core/helpers/company_clock.dart';
import 'leave_type.dart';
import 'leave_request_status.dart';

part 'leave_request_model.g.dart';

@HiveType(typeId: 11)
class LeaveRequestModel {
  const LeaveRequestModel({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.submittedAt,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String employeeId;
  @HiveField(2)
  final LeaveType type;
  @HiveField(3)
  final String startDate;
  @HiveField(4)
  final String endDate;
  @HiveField(5)
  final String reason;
  @HiveField(6)
  final LeaveRequestStatus status;
  @HiveField(7)
  final DateTime submittedAt;

  int get days =>
      CompanyClock.parseCalendarDate(
        endDate,
      ).difference(CompanyClock.parseCalendarDate(startDate)).inDays +
      1;

  // Parses one server-confirmed leave request for offline viewing.
  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    final start = json['start_date'] as String;
    final end = json['end_date'] as String;
    if (CompanyClock.parseCalendarDate(
      end,
    ).isBefore(CompanyClock.parseCalendarDate(start))) {
      throw const FormatException('Invalid leave range');
    }
    return LeaveRequestModel(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      type: LeaveType.values.byName(json['type'] as String),
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      reason: json['reason'] as String,
      status: LeaveRequestStatus.values.byName(json['status'] as String),
      submittedAt: DateTime.parse(json['submitted_at'] as String).toUtc(),
    );
  }

  // Serializes leave history for mock responses and server persistence.
  Map<String, dynamic> toJson() => {
    'id': id,
    'employee_id': employeeId,
    'type': type.name,
    'start_date': startDate,
    'end_date': endDate,
    'reason': reason,
    'status': status.name,
    'submitted_at': CompanyClock.utcTimestamp(submittedAt),
  };
}
