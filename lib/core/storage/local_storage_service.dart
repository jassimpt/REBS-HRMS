import 'package:hive_flutter/hive_flutter.dart';

import '../../features/attendance/models/attendance_record_model.dart';
import '../../features/dashboard/models/dashboard_snapshot_model.dart';
import '../../features/dashboard/models/employee_model.dart';
import '../../features/dashboard/models/office_model.dart';
import '../../features/leave/models/leave_balance_model.dart';

class LocalStorageService {
  static Future<void>? _initialization;

  // Registers generated adapters while preserving their stable type IDs.
  static void registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(OfficeModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(EmployeeModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(AttendanceRecordModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(LeaveBalanceModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(DashboardSnapshotModelAdapter());
    }
  }

  // Initializes Hive lazily so storage failures can be shown inside the app.
  static Future<void> _initialize() async {
    try {
      await Hive.initFlutter();
      registerAdapters();
    } catch (_) {
      _initialization = null;
      rethrow;
    }
  }

  // Opens a typed box, reusing the existing box when already available.
  Future<Box<T>> openBox<T>(String name) async {
    if (Hive.isBoxOpen(name)) return Hive.box<T>(name);
    await (_initialization ??= _initialize());
    return Hive.openBox<T>(name);
  }
}
