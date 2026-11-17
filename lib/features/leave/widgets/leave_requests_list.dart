import 'package:flutter/material.dart';

import '../../../core/constants/text_constants.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../models/leave_request_model.dart';
import 'leave_request_item.dart';

class LeaveRequestsList extends StatelessWidget {
  const LeaveRequestsList({required this.requests, super.key});
  final List<LeaveRequestModel> requests;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(TextConstants.leaveRequests, style: theme.textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          TextConstants.leaveHistorySubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        if (requests.isEmpty)
          const AppEmptyState(
            icon: Icons.event_note_outlined,
            title: TextConstants.noLeaveTitle,
            description: TextConstants.noLeaveDescription,
          )
        else
          for (final request in requests) ...[
            LeaveRequestItem(request: request),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}
