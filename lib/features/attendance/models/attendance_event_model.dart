import 'package:hive/hive.dart';

import 'attendance_action.dart';
import 'attendance_location_model.dart';
import 'attendance_sync_status.dart';

part 'attendance_event_model.g.dart';

@HiveType(typeId: 5)
class AttendanceEventModel {
  const AttendanceEventModel({
    required this.id,
    required this.employeeId,
    required this.sessionId,
    required this.action,
    required this.companyDate,
    required this.occurredAt,
    required this.location,
    this.status = AttendanceSyncStatus.pending,
    this.rejectionCode,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String employeeId;
  @HiveField(2)
  final String sessionId;
  @HiveField(3)
  final AttendanceAction action;
  @HiveField(4)
  final String companyDate;
  @HiveField(5)
  final DateTime occurredAt;
  @HiveField(6)
  final AttendanceLocationModel location;
  @HiveField(7)
  final AttendanceSyncStatus status;
  @HiveField(8)
  final String? rejectionCode;

  // Parses the stable attendance payload received by the mock API.
  factory AttendanceEventModel.fromJson(Map<String, dynamic> json) {
    return AttendanceEventModel(
      id: json['event_id'] as String,
      employeeId: json['employee_id'] as String,
      sessionId: json['session_id'] as String,
      action: AttendanceAction.values.byName(json['action'] as String),
      companyDate: json['company_date'] as String,
      occurredAt: DateTime.parse(json['occurred_at'] as String).toUtc(),
      location: AttendanceLocationModel.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
    );
  }

  // Serializes the immutable event identity and original location evidence.
  Map<String, dynamic> toJson() => {
    'event_id': id,
    'employee_id': employeeId,
    'session_id': sessionId,
    'action': action.name,
    'company_date': companyDate,
    'occurred_at': occurredAt.toUtc().toIso8601String(),
    'location': location.toJson(),
  };

  // Updates delivery status without changing the event or its identity.
  AttendanceEventModel withStatus(
    AttendanceSyncStatus status, {
    String? rejectionCode,
  }) {
    return AttendanceEventModel(
      id: id,
      employeeId: employeeId,
      sessionId: sessionId,
      action: action,
      companyDate: companyDate,
      occurredAt: occurredAt,
      location: location,
      status: status,
      rejectionCode: rejectionCode,
    );
  }
}
