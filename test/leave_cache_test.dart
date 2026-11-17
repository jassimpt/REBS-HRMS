import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:rebs_hrms/core/storage/local_storage_service.dart';
import 'package:rebs_hrms/features/leave/models/leave_request_status.dart';
import 'package:rebs_hrms/features/leave/models/leave_snapshot_model.dart';
import 'package:rebs_hrms/features/leave/services/leave_cache_service.dart';
import 'support/leave_fixture.dart';

void main() {
  test(
    'Generated Hive adapters preserve every leave status and matching balance after reopen',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'rebs-leave-cache-',
      );
      Hive.init(directory.path);
      LocalStorageService.registerAdapters();
      await Hive.openBox<LeaveSnapshotModel>(LeaveCacheService.boxName);
      try {
        final data = leaveSnapshotFixture(
          requests: [
            for (final status in LeaveRequestStatus.values)
              leaveRequestFixture(id: status.name, status: status),
          ],
        );
        final cache = LeaveCacheService();
        await cache.save(data);
        await Hive.close();
        await Hive.openBox<LeaveSnapshotModel>(LeaveCacheService.boxName);
        final restored = (await cache.read())!;
        expect(
          restored.requests.map((request) => request.status),
          LeaveRequestStatus.values,
        );
        expect(restored.requests.first.reason, data.requests.first.reason);
        expect(restored.requests.first.days, 2);
        expect(restored.balance.casual, 8);
        expect(restored.balance.sick, 5);
      } finally {
        await Hive.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
