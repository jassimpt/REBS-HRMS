import 'package:flutter/material.dart';

import '../../../core/constants/text_constants.dart';
import '../../../core/helpers/company_clock.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../models/attendance_record_model.dart';
import 'attendance_sync_badge.dart';
import 'attendance_metric.dart';

class TodayAttendanceCard extends StatelessWidget {
  const TodayAttendanceCard({
    required this.record,
    required this.timezone,
    required this.duration,
    super.key,
  });

  final AttendanceRecordModel? record;
  final String timezone;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = record == null
        ? TextConstants.notCheckedIn
        : record!.checkOut == null
        ? TextConstants.checkedIn
        : TextConstants.checkedOut;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TextConstants.todayAttendance,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            CompanyClock.date(CompanyClock.dateKey(DateTime.now(), timezone)),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          AppStatusBadge(
            label: status,
            tone: record == null ? StatusTone.neutral : StatusTone.success,
          ),
          if (record != null) ...[
            const SizedBox(height: 10),
            AttendanceSyncBadge(status: record!.syncStatus),
          ],
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth >= 380
                  ? (constraints.maxWidth - 32) / 3
                  : constraints.maxWidth;
              return Wrap(
                spacing: 16,
                runSpacing: 20,
                children: [
                  SizedBox(
                    width: width,
                    child: AttendanceMetric(
                      label: TextConstants.checkIn,
                      value: CompanyClock.time(record?.checkIn, timezone),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: AttendanceMetric(
                      label: TextConstants.checkOut,
                      value: CompanyClock.time(record?.checkOut, timezone),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: AttendanceMetric(
                      label: TextConstants.workingTime,
                      value: CompanyClock.duration(duration),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            TextConstants.timezone(timezone),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
