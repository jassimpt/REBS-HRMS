import 'package:flutter/material.dart';

import '../../../core/constants/text_constants.dart';
import '../../../core/helpers/company_clock.dart';
import '../../../core/widgets/app_card.dart';
import '../models/leave_request_model.dart';
import 'leave_status_badge.dart';

class LeaveRequestItem extends StatelessWidget {
  const LeaveRequestItem({required this.request, super.key});
  final LeaveRequestModel request;

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
                TextConstants.leaveRequestTitle(request.type.name),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              LeaveStatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            TextConstants.leaveDateRange(
              CompanyClock.calendarDate(request.startDate),
              CompanyClock.calendarDate(request.endDate),
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            TextConstants.leaveDays(request.days),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(request.reason, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
