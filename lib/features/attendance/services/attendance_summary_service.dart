import '../../../core/helpers/company_clock.dart';
import '../../dashboard/models/dashboard_snapshot_model.dart';
import '../models/attendance_action.dart';
import '../models/attendance_event_model.dart';
import '../models/attendance_record_model.dart';
import '../models/attendance_sync_status.dart';
import '../states/attendance_summary_state.dart';

class AttendanceSummaryService {
  // Overlays durable local actions without discarding confirmed server sessions.
  AttendanceSummaryState summarize(
    DashboardSnapshotModel data,
    List<AttendanceEventModel> events, {
    DateTime? now,
  }) {
    final instant = now ?? DateTime.now().toUtc();
    final records = {for (final record in data.attendance) record.date: record};
    for (final event in events) {
      if (event.employeeId != data.employee.id ||
          event.status == AttendanceSyncStatus.rejected) {
        continue;
      }
      final current = records[event.companyDate];
      if (event.action == AttendanceAction.checkIn) {
        if (current == null) {
          records[event.companyDate] = AttendanceRecordModel(
            id: event.sessionId,
            date: event.companyDate,
            checkIn: event.occurredAt,
            syncStatus: event.status,
          );
        } else if (current.id == event.sessionId &&
            event.status == AttendanceSyncStatus.pending) {
          records[event.companyDate] = AttendanceRecordModel(
            id: current.id,
            date: current.date,
            checkIn: current.checkIn,
            checkOut: current.checkOut,
            syncStatus: AttendanceSyncStatus.pending,
          );
        }
      } else if (current != null && current.id == event.sessionId) {
        records[event.companyDate] = AttendanceRecordModel(
          id: current.id,
          date: current.date,
          checkIn: current.checkIn,
          checkOut: current.checkOut ?? event.occurredAt,
          syncStatus: current.syncStatus == AttendanceSyncStatus.pending
              ? current.syncStatus
              : event.status,
        );
      }
    }
    final sorted = records.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final date = CompanyClock.dateKey(instant, data.employee.office.timezone);
    final today = records[date];
    final duration = today == null
        ? Duration.zero
        : (today.checkOut ?? instant).difference(today.checkIn);
    return AttendanceSummaryState(
      dashboard: DashboardSnapshotModel(
        employee: data.employee,
        attendance: List.unmodifiable(sorted.take(5)),
        leaveBalance: data.leaveBalance,
        savedAt: data.savedAt,
      ),
      today: today,
      duration: duration.isNegative ? Duration.zero : duration,
      canCheckIn: today == null,
      canCheckOut: today != null && today.checkOut == null,
    );
  }
}
