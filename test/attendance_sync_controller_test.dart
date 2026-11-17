import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:rebs_hrms/core/storage/local_storage_service.dart';
import 'package:rebs_hrms/features/attendance/controllers/attendance_sync_controller.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_action.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_event_model.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_sync_status.dart';
import 'package:rebs_hrms/features/attendance/services/attendance_cache_service.dart';
import 'package:rebs_hrms/features/attendance/states/attendance_sync_state.dart';

import '../tool/mock_api.dart';
import 'support/attendance_fixture.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const methodChannel = MethodChannel('dev.fluttercommunity.plus/connectivity');
  const eventChannel = EventChannel(
    'dev.fluttercommunity.plus/connectivity_status',
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final originalHttpOverrides = HttpOverrides.current;
  final cache = AttendanceCacheService();
  late Directory directory;
  late MockApiServer server;
  AttendanceSyncController? controller;
  late MockStreamHandlerEventSink networkEvents;
  var connected = true;

  Future<void> saveSession() async {
    final now = DateTime.now().toUtc();
    final checkIn = attendanceFixture(
      at: now.subtract(const Duration(seconds: 1)),
    );
    await cache.save(checkIn);
    await cache.save(
      attendanceFixture(
        id: 'checkout',
        sessionId: checkIn.id,
        action: AttendanceAction.checkOut,
        at: now,
      ),
    );
  }

  setUp(() async {
    HttpOverrides.global = null;
    connected = true;
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    directory = await Directory.systemTemp.createTemp('rebs-sync-controller-');
    Hive.init(directory.path);
    LocalStorageService.registerAdapters();
    await Hive.openBox<AttendanceEventModel>(AttendanceCacheService.boxName);
    server = MockApiServer();
    await server.start(port: 0);
    messenger.setMockMethodCallHandler(
      methodChannel,
      (_) async => [connected ? 'wifi' : 'none'],
    );
    messenger.setMockStreamHandler(
      eventChannel,
      MockStreamHandler.inline(onListen: (_, events) => networkEvents = events),
    );
  });

  tearDown(() async {
    controller?.dispose();
    controller = null;
    await Future<void>.delayed(Duration.zero);
    await server.close();
    await Hive.close();
    await directory.delete(recursive: true);
    HttpOverrides.global = originalHttpOverrides;
  });

  test(
    'Connectivity restoration automatically synchronizes a saved offline session',
    () async {
      connected = false;
      await saveSession();
      controller = AttendanceSyncController(
        baseUrl: 'http://127.0.0.1:${server.port}',
      );
      await waitUntil(
        () => !controller!.state.isLoading && !controller!.state.isSyncing,
      );
      expect(controller!.state.pendingCount, 2);
      expect(controller!.state.feedback, SyncFeedback.offline);
      expect(server.receivedAttendanceEvents, isEmpty);
      connected = true;
      networkEvents.success(['wifi']);
      await waitUntil(
        () =>
            controller!.state.pendingCount == 0 && !controller!.state.isSyncing,
      );
      expect(
        (await cache.read()).every(
          (event) => event.status == AttendanceSyncStatus.synced,
        ),
        isTrue,
      );
      expect(server.receivedAttendanceEvents.map((event) => event.action), [
        AttendanceAction.checkIn,
        AttendanceAction.checkOut,
      ]);
    },
  );

  test('App startup processes pending attendance restored from disk', () async {
    await saveSession();
    await Hive.close();
    await Hive.openBox<AttendanceEventModel>(AttendanceCacheService.boxName);
    controller = AttendanceSyncController(
      baseUrl: 'http://127.0.0.1:${server.port}',
    );
    await waitUntil(
      () => !controller!.state.isLoading && !controller!.state.isSyncing,
    );
    expect(controller!.state.pendingCount, 0);
    expect(controller!.state.lastSyncedAt, isNotNull);
    expect(server.receivedAttendanceEvents, hasLength(2));
  });

  test(
    'Backend recovery is retried even without a network-interface change',
    () async {
      await saveSession();
      server.scenario = 'server-error';
      controller = AttendanceSyncController(
        baseUrl: 'http://127.0.0.1:${server.port}',
      );
      await waitUntil(
        () => controller!.state.feedback == SyncFeedback.serverUnavailable,
      );
      expect(controller!.state.pendingCount, 2);
      server.scenario = 'success';
      await waitUntil(
        () =>
            controller!.state.pendingCount == 0 && !controller!.state.isSyncing,
        timeout: const Duration(seconds: 8),
      );
      expect(server.receivedAttendanceEvents, hasLength(2));
    },
  );

  test(
    'Background retries pause and app resume processes saved actions',
    () async {
      controller = AttendanceSyncController(
        baseUrl: 'http://127.0.0.1:${server.port}',
      );
      await waitUntil(
        () => !controller!.state.isLoading && !controller!.state.isSyncing,
      );
      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await saveSession();
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(server.receivedAttendanceEvents, isEmpty);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await waitUntil(
        () =>
            controller!.state.pendingCount == 0 && !controller!.state.isSyncing,
      );
      expect(server.receivedAttendanceEvents, hasLength(2));
    },
  );
}

Future<void> waitUntil(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 3),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Synchronization did not reach the expected state');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
