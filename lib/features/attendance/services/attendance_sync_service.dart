import '../../../core/network/api_exception.dart';
import '../models/attendance_action.dart';
import '../models/attendance_event_model.dart';
import '../models/attendance_sync_result.dart';
import '../models/attendance_sync_status.dart';
import 'attendance_cache_service.dart';
import 'attendance_service.dart';

class AttendanceSyncService {
  AttendanceSyncService({String? baseUrl})
    : _attendance = AttendanceService(baseUrl: baseUrl);

  final AttendanceService _attendance;
  final _cache = AttendanceCacheService();
  Future<AttendanceSyncResult>? _running;

  // Shares one queue pass between overlapping manual and automatic triggers.
  Future<AttendanceSyncResult> synchronize() {
    return _running ??= _process().whenComplete(() => _running = null);
  }

  // Processes durable events in order and stops on uncertain server outcomes.
  Future<AttendanceSyncResult> _process() async {
    var synced = 0;
    var rejected = 0;
    while (true) {
      final events = await _cache.read();
      final pending = events.where(
        (event) => event.status == AttendanceSyncStatus.pending,
      );
      if (pending.isEmpty) {
        return AttendanceSyncResult(synced: synced, rejected: rejected);
      }
      final event = pending.first;
      if (_hasRejectedCheckIn(event, events)) {
        await _cache.save(
          event.withStatus(
            AttendanceSyncStatus.rejected,
            rejectionCode: 'check_in_rejected',
          ),
        );
        rejected++;
        continue;
      }
      try {
        await _attendance.submit(event);
      } on ApiException catch (error) {
        if (error.isPermanentRejection) {
          await _cache.save(
            event.withStatus(
              AttendanceSyncStatus.rejected,
              rejectionCode: error.code,
            ),
          );
          rejected++;
          continue;
        }
        return AttendanceSyncResult(
          synced: synced,
          rejected: rejected,
          failure: error.failure,
        );
      }
      await _cache.save(event.withStatus(AttendanceSyncStatus.synced));
      synced++;
    }
  }

  // Prevents a checkout from being attached to a different accepted session.
  bool _hasRejectedCheckIn(
    AttendanceEventModel event,
    List<AttendanceEventModel> events,
  ) {
    return event.action == AttendanceAction.checkOut &&
        events.any(
          (previous) =>
              previous.employeeId == event.employeeId &&
              previous.sessionId == event.sessionId &&
              previous.action == AttendanceAction.checkIn &&
              previous.status == AttendanceSyncStatus.rejected,
        );
  }
}
