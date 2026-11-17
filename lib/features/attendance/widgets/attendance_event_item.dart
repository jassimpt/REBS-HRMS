import 'package:flutter/material.dart';

import '../../../core/constants/text_constants.dart';
import '../../../core/helpers/company_clock.dart';
import '../../../core/widgets/app_card.dart';
import '../models/attendance_action.dart';
import '../models/attendance_event_model.dart';
import '../models/attendance_sync_status.dart';
import 'attendance_sync_badge.dart';

class AttendanceEventItem extends StatelessWidget {
  const AttendanceEventItem({
    required this.event,
    required this.timezone,
    super.key,
  });

  final AttendanceEventModel event;
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
                event.action == AttendanceAction.checkIn
                    ? TextConstants.checkIn
                    : TextConstants.checkOut,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              AttendanceSyncBadge(status: event.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${CompanyClock.date(event.companyDate)} · ${CompanyClock.time(event.occurredAt, timezone)}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            TextConstants.coordinates(
              event.location.latitude,
              event.location.longitude,
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (event.status == AttendanceSyncStatus.rejected) ...[
            const SizedBox(height: 12),
            Text(
              TextConstants.attendanceRejectionReason(event.rejectionCode),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
