import '../models/leave_type.dart';

enum LeaveField { startDate, endDate, reason }

enum LeaveValidationIssue {
  required,
  invalidDate,
  startInPast,
  endBeforeStart,
  reasonTooShort,
  balanceExceeded,
  overlapping,
}

enum LeaveFormFeedback {
  submitted,
  unavailable,
  timeout,
  serverRejected,
  serverError,
  invalidResponse,
}

class LeaveFormState {
  const LeaveFormState({
    this.type = LeaveType.casual,
    this.startDate,
    this.endDate,
    this.reason = '',
    this.isSubmitting = false,
    this.errors = const {},
    this.feedback,
  });

  final LeaveType type;
  final String? startDate;
  final String? endDate;
  final String reason;
  final bool isSubmitting;
  final Map<LeaveField, LeaveValidationIssue> errors;
  final LeaveFormFeedback? feedback;

  // Updates the draft while clearing any previous submission feedback.
  LeaveFormState copyWith({
    LeaveType? type,
    String? startDate,
    String? endDate,
    String? reason,
    bool? isSubmitting,
    Map<LeaveField, LeaveValidationIssue>? errors,
    LeaveFormFeedback? feedback,
  }) {
    return LeaveFormState(
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errors: errors ?? this.errors,
      feedback: feedback,
    );
  }
}
