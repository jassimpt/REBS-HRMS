import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:rebs_hrms/core/helpers/company_clock.dart';
import 'package:rebs_hrms/core/storage/local_storage_service.dart';
import 'package:rebs_hrms/features/dashboard/models/dashboard_snapshot_model.dart';
import 'package:rebs_hrms/features/dashboard/services/dashboard_cache_service.dart';
import 'support/dashboard_fixture.dart';

void main() {
  test(
    'Generated adapters preserve typed dashboard data after Hive reopens',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'rebs-dashboard-test-',
      );
      Hive.init(directory.path);
      LocalStorageService.registerAdapters();
      await Hive.openBox<DashboardSnapshotModel>(DashboardCacheService.boxName);
      try {
        final cache = DashboardCacheService();
        final original = dashboardFixture();
        await cache.save(original);
        await Hive.close();
        await Hive.openBox<DashboardSnapshotModel>(
          DashboardCacheService.boxName,
        );
        final restored = (await cache.read())!;
        expect(restored.employee.name, original.employee.name);
        expect(restored.employee.office.latitude, 12.9716);
        expect(restored.employee.office.timezone, 'Asia/Kolkata');
        expect(
          restored.attendance.single.checkIn,
          original.attendance.single.checkIn,
        );
        expect(
          restored.attendance.single.checkOut,
          original.attendance.single.checkOut,
        );
        expect(restored.leaveBalance.total, 13);
        expect(restored.savedAt, original.savedAt);
      } finally {
        await Hive.close();
        await directory.delete(recursive: true);
      }
    },
  );
  test('Company day differs from UTC and handles daylight-saving zones', () {
    expect(
      CompanyClock.dateKey(DateTime.utc(2026, 11, 16, 20), 'Asia/Kolkata'),
      '2026-11-17',
    );
    expect(
      CompanyClock.time(DateTime.utc(2026, 7, 1, 12), 'America/New_York'),
      '8:00 AM',
    );
    expect(
      CompanyClock.time(DateTime.utc(2026, 12, 1, 12), 'America/New_York'),
      '7:00 AM',
    );
  });
}
