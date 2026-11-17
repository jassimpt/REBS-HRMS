import 'package:rebs_hrms/core/helpers/company_clock.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_action.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_event_model.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_location_model.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_sync_status.dart';

AttendanceEventModel attendanceFixture({
  String id = '44ba0440-1555-4e70-9465-19674571327c',
  String? sessionId,
  AttendanceAction action = AttendanceAction.checkIn,
  AttendanceSyncStatus status = AttendanceSyncStatus.pending,
  DateTime? at,
  double latitude = 12.9716,
}) {
  final now = at ?? DateTime.now().toUtc();
  return AttendanceEventModel(
    id: id,
    employeeId: 'REBS-1042',
    sessionId: sessionId ?? id,
    action: action,
    companyDate: CompanyClock.dateKey(now, 'Asia/Kolkata'),
    occurredAt: now,
    location: AttendanceLocationModel(
      latitude: latitude,
      longitude: 77.5946,
      accuracy: 5,
      capturedAt: now,
    ),
    status: status,
  );
}
