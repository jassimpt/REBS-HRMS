import 'dart:io';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:rebs_hrms/core/network/api_exception.dart';
import 'package:rebs_hrms/core/network/api_service.dart';
import 'package:rebs_hrms/core/storage/local_storage_service.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_action.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_event_model.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_sync_status.dart';
import 'package:rebs_hrms/features/attendance/services/attendance_cache_service.dart';
import 'package:rebs_hrms/features/attendance/services/attendance_sync_service.dart';

import '../tool/mock_api.dart';
import 'support/attendance_fixture.dart';

void main() {
  late Directory directory;
  late MockApiServer server;
  late AttendanceSyncService service;
  late AttendanceEventModel checkIn;
  late AttendanceEventModel checkOut;
  final cache = AttendanceCacheService();

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('rebs-sync-test-');
    Hive.init(directory.path);
    LocalStorageService.registerAdapters();
    await Hive.openBox<AttendanceEventModel>(AttendanceCacheService.boxName);
    server = MockApiServer();
    await server.start(port: 0);
    service = AttendanceSyncService(baseUrl: 'http://127.0.0.1:${server.port}');
    final now = DateTime.now().toUtc();
    checkIn = attendanceFixture(at: now.subtract(const Duration(seconds: 1)));
    checkOut = attendanceFixture(
      id: 'checkout',
      sessionId: checkIn.id,
      action: AttendanceAction.checkOut,
      at: now,
    );
  });
  tearDown(() async {
    await server.close();
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test(
    'Persisted events synchronize check-in before checkout after Hive reopens',
    () async {
      await cache.save(checkOut);
      await cache.save(checkIn);
      await Hive.close();
      await Hive.openBox<AttendanceEventModel>(AttendanceCacheService.boxName);
      final result = await service.synchronize();
      expect(result.synced, 2);
      expect(server.receivedAttendanceEvents.map((event) => event.id), [
        checkIn.id,
        checkOut.id,
      ]);
      expect(
        (await cache.read()).every(
          (event) => event.status == AttendanceSyncStatus.synced,
        ),
        isTrue,
      );
      final api = ApiService(baseUrl: 'http://127.0.0.1:${server.port}');
      final records = (await api.get('/attendance'))['records'] as List;
      expect(
        records.where((record) => record['date'] == checkIn.companyDate),
        hasLength(1),
      );
      expect(records.first['check_out'], checkOut.toJson()['occurred_at']);
    },
  );

  test(
    'Overlapping synchronization triggers share one pass and one HTTP submission per event',
    () async {
      await cache.save(checkIn);
      await cache.save(checkOut);
      final first = service.synchronize();
      final second = service.synchronize();
      expect(identical(first, second), isTrue);
      await Future.wait([first, second]);
      expect(server.receivedAttendanceEvents, hasLength(2));
      expect((await service.synchronize()).synced, 0);
      expect(server.receivedAttendanceEvents, hasLength(2));
    },
  );

  test(
    'A rejected check-in rejects its checkout without sending that checkout',
    () async {
      server.scenario = 'duplicate-attendance';
      await cache.save(checkIn);
      await cache.save(checkOut);
      final result = await service.synchronize();
      expect(result.rejected, 2);
      expect(server.receivedAttendanceEvents.map((event) => event.action), [
        AttendanceAction.checkIn,
      ]);
      final events = await cache.read();
      expect(
        events.every((event) => event.status == AttendanceSyncStatus.rejected),
        isTrue,
      );
      expect(events.last.rejectionCode, 'check_in_rejected');
      await service.synchronize();
      expect(server.receivedAttendanceEvents, hasLength(1));
    },
  );

  test(
    'A server failure preserves the queue and prevents checkout from overtaking check-in',
    () async {
      server.scenario = 'server-error';
      await cache.save(checkIn);
      await cache.save(checkOut);
      final result = await service.synchronize();
      expect(result.failure, ApiFailure.server);
      expect(
        (await cache.read()).every(
          (event) => event.status == AttendanceSyncStatus.pending,
        ),
        isTrue,
      );
      server.scenario = 'success';
      expect((await service.synchronize()).synced, 2);
      expect(server.receivedAttendanceEvents.map((event) => event.id), [
        checkIn.id,
        checkOut.id,
      ]);
    },
  );

  test(
    'Timeout after acceptance preserves identities and safely retries before checkout',
    () async {
      server.scenario = 'timeout-after-accept';
      await cache.save(checkIn);
      await cache.save(checkOut);
      final result = await service.synchronize();
      expect(result.failure, ApiFailure.timeout);
      expect(server.receivedAttendanceEvents, hasLength(1));
      expect((await cache.read()).first.toJson(), checkIn.toJson());
      await Hive.close();
      await Hive.openBox<AttendanceEventModel>(AttendanceCacheService.boxName);
      server.scenario = 'success';
      expect((await service.synchronize()).synced, 2);
      expect(server.receivedAttendanceEvents.map((event) => event.id), [
        checkIn.id,
        checkIn.id,
        checkOut.id,
      ]);
      expect(
        server.receivedAttendanceEvents[1].toJson(),
        server.receivedAttendanceEvents.first.toJson(),
      );
    },
  );

  test(
    'Legacy microsecond payloads remain idempotent after a client restart',
    () async {
      await server.close();
      final payload = checkIn.toJson();
      payload['occurred_at'] = checkIn.occurredAt.toIso8601String();
      payload['location'] = {
        ...checkIn.location.toJson(),
        'captured_at': checkIn.location.capturedAt.toIso8601String(),
      };
      final path = '${directory.path}/legacy-server.json';
      await File(path).writeAsString(
        jsonEncode({
          checkIn.id: {
            'payload': payload,
            'record': {
              'id': checkIn.id,
              'date': checkIn.companyDate,
              'check_in': checkIn.occurredAt.toIso8601String(),
              'check_out': null,
            },
          },
        }),
      );
      server = MockApiServer(storagePath: path);
      await server.start(port: 0);
      service = AttendanceSyncService(
        baseUrl: 'http://127.0.0.1:${server.port}',
      );
      await cache.save(checkIn);
      await Hive.close();
      await Hive.openBox<AttendanceEventModel>(AttendanceCacheService.boxName);
      final result = await service.synchronize();
      expect(result.synced, 1);
      expect(result.rejected, 0);
      expect((await cache.read()).single.status, AttendanceSyncStatus.synced);
    },
  );

  test('A newly queued checkout is picked up during a running pass', () async {
    server.scenario = 'slow';
    await cache.save(checkIn);
    final running = service.synchronize();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await cache.save(checkOut);
    server.scenario = 'success';
    await running;
    expect(
      (await cache.read()).every(
        (event) => event.status == AttendanceSyncStatus.synced,
      ),
      isTrue,
    );
    expect(server.receivedAttendanceEvents.map((event) => event.id), [
      checkIn.id,
      checkOut.id,
    ]);
  });
}
