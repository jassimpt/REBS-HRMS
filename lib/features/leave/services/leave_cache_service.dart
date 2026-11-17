import '../../../core/storage/local_storage_service.dart';
import '../models/leave_snapshot_model.dart';

class LeaveCacheService {
  static const boxName = 'leave_cache';
  static const snapshotKey = 'snapshot';
  final _storage = LocalStorageService();

  // Restores the last complete leave history and balance for offline viewing.
  Future<LeaveSnapshotModel?> read() async {
    final box = await _storage.openBox<LeaveSnapshotModel>(boxName);
    return box.get(snapshotKey);
  }

  // Saves history and its matching balance as one typed Hive entry.
  Future<void> save(LeaveSnapshotModel snapshot) async {
    final box = await _storage.openBox<LeaveSnapshotModel>(boxName);
    await box.put(snapshotKey, snapshot);
    await box.flush();
  }
}
