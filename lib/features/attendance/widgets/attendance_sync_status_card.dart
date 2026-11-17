import 'package:flutter/material.dart';

import '../../../core/constants/text_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../states/attendance_sync_state.dart';

class AttendanceSyncStatusCard extends StatelessWidget {
  const AttendanceSyncStatusCard({
    required this.state,
    required this.onSync,
    super.key,
  });

  final AttendanceSyncState state;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = state.isLoading
        ? TextConstants.syncRestoring
        : state.isSyncing
        ? TextConstants.syncInProgress
        : state.connection == SyncConnection.offline
        ? TextConstants.syncOffline
        : switch (state.feedback) {
            SyncFeedback.idle =>
              state.pendingCount > 0
                  ? TextConstants.syncPending
                  : TextConstants.syncUpToDate,
            SyncFeedback.syncing => TextConstants.syncInProgress,
            SyncFeedback.completed || SyncFeedback.upToDate =>
              state.pendingCount > 0
                  ? TextConstants.syncPending
                  : TextConstants.syncUpToDate,
            SyncFeedback.offline => TextConstants.syncOffline,
            SyncFeedback.serverUnavailable =>
              TextConstants.syncServerUnavailable,
            SyncFeedback.timeout => TextConstants.syncTimedOut,
            SyncFeedback.invalidResponse => TextConstants.syncInvalidResponse,
            SyncFeedback.storageError => TextConstants.syncStorageError,
            SyncFeedback.rejected => TextConstants.syncRejected,
          };
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TextConstants.attendanceSync,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (state.pendingCount > 0 || state.rejectedCount > 0) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (state.pendingCount > 0)
                  AppStatusBadge(
                    label: TextConstants.pendingActions(state.pendingCount),
                    tone: StatusTone.warning,
                  ),
                if (state.rejectedCount > 0)
                  AppStatusBadge(
                    label: TextConstants.rejectedActions(state.rejectedCount),
                    tone: StatusTone.warning,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          if (state.isSyncing) ...[
            const LinearProgressIndicator(
              semanticsLabel: TextConstants.syncInProgress,
            ),
            const SizedBox(height: 16),
          ],
          OutlinedButton.icon(
            onPressed:
                state.isLoading || state.isSyncing || state.pendingCount == 0
                ? null
                : onSync,
            icon: const Icon(Icons.sync_rounded),
            label: const Text(TextConstants.syncNow),
          ),
        ],
      ),
    );
  }
}
