import '../models/dashboard_snapshot_model.dart';

enum DashboardNotice {
  unavailable,
  timeout,
  serverError,
  invalidResponse,
  cacheError,
}

class DashboardState {
  const DashboardState({
    this.data,
    this.isLoading = true,
    this.isRefreshing = false,
    this.notice,
  });

  final DashboardSnapshotModel? data;
  final bool isLoading;
  final bool isRefreshing;
  final DashboardNotice? notice;
}
