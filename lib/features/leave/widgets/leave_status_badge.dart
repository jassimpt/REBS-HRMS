import 'package:flutter/material.dart';

import '../../../core/constants/text_constants.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../models/leave_request_status.dart';

class LeaveStatusBadge extends StatelessWidget {
  const LeaveStatusBadge({required this.status, super.key});
  final LeaveRequestStatus status;

  @override
  Widget build(BuildContext context) {
    return AppStatusBadge(
      label: switch (status) {
        LeaveRequestStatus.pending => TextConstants.pending,
        LeaveRequestStatus.approved => TextConstants.approved,
        LeaveRequestStatus.rejected => TextConstants.rejected,
      },
      tone: switch (status) {
        LeaveRequestStatus.pending => StatusTone.warning,
        LeaveRequestStatus.approved => StatusTone.success,
        LeaveRequestStatus.rejected => StatusTone.error,
      },
    );
  }
}
