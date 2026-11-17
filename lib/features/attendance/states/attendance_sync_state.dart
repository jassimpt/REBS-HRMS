enum SyncConnection { unknown, offline, available }

enum SyncFeedback {
  idle,
  syncing,
  completed,
  upToDate,
  offline,
  serverUnavailable,
  timeout,
  invalidResponse,
  storageError,
  rejected,
}

class AttendanceSyncState {
  const AttendanceSyncState({
    this.isLoading = true,
    this.isSyncing = false,
    this.pendingCount = 0,
    this.rejectedCount = 0,
    this.connection = SyncConnection.unknown,
    this.feedback = SyncFeedback.idle,
    this.lastSyncedAt,
  });

  final bool isLoading;
  final bool isSyncing;
  final int pendingCount;
  final int rejectedCount;
  final SyncConnection connection;
  final SyncFeedback feedback;
  final DateTime? lastSyncedAt;

  // Updates synchronization details without clearing unrelated state.
  AttendanceSyncState copyWith({
    bool? isLoading,
    bool? isSyncing,
    int? pendingCount,
    int? rejectedCount,
    SyncConnection? connection,
    SyncFeedback? feedback,
    DateTime? lastSyncedAt,
  }) {
    return AttendanceSyncState(
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      pendingCount: pendingCount ?? this.pendingCount,
      rejectedCount: rejectedCount ?? this.rejectedCount,
      connection: connection ?? this.connection,
      feedback: feedback ?? this.feedback,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
