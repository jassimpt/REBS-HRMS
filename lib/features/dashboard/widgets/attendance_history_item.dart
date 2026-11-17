import 'package:flutter/material.dart';

import '../../../core/constants/text_constants.dart';
import '../../../core/helpers/company_clock.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../../attendance/models/attendance_record_model.dart';
import 'attendance_metric.dart';

class AttendanceHistoryItem extends StatelessWidget {
  const AttendanceHistoryItem({
    required this.record,
    required this.timezone,
    super.key,
  });

  final AttendanceRecordModel record;
  final String timezone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                CompanyClock.date(record.date),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const AppStatusBadge(
                label: TextConstants.synced,
                tone: StatusTone.success,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth >= 380
                  ? (constraints.maxWidth - 32) / 3
                  : constraints.maxWidth;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: width,
                    child: AttendanceMetric(
                      label: TextConstants.checkIn,
                      value: CompanyClock.time(record.checkIn, timezone),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: AttendanceMetric(
                      label: TextConstants.checkOut,
                      value: CompanyClock.time(record.checkOut, timezone),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: AttendanceMetric(
                      label: TextConstants.workingTime,
                      value: record.checkOut == null
                          ? TextConstants.inProgress
                          : CompanyClock.duration(
                              record.checkOut!.difference(record.checkIn),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
