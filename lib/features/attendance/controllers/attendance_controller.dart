import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/helpers/company_clock.dart';
import '../../../core/network/api_exception.dart';
import '../../dashboard/models/dashboard_snapshot_model.dart';
import '../models/attendance_action.dart';
import '../models/attendance_event_model.dart';
import '../models/attendance_sync_status.dart';
import '../services/attendance_cache_service.dart';
import '../services/attendance_location_service.dart';
import '../services/attendance_rules_service.dart';
import '../services/attendance_service.dart';
import '../services/attendance_summary_service.dart';
import '../states/attendance_state.dart';
import '../states/attendance_summary_state.dart';

class AttendanceController extends ChangeNotifier {
  AttendanceController() {
    load();
  }

  final _cache = AttendanceCacheService();
  final _location = AttendanceLocationService();
  final _rules = AttendanceRulesService();
  final _service = AttendanceService();
  final _summary = AttendanceSummaryService();
  AttendanceState _state = const AttendanceState();
  bool _disposed = false;

  AttendanceState get state => _state;

  // Builds one consistent attendance view for the dashboard and attendance tab.
  AttendanceSummaryState summarize(DashboardSnapshotModel data) {
    return _summary.summarize(data, _state.events);
  }

  // Publishes immutable attendance state while the controller remains active.
  void _publish({
    List<AttendanceEventModel>? events,
    bool isLoading = false,
    bool isSubmitting = false,
    AttendanceFeedback? feedback,
  }) {
    if (_disposed) return;
    _state = AttendanceState(
      events: events ?? _state.events,
      isLoading: isLoading,
      isSubmitting: isSubmitting,
      feedback: feedback,
    );
    notifyListeners();
  }

  // Restores saved actions, including unsent actions from a previous app session.
  Future<void> load() async {
    if (_state.isSubmitting) return;
    try {
      _publish(events: await _cache.read());
    } catch (_) {
      _publish(feedback: AttendanceFeedback.storageError);
    }
  }

  // Validates GPS and daily rules, saves first, then attempts one online submission.
  Future<bool> submit(
    AttendanceAction action,
    DashboardSnapshotModel data,
  ) async {
    if (_state.isLoading || _state.isSubmitting || _disposed) return false;
    _publish(isSubmitting: true);
    try {
      final events = await _cache.read();
      if (_disposed) return false;
      _publish(events: events, isSubmitting: true);
      final summary = summarize(data);
      _rules.validateAction(action, summary.today);
      final date = CompanyClock.dateKey(
        DateTime.now(),
        data.employee.office.timezone,
      );
      final location = await _location.capture();
      if (_disposed) return false;
      final now = DateTime.now().toUtc();
      _rules.validateDay(date, now, data.employee.office.timezone);
      _rules.validateLocation(location, data.employee.office, now);
      final id = const Uuid().v4();
      final event = AttendanceEventModel(
        id: id,
        employeeId: data.employee.id,
        sessionId: action == AttendanceAction.checkIn ? id : summary.today!.id,
        action: action,
        companyDate: date,
        occurredAt: now,
        location: location,
      );
      await _cache.save(event);
      _publish(events: await _cache.read(), isSubmitting: true);

      final dependsOnPending = events.any(
        (previous) =>
            previous.sessionId == event.sessionId &&
            previous.status == AttendanceSyncStatus.pending,
      );
      if (dependsOnPending) {
        _publish(feedback: AttendanceFeedback.savedPending);
        return false;
      }
      return await _send(event);
    } on AttendanceRuleException catch (error) {
      _publish(feedback: error.feedback);
    } catch (_) {
      _publish(feedback: AttendanceFeedback.storageError);
    }
    return false;
  }

  // Records acknowledgement or rejection while preserving uncertain events for retry.
  Future<bool> _send(AttendanceEventModel event) async {
    try {
      await _service.submit(event);
      await _cache.save(event.withStatus(AttendanceSyncStatus.synced));
      _publish(
        events: await _cache.read(),
        feedback: event.action == AttendanceAction.checkIn
            ? AttendanceFeedback.checkedIn
            : AttendanceFeedback.checkedOut,
      );
      return true;
    } on ApiException catch (error) {
      final code = error.statusCode;
      if (code != null &&
          code >= 400 &&
          code < 500 &&
          code != 408 &&
          code != 429) {
        await _cache.save(
          event.withStatus(
            AttendanceSyncStatus.rejected,
            rejectionCode: error.code,
          ),
        );
        _publish(
          events: await _cache.read(),
          feedback: AttendanceFeedback.rejected,
        );
        return true;
      }
      _publish(feedback: AttendanceFeedback.savedPending);
      return false;
    }
  }

  // Opens permission settings for a permanently denied location request.
  Future<void> openAppSettings() async {
    if (!await _location.openAppSettings()) {
      _publish(feedback: AttendanceFeedback.locationUnavailable);
    }
  }

  // Opens device settings when location services are switched off.
  Future<void> openLocationSettings() async {
    if (!await _location.openLocationSettings()) {
      _publish(feedback: AttendanceFeedback.locationUnavailable);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
