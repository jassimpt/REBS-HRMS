import 'package:flutter/material.dart';

import '../../../core/constants/text_constants.dart';
import '../../../core/helpers/company_clock.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../attendance/models/attendance_record_model.dart';
import '../models/dashboard_snapshot_model.dart';
import '../../attendance/widgets/attendance_history_item.dart';
import 'employee_card.dart';
import 'leave_balance_card.dart';
import '../../attendance/widgets/today_attendance_card.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({
    required this.data,
    required this.todayRecord,
    required this.workingDuration,
    super.key,
  });

  final DashboardSnapshotModel data;
  final AttendanceRecordModel? todayRecord;
  final Duration workingDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timezone = data.employee.office.timezone;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EmployeeCard(employee: data.employee),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final attendance = TodayAttendanceCard(
              record: todayRecord,
              timezone: timezone,
              duration: workingDuration,
            );
            final balance = LeaveBalanceCard(balance: data.leaveBalance);
            if (constraints.maxWidth < 800) {
              return Column(
                children: [attendance, const SizedBox(height: 20), balance],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: attendance),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: balance),
              ],
            );
          },
        ),
        const SizedBox(height: 32),
        Text(TextConstants.recentAttendance, style: theme.textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          TextConstants.latestFiveRecords,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        if (data.attendance.isEmpty)
          const AppEmptyState(
            icon: Icons.schedule_rounded,
            title: TextConstants.noAttendanceTitle,
            description: TextConstants.noAttendanceDescription,
          )
        else
          for (final record in data.attendance) ...[
            AttendanceHistoryItem(record: record, timezone: timezone),
            const SizedBox(height: 12),
          ],
        const SizedBox(height: 12),
        Text(
          TextConstants.lastUpdated(CompanyClock.time(data.savedAt, timezone)),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
