import 'package:flutter_test/flutter_test.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_action.dart';
import 'package:rebs_hrms/features/dashboard/models/dashboard_snapshot_model.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_record_model.dart';
import 'package:rebs_hrms/features/attendance/services/attendance_rules_service.dart';
import 'package:rebs_hrms/features/attendance/services/attendance_summary_service.dart';
import 'package:rebs_hrms/features/attendance/states/attendance_state.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_sync_status.dart';
import 'support/dashboard_fixture.dart';
import 'support/attendance_fixture.dart';

void main() {
  final rules = AttendanceRulesService();
  test('Check-out without check-in is rejected', () {
    expect(
      () => rules.validateAction(AttendanceAction.checkOut, null),
      throwsA(
        isA<AttendanceRuleException>().having(
          (error) => error.feedback,
          'reason',
          AttendanceFeedback.checkInRequired,
        ),
      ),
    );
  });
  test('Another check-in after a completed session is rejected', () {
    expect(
      () => rules.validateAction(
        AttendanceAction.checkIn,
        dashboardFixture().attendance.single,
      ),
      throwsA(
        isA<AttendanceRuleException>().having(
          (error) => error.feedback,
          'reason',
          AttendanceFeedback.alreadyCheckedOut,
        ),
      ),
    );
  });
  test(
    'Inside-office locations pass and outside-office locations are rejected',
    () {
      final now = DateTime.now().toUtc();
      final office = dashboardFixture().employee.office;
      rules.validateLocation(
        attendanceFixture(at: now, latitude: 12.9726).location,
        office,
        now,
      );
      expect(
        () => rules.validateLocation(
          attendanceFixture(at: now, latitude: 12.9746).location,
          office,
          now,
        ),
        throwsA(
          isA<AttendanceRuleException>().having(
            (error) => error.feedback,
            'reason',
            AttendanceFeedback.outsideOffice,
          ),
        ),
      );
    },
  );
  test('A stale GPS fix and a changed company day are rejected', () {
    final now = DateTime.now().toUtc();
    expect(
      () => rules.validateLocation(
        attendanceFixture(
          at: now.subtract(const Duration(minutes: 3)),
        ).location,
        dashboardFixture().employee.office,
        now,
      ),
      throwsA(isA<AttendanceRuleException>()),
    );
    expect(
      () => rules.validateDay(
        '2026-11-16',
        DateTime.utc(2026, 11, 16, 20),
        'Asia/Kolkata',
      ),
      throwsA(
        isA<AttendanceRuleException>().having(
          (error) => error.feedback,
          'reason',
          AttendanceFeedback.dayChanged,
        ),
      ),
    );
  });
  test(
    'Pending actions merge as one session and rejected actions do not change attendance',
    () {
      final data = dashboardFixture(empty: true);
      final time = DateTime.utc(2026, 11, 17, 4);
      final checkIn = attendanceFixture(at: time);
      final checkOut = attendanceFixture(
        id: 'checkout',
        sessionId: checkIn.id,
        action: AttendanceAction.checkOut,
        at: time.add(const Duration(hours: 1)),
      );
      final summary = AttendanceSummaryService().summarize(data, [
        checkIn,
        checkOut,
      ], now: time.add(const Duration(hours: 2)));
      expect(summary.dashboard.attendance, hasLength(1));
      expect(summary.today!.syncStatus, AttendanceSyncStatus.pending);
      expect(summary.duration, const Duration(hours: 1));
      expect(summary.canCheckIn || summary.canCheckOut, isFalse);
      final rejected = AttendanceSummaryService().summarize(data, [
        checkIn.withStatus(AttendanceSyncStatus.rejected),
      ], now: time);
      expect(rejected.today, isNull);
      expect(rejected.canCheckIn, isTrue);
    },
  );
  test(
    'An unacknowledged event remains pending even after the server history contains it',
    () {
      final time = DateTime.utc(2026, 11, 17, 4);
      final event = attendanceFixture(at: time);
      final base = dashboardFixture(empty: true);
      final data = DashboardSnapshotModel(
        employee: base.employee,
        leaveBalance: base.leaveBalance,
        savedAt: time,
        attendance: [
          AttendanceRecordModel(
            id: event.id,
            date: event.companyDate,
            checkIn: time,
          ),
        ],
      );
      expect(
        AttendanceSummaryService()
            .summarize(data, [event], now: time)
            .today!
            .syncStatus,
        AttendanceSyncStatus.pending,
      );
    },
  );
  test('Previous-day attendance does not allow an overnight check-out', () {
    final checkIn = attendanceFixture(at: DateTime.utc(2026, 11, 16, 10));
    final summary = AttendanceSummaryService().summarize(
      dashboardFixture(empty: true),
      [checkIn],
      now: DateTime.utc(2026, 11, 17, 10),
    );
    expect(summary.today, isNull);
    expect(summary.canCheckOut, isFalse);
  });
}
