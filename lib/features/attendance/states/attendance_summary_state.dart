import '../../dashboard/models/dashboard_snapshot_model.dart';
import '../models/attendance_record_model.dart';

class AttendanceSummaryState {
  const AttendanceSummaryState({
    required this.dashboard,
    required this.today,
    required this.duration,
    required this.canCheckIn,
    required this.canCheckOut,
  });

  final DashboardSnapshotModel dashboard;
  final AttendanceRecordModel? today;
  final Duration duration;
  final bool canCheckIn;
  final bool canCheckOut;
}
