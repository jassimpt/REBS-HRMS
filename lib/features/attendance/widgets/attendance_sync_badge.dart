import 'package:flutter/material.dart';

import '../../../core/constants/text_constants.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../models/attendance_sync_status.dart';

class AttendanceSyncBadge extends StatelessWidget {
  const AttendanceSyncBadge({required this.status, super.key});
  final AttendanceSyncStatus status;

  @override
  Widget build(BuildContext context) {
    return AppStatusBadge(
      label: switch (status) {
        AttendanceSyncStatus.pending => TextConstants.pendingSync,
        AttendanceSyncStatus.synced => TextConstants.synced,
        AttendanceSyncStatus.rejected => TextConstants.rejected,
      },
      tone: status == AttendanceSyncStatus.synced
          ? StatusTone.success
          : StatusTone.warning,
    );
  }
}
