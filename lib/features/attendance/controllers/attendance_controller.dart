import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/helpers/company_clock.dart';
import '../../dashboard/models/dashboard_snapshot_model.dart';
import '../models/attendance_action.dart';
import '../models/attendance_event_model.dart';
import '../models/attendance_sync_status.dart';
import '../services/attendance_cache_service.dart';
import '../services/attendance_location_service.dart';
import '../services/attendance_rules_service.dart';
import '../services/attendance_summary_service.dart';
import '../states/attendance_state.dart';
import '../states/attendance_summary_state.dart';

class AttendanceController extends ChangeNotifier {
  AttendanceController() {
    _subscription = _cache.changes.listen((_) => _refreshEvents());
    load();
  }

  final _cache = AttendanceCacheService();
  final _location = AttendanceLocationService();
  final _rules = AttendanceRulesService();
  StreamSubscription<void>? _subscription;
  String? _lastEventId;
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
      await _refreshEvents();
    } catch (_) {
      _publish(feedback: AttendanceFeedback.storageError);
    }
  }

  // Restores event statuses without clearing an in-progress action.
  Future<void> _refreshEvents() async {
    if (_disposed) return;
    try {
      final events = await _cache.read();
      _publish(
        events: events,
        isSubmitting: _state.isSubmitting,
        feedback: _feedbackFor(events),
      );
    } catch (_) {
      _publish(
        isSubmitting: _state.isSubmitting,
        feedback: AttendanceFeedback.storageError,
      );
    }
  }

  // Keeps the latest action's message consistent with its delivery status.
  AttendanceFeedback? _feedbackFor(List<AttendanceEventModel> events) {
    const deliveryMessages = {
      AttendanceFeedback.savedPending,
      AttendanceFeedback.checkedIn,
      AttendanceFeedback.checkedOut,
      AttendanceFeedback.rejected,
    };
    if (_state.feedback != null &&
        !deliveryMessages.contains(_state.feedback)) {
      return _state.feedback;
    }
    for (final event in events) {
      if (event.id != _lastEventId) continue;
      return switch (event.status) {
        AttendanceSyncStatus.pending => AttendanceFeedback.savedPending,
        AttendanceSyncStatus.rejected => AttendanceFeedback.rejected,
        AttendanceSyncStatus.synced =>
          event.action == AttendanceAction.checkIn
              ? AttendanceFeedback.checkedIn
              : AttendanceFeedback.checkedOut,
      };
    }
    return _state.feedback;
  }

  // Validates GPS and daily rules before adding one durable attendance action.
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
      _lastEventId = event.id;
      final saved = await _cache.read();
      _publish(events: saved, feedback: _feedbackFor(saved));
      return true;
    } on AttendanceRuleException catch (error) {
      _publish(feedback: error.feedback);
    } catch (_) {
      _publish(feedback: AttendanceFeedback.storageError);
    }
    return false;
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
    _subscription?.cancel();
    super.dispose();
  }
}
