import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../core/helpers/company_clock.dart';
import '../../../core/network/api_exception.dart';
import '../../attendance/models/attendance_record_model.dart';
import '../../attendance/services/attendance_service.dart';
import '../../leave/models/leave_balance_model.dart';
import '../../leave/services/leave_balance_service.dart';
import '../models/dashboard_snapshot_model.dart';
import '../models/employee_model.dart';
import '../services/dashboard_cache_service.dart';
import '../services/dashboard_service.dart';
import '../states/dashboard_state.dart';

class DashboardController extends ChangeNotifier {
  DashboardController() {
    _lifecycle = AppLifecycleListener(onResume: _resume, onPause: _pause);
    _startClock();
    load();
  }

  final _dashboardService = DashboardService();
  final _attendanceService = AttendanceService();
  final _leaveBalanceService = LeaveBalanceService();
  final _cacheService = DashboardCacheService();
  late final AppLifecycleListener _lifecycle;
  Timer? _clock;
  bool _disposed = false;
  bool _busy = false;
  bool _cacheRead = false;
  String? _lastCompanyDate;
  DashboardState _state = const DashboardState();

  DashboardState get state => _state;

  AttendanceRecordModel? get todayRecord {
    final data = _state.data;
    if (data == null) return null;
    final date = CompanyClock.dateKey(
      DateTime.now(),
      data.employee.office.timezone,
    );
    for (final record in data.attendance) {
      if (record.date == date) return record;
    }
    return null;
  }

  Duration get workingDuration {
    final record = todayRecord;
    if (record == null) return Duration.zero;
    final now = DateTime.now().toUtc();
    final end = record.checkOut ?? now;
    return end.isBefore(record.checkIn)
        ? Duration.zero
        : end.difference(record.checkIn);
  }

  // Publishes a state only while this controller is active.
  void _publish(DashboardState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  // Restores cached data, refreshes each module and saves a complete snapshot.
  Future<void> load() async {
    if (_busy || _disposed) return;
    _busy = true;
    try {
      var cached = _state.data;
      if (!_cacheRead) {
        try {
          cached = await _cacheService.read();
          _cacheRead = true;
        } catch (_) {
          cached = null;
        }
      }
      _publish(
        DashboardState(
          data: cached,
          isLoading: cached == null,
          isRefreshing: cached != null,
        ),
      );

      final results = await Future.wait<Object>([
        _dashboardService.fetchEmployee(),
        _attendanceService.fetchRecent(),
        _leaveBalanceService.fetchBalance(),
      ]);
      if (_disposed) return;
      final employee = results[0] as EmployeeModel;
      _lastCompanyDate = CompanyClock.dateKey(
        DateTime.now(),
        employee.office.timezone,
      );
      final snapshot = DashboardSnapshotModel(
        employee: employee,
        attendance: results[1] as List<AttendanceRecordModel>,
        leaveBalance: results[2] as LeaveBalanceModel,
        savedAt: DateTime.now().toUtc(),
      );
      DashboardNotice? notice;
      try {
        await _cacheService.save(snapshot);
      } catch (_) {
        notice = DashboardNotice.cacheError;
      }
      _publish(
        DashboardState(data: snapshot, isLoading: false, notice: notice),
      );
    } on ApiException catch (error) {
      final notice = switch (error.failure) {
        ApiFailure.unavailable => DashboardNotice.unavailable,
        ApiFailure.timeout => DashboardNotice.timeout,
        ApiFailure.server => DashboardNotice.serverError,
        ApiFailure.invalidResponse => DashboardNotice.invalidResponse,
      };
      _publish(
        DashboardState(data: _state.data, isLoading: false, notice: notice),
      );
    } catch (_) {
      _publish(
        DashboardState(
          data: _state.data,
          isLoading: false,
          notice: DashboardNotice.invalidResponse,
        ),
      );
    } finally {
      _busy = false;
    }
  }

  // Updates elapsed time and refreshes attendance at a company day boundary.
  void _startClock() {
    _clock?.cancel();
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      final data = _state.data;
      if (data == null || _disposed) return;
      final date = CompanyClock.dateKey(
        DateTime.now(),
        data.employee.office.timezone,
      );
      if (_lastCompanyDate != null && date != _lastCompanyDate) {
        _lastCompanyDate = date;
        load();
      }
      notifyListeners();
    });
  }

  // Refreshes saved information when the employee returns to the app.
  void _resume() {
    _startClock();
    load();
  }

  // Suspends the display clock while the app is in the background.
  void _pause() => _clock?.cancel();

  @override
  void dispose() {
    _disposed = true;
    _clock?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }
}
