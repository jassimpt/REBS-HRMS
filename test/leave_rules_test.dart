import 'package:flutter_test/flutter_test.dart';
import 'package:rebs_hrms/features/leave/models/leave_balance_model.dart';
import 'package:rebs_hrms/features/leave/models/leave_request_status.dart';
import 'package:rebs_hrms/features/leave/models/leave_request_model.dart';
import 'package:rebs_hrms/features/leave/models/leave_type.dart';
import 'package:rebs_hrms/features/leave/services/leave_rules_service.dart';
import 'package:rebs_hrms/features/leave/states/leave_form_state.dart';
import 'support/leave_fixture.dart';

void main() {
  final rules = LeaveRulesService();
  final now = DateTime.utc(2026, 11, 17, 5);
  Map<LeaveField, LeaveValidationIssue> validate({
    String? start = '2026-11-19',
    String? end = '2026-11-20',
    String reason = 'Personal appointments and family commitments.',
    LeaveType type = LeaveType.casual,
    List<LeaveRequestModel> requests = const [],
  }) {
    return rules.validate(
      type: type,
      startDate: start,
      endDate: end,
      reason: reason,
      balance: const LeaveBalanceModel(casual: 8, sick: 5),
      requests: requests,
      timezone: 'Asia/Kolkata',
      now: now,
    );
  }

  test(
    'Pending and Approved requests block overlaps including shared endpoints',
    () {
      for (final status in [
        LeaveRequestStatus.pending,
        LeaveRequestStatus.approved,
      ]) {
        final request = leaveRequestFixture(status: status);
        expect(
          validate(
            start: '2026-11-20',
            end: '2026-11-21',
            requests: [request],
          )[LeaveField.endDate],
          LeaveValidationIssue.overlapping,
        );
        expect(
          validate(
            start: '2026-11-18',
            end: '2026-11-19',
            requests: [request],
          )[LeaveField.endDate],
          LeaveValidationIssue.overlapping,
        );
      }
    },
  );
  test(
    'Rejected requests do not block dates and adjacent ranges do not overlap',
    () {
      expect(
        validate(
          requests: [leaveRequestFixture(status: LeaveRequestStatus.rejected)],
        ),
        isEmpty,
      );
      expect(
        validate(
          start: '2026-11-21',
          end: '2026-11-22',
          requests: [leaveRequestFixture()],
        ),
        isEmpty,
      );
    },
  );
  test(
    'Date validation rejects missing dates, past starts, reversed ranges and invalid dates',
    () {
      expect(
        validate(start: null)[LeaveField.startDate],
        LeaveValidationIssue.required,
      );
      expect(
        validate(start: '2026-11-16')[LeaveField.startDate],
        LeaveValidationIssue.startInPast,
      );
      expect(
        validate(start: '2026-11-21')[LeaveField.endDate],
        LeaveValidationIssue.endBeforeStart,
      );
      expect(
        validate(start: '2026-02-30')[LeaveField.startDate],
        LeaveValidationIssue.invalidDate,
      );
    },
  );
  test('Reason validation counts non-whitespace characters', () {
    expect(
      validate(reason: 'a b c d e f g h i \n\t')[LeaveField.reason],
      LeaveValidationIssue.reasonTooShort,
    );
    expect(validate(reason: 'a b c d e f g h i j'), isEmpty);
  });
  test(
    'Requested duration uses inclusive calendar days and the selected leave balance',
    () {
      expect(rules.requestedDays('2026-11-20', '2026-11-22'), 3);
      expect(rules.requestedDays('2026-03-07', '2026-03-09'), 3);
      expect(
        validate(
          start: '2026-11-19',
          end: '2026-11-24',
          type: LeaveType.sick,
        )[LeaveField.endDate],
        LeaveValidationIssue.balanceExceeded,
      );
      expect(validate(start: '2026-11-19', end: '2026-11-24'), isEmpty);
    },
  );
  test('Start validation uses the company date rather than the UTC date', () {
    final errors = rules.validate(
      type: LeaveType.casual,
      startDate: '2026-11-16',
      endDate: '2026-11-16',
      reason: 'Personal appointments.',
      balance: const LeaveBalanceModel(casual: 8, sick: 5),
      requests: [],
      timezone: 'Asia/Kolkata',
      now: DateTime.utc(2026, 11, 16, 20),
    );
    expect(errors[LeaveField.startDate], LeaveValidationIssue.startInPast);
  });
}
