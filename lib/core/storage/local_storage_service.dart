import 'package:hive_flutter/hive_flutter.dart';

import '../../features/attendance/models/attendance_record_model.dart';
import '../../features/attendance/models/attendance_action.dart';
import '../../features/attendance/models/attendance_sync_status.dart';
import '../../features/attendance/models/attendance_event_model.dart';
import '../../features/attendance/models/attendance_location_model.dart';
import '../../features/dashboard/models/dashboard_snapshot_model.dart';
import '../../features/dashboard/models/employee_model.dart';
import '../../features/dashboard/models/office_model.dart';
import '../../features/leave/models/leave_balance_model.dart';
import '../../features/leave/models/leave_type.dart';
import '../../features/leave/models/leave_request_status.dart';
import '../../features/leave/models/leave_request_model.dart';
import '../../features/leave/models/leave_snapshot_model.dart';

class LocalStorageService {
  static Future<void>? _initialization;

  // Registers generated adapters while preserving their stable type IDs.
  static void registerAdapters() {
    registerAttendanceAdapters();
    registerLeaveAdapters();
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

  // Registers attendance event adapters without changing existing type IDs.
  static void registerAttendanceAdapters() {
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(AttendanceEventModelAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(AttendanceActionAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(AttendanceSyncStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(AttendanceLocationModelAdapter());
    }
  }

  // Registers typed leave history adapters using new stable type IDs.
  static void registerLeaveAdapters() {
    if (!Hive.isAdapterRegistered(9)) Hive.registerAdapter(LeaveTypeAdapter());
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(LeaveRequestStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(LeaveRequestModelAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(LeaveSnapshotModelAdapter());
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
