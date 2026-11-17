import '../../../core/network/api_exception.dart';
import '../models/leave_snapshot_model.dart';

class LeaveRequestsState {
  const LeaveRequestsState({
    this.data,
    this.isLoading = true,
    this.isRefreshing = false,
    this.failure,
    this.cacheError = false,
  });

  final LeaveSnapshotModel? data;
  final bool isLoading;
  final bool isRefreshing;
  final ApiFailure? failure;
  final bool cacheError;
}
