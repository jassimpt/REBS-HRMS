import 'leave_type.dart';

class LeaveApplicationModel {
  const LeaveApplicationModel({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
  });

  final String id;
  final String employeeId;
  final LeaveType type;
  final String startDate;
  final String endDate;
  final String reason;

  // Parses a submitted leave application without trusting client validation.
  factory LeaveApplicationModel.fromJson(Map<String, dynamic> json) {
    return LeaveApplicationModel(
      id: json['request_id'] as String,
      employeeId: json['employee_id'] as String,
      type: LeaveType.values.byName(json['type'] as String),
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      reason: json['reason'] as String,
    );
  }

  // Keeps the same payload and request ID for an unchanged submission retry.
  Map<String, dynamic> toJson() => {
    'request_id': id,
    'employee_id': employeeId,
    'type': type.name,
    'start_date': startDate,
    'end_date': endDate,
    'reason': reason.trim(),
  };
}
