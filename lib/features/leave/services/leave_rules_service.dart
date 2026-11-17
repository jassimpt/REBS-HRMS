import '../../../core/helpers/company_clock.dart';
import '../models/leave_balance_model.dart';
import '../models/leave_request_model.dart';
import '../models/leave_request_status.dart';
import '../models/leave_type.dart';
import '../states/leave_form_state.dart';

class LeaveRulesService {
  // Parses a strict calendar date without device timezone or DST conversion.
  DateTime parseDate(String value) => CompanyClock.parseCalendarDate(value);

  // Counts inclusive calendar days, including weekends and holidays.
  int requestedDays(String startDate, String endDate) {
    return parseDate(endDate).difference(parseDate(startDate)).inDays + 1;
  }

  // Validates the application against current company date, balance and requests.
  Map<LeaveField, LeaveValidationIssue> validate({
    required LeaveType type,
    required String? startDate,
    required String? endDate,
    required String reason,
    required LeaveBalanceModel balance,
    required List<LeaveRequestModel> requests,
    required String timezone,
    DateTime? now,
  }) {
    final errors = <LeaveField, LeaveValidationIssue>{};
    DateTime? start;
    DateTime? end;
    if (startDate == null || startDate.isEmpty) {
      errors[LeaveField.startDate] = LeaveValidationIssue.required;
    } else {
      try {
        start = parseDate(startDate);
      } on FormatException {
        errors[LeaveField.startDate] = LeaveValidationIssue.invalidDate;
      }
    }
    if (endDate == null || endDate.isEmpty) {
      errors[LeaveField.endDate] = LeaveValidationIssue.required;
    } else {
      try {
        end = parseDate(endDate);
      } on FormatException {
        errors[LeaveField.endDate] = LeaveValidationIssue.invalidDate;
      }
    }
    final today = parseDate(
      CompanyClock.dateKey(now ?? DateTime.now(), timezone),
    );
    if (start != null && start.isBefore(today)) {
      errors[LeaveField.startDate] = LeaveValidationIssue.startInPast;
    }
    if (end != null && start != null && end.isBefore(start)) {
      errors[LeaveField.endDate] = LeaveValidationIssue.endBeforeStart;
    }
    if (reason.replaceAll(RegExp(r'\s', unicode: true), '').runes.length < 10) {
      errors[LeaveField.reason] = LeaveValidationIssue.reasonTooShort;
    }
    if (start != null &&
        end != null &&
        !end.isBefore(start) &&
        !errors.containsKey(LeaveField.startDate)) {
      final available = type == LeaveType.casual
          ? balance.casual
          : balance.sick;
      if (end.difference(start).inDays + 1 > available) {
        errors[LeaveField.endDate] = LeaveValidationIssue.balanceExceeded;
      } else if (requests.any(
        (request) =>
            request.status != LeaveRequestStatus.rejected &&
            !end!.isBefore(parseDate(request.startDate)) &&
            !start!.isAfter(parseDate(request.endDate)),
      )) {
        errors[LeaveField.endDate] = LeaveValidationIssue.overlapping;
      }
    }
    return errors;
  }

  // Returns a stable validation code for server responses.
  String code(LeaveValidationIssue issue) => switch (issue) {
    LeaveValidationIssue.required => 'leave_required',
    LeaveValidationIssue.invalidDate => 'leave_invalid_date',
    LeaveValidationIssue.startInPast => 'leave_start_in_past',
    LeaveValidationIssue.endBeforeStart => 'leave_end_before_start',
    LeaveValidationIssue.reasonTooShort => 'leave_reason_too_short',
    LeaveValidationIssue.balanceExceeded => 'leave_balance_exceeded',
    LeaveValidationIssue.overlapping => 'leave_overlap',
  };

  // Maps known server validation codes back to the relevant form field.
  Map<LeaveField, LeaveValidationIssue> serverErrors(String? code) =>
      switch (code) {
        'leave_start_in_past' => {
          LeaveField.startDate: LeaveValidationIssue.startInPast,
        },
        'leave_invalid_date' => {
          LeaveField.startDate: LeaveValidationIssue.invalidDate,
        },
        'leave_end_before_start' => {
          LeaveField.endDate: LeaveValidationIssue.endBeforeStart,
        },
        'leave_reason_too_short' => {
          LeaveField.reason: LeaveValidationIssue.reasonTooShort,
        },
        'leave_balance_exceeded' => {
          LeaveField.endDate: LeaveValidationIssue.balanceExceeded,
        },
        'leave_overlap' => {
          LeaveField.endDate: LeaveValidationIssue.overlapping,
        },
        _ => {},
      };
}
