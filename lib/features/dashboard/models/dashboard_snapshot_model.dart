import 'package:hive/hive.dart';

import '../../attendance/models/attendance_record_model.dart';
import '../../leave/models/leave_balance_model.dart';
import 'employee_model.dart';

part 'dashboard_snapshot_model.g.dart';

@HiveType(typeId: 4)
class DashboardSnapshotModel {
  const DashboardSnapshotModel({
    required this.employee,
    required this.attendance,
    required this.leaveBalance,
    required this.savedAt,
  });

  @HiveField(0)
  final EmployeeModel employee;
  @HiveField(1)
  final List<AttendanceRecordModel> attendance;
  @HiveField(2)
  final LeaveBalanceModel leaveBalance;
  @HiveField(3)
  final DateTime savedAt;
}
