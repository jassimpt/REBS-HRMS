import '../../../core/storage/local_storage_service.dart';
import '../models/dashboard_snapshot_model.dart';

class DashboardCacheService {
  static const boxName = 'dashboard_cache';
  static const snapshotKey = 'snapshot';
  final _storage = LocalStorageService();

  // Restores the last complete dashboard snapshot from disk.
  Future<DashboardSnapshotModel?> read() async {
    final box = await _storage.openBox<DashboardSnapshotModel>(boxName);
    return box.get(snapshotKey);
  }

  // Persists a complete snapshot and waits until Hive flushes it to disk.
  Future<void> save(DashboardSnapshotModel snapshot) async {
    final box = await _storage.openBox<DashboardSnapshotModel>(boxName);
    await box.put(snapshotKey, snapshot);
    await box.flush();
  }
}
