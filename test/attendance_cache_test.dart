import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:rebs_hrms/core/storage/local_storage_service.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_action.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_event_model.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_sync_status.dart';
import 'package:rebs_hrms/features/attendance/services/attendance_cache_service.dart';
import 'support/attendance_fixture.dart';

void main() {
  test(
    'Pending event identities, GPS and ordering survive Hive close/reopen',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'rebs-attendance-test-',
      );
      Hive.init(directory.path);
      LocalStorageService.registerAdapters();
      await Hive.openBox<AttendanceEventModel>(AttendanceCacheService.boxName);
      try {
        final cache = AttendanceCacheService();
        final checkIn = attendanceFixture(at: DateTime.utc(2026, 11, 17, 4));
        final checkOut = attendanceFixture(
          id: 'checkout',
          sessionId: checkIn.id,
          action: AttendanceAction.checkOut,
          at: DateTime.utc(2026, 11, 17, 5),
        );
        await cache.save(checkOut);
        await cache.save(checkIn);
        await Hive.close();
        await Hive.openBox<AttendanceEventModel>(
          AttendanceCacheService.boxName,
        );
        final events = await cache.read();
        expect(events.map((event) => event.id), [checkIn.id, checkOut.id]);
        expect(
          events.every((event) => event.status == AttendanceSyncStatus.pending),
          isTrue,
        );
        expect(events.first.location.latitude, 12.9716);
        expect(events.last.sessionId, events.first.id);
        await cache.save(events.first.withStatus(AttendanceSyncStatus.synced));
        expect(await cache.read(), hasLength(2));
      } finally {
        await Hive.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
