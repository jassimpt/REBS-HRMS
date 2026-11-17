import 'dart:io';
import 'package:hive/hive.dart';
import 'package:rebs_hrms/core/storage/local_storage_service.dart';
import 'package:rebs_hrms/features/dashboard/models/dashboard_snapshot_model.dart';
import 'package:rebs_hrms/features/dashboard/services/dashboard_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rebs_hrms/app/app.dart';
import 'package:rebs_hrms/core/constants/text_constants.dart';
import 'package:rebs_hrms/features/dashboard/screens/dashboard_screen.dart';
import 'package:rebs_hrms/features/attendance/screens/attendance_screen.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_event_model.dart';
import 'package:rebs_hrms/features/attendance/services/attendance_cache_service.dart';

void main() {
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('rebs-workspace-test-');
    Hive.init(directory.path);
    LocalStorageService.registerAdapters();
    await Hive.openBox<DashboardSnapshotModel>(DashboardCacheService.boxName);
    await Hive.openBox<AttendanceEventModel>(AttendanceCacheService.boxName);
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });
  testWidgets('Workspace navigation changes the visible section', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(TextConstants.attendance),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AttendanceScreen), findsOneWidget);
    expect(find.byType(DashboardScreen), findsNothing);

    await tester.tap(find.text(TextConstants.leave));
    await tester.pumpAndSettle();
    expect(find.text(TextConstants.leaveTitle), findsOneWidget);

    await tester.tap(find.text(TextConstants.overview));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  for (final size in [
    const Size(320, 568),
    const Size(667, 375),
    const Size(768, 1024),
    const Size(1366, 768),
  ]) {
    testWidgets('Workspace fits $size with enlarged text', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        find.byType(size.width >= 720 ? NavigationRail : NavigationBar),
        findsOneWidget,
      );
      await tester.tap(find.text(TextConstants.leave));
      await tester.pumpAndSettle();
      expect(find.text(TextConstants.leaveTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
