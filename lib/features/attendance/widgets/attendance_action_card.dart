import 'package:flutter/material.dart';

import '../../../core/constants/text_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../models/attendance_action.dart';
import '../states/attendance_summary_state.dart';

class AttendanceActionCard extends StatelessWidget {
  const AttendanceActionCard({
    required this.summary,
    required this.isBusy,
    required this.onAction,
    super.key,
  });

  final AttendanceSummaryState summary;
  final bool isBusy;
  final ValueChanged<AttendanceAction> onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary.dashboard.employee.office.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            TextConstants.officeRadius(
              summary.dashboard.employee.office.radiusMetres.round(),
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          if (isBusy) ...[
            const LinearProgressIndicator(
              semanticsLabel: TextConstants.recordingAttendance,
            ),
            const SizedBox(height: 12),
            const Text(TextConstants.recordingAttendance),
            const SizedBox(height: 16),
          ],
          if (!summary.canCheckIn && !summary.canCheckOut)
            const Text(TextConstants.attendanceComplete)
          else
            FilledButton.icon(
              onPressed: isBusy
                  ? null
                  : () => onAction(
                      summary.canCheckIn
                          ? AttendanceAction.checkIn
                          : AttendanceAction.checkOut,
                    ),
              icon: Icon(
                summary.canCheckIn ? Icons.login_rounded : Icons.logout_rounded,
              ),
              label: Text(
                summary.canCheckIn
                    ? TextConstants.checkIn
                    : TextConstants.checkOut,
              ),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
            ),
        ],
      ),
    );
  }
}
