import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/attendance_sync_controller.dart';
import 'attendance_sync_status_card.dart';

class AttendanceSyncPanel extends StatelessWidget {
  const AttendanceSyncPanel({this.hideWhenIdle = false, super.key});

  final bool hideWhenIdle;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AttendanceSyncController>();
    final state = controller.state;
    if (hideWhenIdle &&
        state.pendingCount == 0 &&
        state.rejectedCount == 0 &&
        !state.isSyncing) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: AttendanceSyncStatusCard(state: state, onSync: controller.syncNow),
    );
  }
}
