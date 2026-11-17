import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:rebs_hrms/core/storage/local_storage_service.dart';
import 'package:rebs_hrms/features/attendance/controllers/attendance_controller.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_action.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_event_model.dart';
import 'package:rebs_hrms/features/attendance/services/attendance_cache_service.dart';
import 'support/dashboard_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter.baseflow.com/geolocator');

  test(
    'Rapid repeated taps acquire GPS once and persist only one event',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'rebs-controller-test-',
      );
      Hive.init(directory.path);
      LocalStorageService.registerAdapters();
      await Hive.openBox<AttendanceEventModel>(AttendanceCacheService.boxName);
      final captured = Completer<Map<String, dynamic>>();
      final requested = Completer<void>();
      var gpsCalls = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            switch (call.method) {
              case 'isLocationServiceEnabled':
                return true;
              case 'checkPermission':
                return 2;
              case 'getCurrentPosition':
                gpsCalls++;
                if (!requested.isCompleted) requested.complete();
                return captured.future;
              default:
                return true;
            }
          });
      final controller = AttendanceController();
      try {
        await controller.load();
        final first = controller.submit(
          AttendanceAction.checkIn,
          dashboardFixture(empty: true),
        );
        await requested.future;
        final repeated = await controller.submit(
          AttendanceAction.checkIn,
          dashboardFixture(empty: true),
        );
        expect(repeated, isFalse);
        captured.complete({
          'latitude': 12.9716,
          'longitude': 77.5946,
          'accuracy': 5.0,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        await first;
        expect(gpsCalls, 1);
        expect(await AttendanceCacheService().read(), hasLength(1));
      } finally {
        controller.dispose();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
        await Hive.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
