import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/helpers/company_clock.dart';
import '../../../core/network/api_exception.dart';
import '../models/leave_application_model.dart';
import '../models/leave_snapshot_model.dart';
import '../models/leave_submission_result.dart';
import '../models/leave_type.dart';
import '../services/leave_requests_service.dart';
import '../services/leave_rules_service.dart';
import '../states/leave_form_state.dart';

class LeaveFormController extends ChangeNotifier {
  LeaveFormController({String? baseUrl})
    : _requests = LeaveRequestsService(baseUrl: baseUrl) {
    reasonController.addListener(_reasonChanged);
  }

  final reasonController = TextEditingController();
  final LeaveRequestsService _requests;
  final _rules = LeaveRulesService();
  LeaveFormState _state = const LeaveFormState();
  String _requestId = const Uuid().v4();
  bool _disposed = false;

  LeaveFormState get state => _state;

  int? get requestedDays {
    if (_state.startDate == null || _state.endDate == null) return null;
    final days = _rules.requestedDays(_state.startDate!, _state.endDate!);
    return days > 0 ? days : null;
  }

  // Returns the current company calendar date for the date picker.
  DateTime today(String timezone) =>
      _rules.parseDate(CompanyClock.dateKey(DateTime.now(), timezone));

  // Publishes form changes while the controller is attached.
  void _publish(LeaveFormState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  // Selects the leave type and clears balance-related validation.
  void selectType(LeaveType type) {
    if (_state.isSubmitting || type == _state.type) return;
    _requestId = const Uuid().v4();
    _publish(_state.copyWith(type: type, errors: {}));
  }

  // Updates the start date and keeps the date range valid in the picker.
  void selectStart(DateTime date) {
    if (_state.isSubmitting) return;
    final selected = DateFormat('yyyy-MM-dd').format(date);
    if (selected == _state.startDate) return;
    final end = _state.endDate;
    _requestId = const Uuid().v4();
    _publish(
      _state.copyWith(
        startDate: selected,
        endDate: end != null && end.compareTo(selected) < 0 ? selected : end,
        errors: {},
      ),
    );
  }

  // Updates the inclusive end date of the application.
  void selectEnd(DateTime date) {
    if (_state.isSubmitting) return;
    final selected = DateFormat('yyyy-MM-dd').format(date);
    if (selected == _state.endDate) return;
    _requestId = const Uuid().v4();
    _publish(_state.copyWith(endDate: selected, errors: {}));
  }

  // Mirrors reason edits into Provider state without widget-local state.
  void _reasonChanged() {
    if (_state.isSubmitting || reasonController.text == _state.reason) return;
    _requestId = const Uuid().v4();
    final errors = {..._state.errors}..remove(LeaveField.reason);
    _publish(_state.copyWith(reason: reasonController.text, errors: errors));
  }

  // Validates and submits online while retaining inputs after any failure.
  Future<LeaveSubmissionResult?> submit({
    required LeaveSnapshotModel snapshot,
    required String employeeId,
    required String timezone,
  }) async {
    if (_state.isSubmitting || _disposed) return null;
    final confirmed = snapshot.requests.any(
      (request) => request.id == _requestId,
    );
    final errors = confirmed
        ? <LeaveField, LeaveValidationIssue>{}
        : _rules.validate(
            type: _state.type,
            startDate: _state.startDate,
            endDate: _state.endDate,
            reason: _state.reason,
            balance: snapshot.balance,
            requests: snapshot.requests,
            timezone: timezone,
          );
    if (errors.isNotEmpty) {
      _publish(_state.copyWith(errors: errors));
      return null;
    }
    final application = LeaveApplicationModel(
      id: _requestId,
      employeeId: employeeId,
      type: _state.type,
      startDate: _state.startDate!,
      endDate: _state.endDate!,
      reason: _state.reason,
    );
    _publish(_state.copyWith(isSubmitting: true, errors: {}));
    try {
      final result = await _requests.submit(application);
      if (_disposed) return result;
      reasonController.removeListener(_reasonChanged);
      reasonController.clear();
      reasonController.addListener(_reasonChanged);
      _requestId = const Uuid().v4();
      _publish(const LeaveFormState(feedback: LeaveFormFeedback.submitted));
      return result;
    } on ApiException catch (error) {
      final feedback = error.isPermanentRejection
          ? LeaveFormFeedback.serverRejected
          : switch (error.failure) {
              ApiFailure.unavailable => LeaveFormFeedback.unavailable,
              ApiFailure.timeout => LeaveFormFeedback.timeout,
              ApiFailure.server => LeaveFormFeedback.serverError,
              ApiFailure.invalidResponse => LeaveFormFeedback.invalidResponse,
            };
      _publish(
        _state.copyWith(
          isSubmitting: false,
          errors: _rules.serverErrors(error.code),
          feedback: feedback,
        ),
      );
    } catch (_) {
      _publish(
        _state.copyWith(
          isSubmitting: false,
          feedback: LeaveFormFeedback.invalidResponse,
        ),
      );
    }
    return null;
  }

  @override
  void dispose() {
    _disposed = true;
    reasonController.removeListener(_reasonChanged);
    reasonController.dispose();
    super.dispose();
  }
}
