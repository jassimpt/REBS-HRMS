import '../../../core/network/api_exception.dart';

class AttendanceSyncResult {
  const AttendanceSyncResult({
    this.synced = 0,
    this.rejected = 0,
    this.failure,
  });

  final int synced;
  final int rejected;
  final ApiFailure? failure;
}
