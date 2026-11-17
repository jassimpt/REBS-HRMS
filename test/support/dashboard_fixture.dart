import 'package:rebs_hrms/features/attendance/models/attendance_record_model.dart';
import 'package:rebs_hrms/features/dashboard/models/dashboard_snapshot_model.dart';
import 'package:rebs_hrms/features/dashboard/models/employee_model.dart';
import 'package:rebs_hrms/features/dashboard/models/office_model.dart';
import 'package:rebs_hrms/features/leave/models/leave_balance_model.dart';

DashboardSnapshotModel dashboardFixture({bool empty = false}) {
  return DashboardSnapshotModel(
    employee: const EmployeeModel(
      id: 'REBS-1042',
      name: 'Aarav Menon',
      department: 'Engineering',
      designation: 'Flutter Developer',
      office: OfficeModel(
        name: 'Bengaluru Office',
        latitude: 12.9716,
        longitude: 77.5946,
        radiusMetres: 200,
        timezone: 'Asia/Kolkata',
      ),
    ),
    attendance: empty
        ? []
        : [
            AttendanceRecordModel(
              id: 'attendance-2026-11-17',
              date: '2026-11-17',
              checkIn: DateTime.utc(2026, 11, 17, 3, 45),
              checkOut: DateTime.utc(2026, 11, 17, 12),
            ),
          ],
    leaveBalance: const LeaveBalanceModel(casual: 8, sick: 5),
    savedAt: DateTime.utc(2026, 11, 17, 12, 30),
  );
}
