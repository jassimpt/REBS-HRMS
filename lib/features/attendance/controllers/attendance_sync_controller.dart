import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/connectivity_service.dart';
import '../models/attendance_sync_status.dart';
import '../services/attendance_cache_service.dart';
import '../services/attendance_sync_service.dart';
import '../states/attendance_sync_state.dart';

class AttendanceSyncController extends ChangeNotifier {
  AttendanceSyncController({String? baseUrl})
    : _service = AttendanceSyncService(baseUrl: baseUrl) {
    _lifecycle = AppLifecycleListener(onResume: _resume, onPause: _pause);
    _initialize();
  }

  final _cache = AttendanceCacheService();
  final AttendanceSyncService _service;
  final _network = ConnectivityService();
  late final AppLifecycleListener _lifecycle;
  StreamSubscription<void>? _queueSubscription;
  StreamSubscription<bool>? _networkSubscription;
  Timer? _retry;
  Future<void>? _running;
  bool _disposed = false;
  bool _foreground = true;
  int _attempt = 0;
  AttendanceSyncState _state = const AttendanceSyncState();

  AttendanceSyncState get state => _state;

  // Restores pending counts and observes durable queue and connectivity changes.
  Future<void> _initialize() async {
    _queueSubscription = _cache.changes.listen((_) => _queueChanged());
    try {
      _networkSubscription = _network.changes.listen(
        _connectionChanged,
        onError: (Object error) =>
            _publish(_state.copyWith(connection: SyncConnection.unknown)),
      );
      final available = await _network.isAvailable();
      if (_disposed) return;
      _publish(
        _state.copyWith(
          connection: available
              ? SyncConnection.available
              : SyncConnection.offline,
        ),
      );
    } catch (_) {
      _publish(_state.copyWith(connection: SyncConnection.unknown));
    }
    await syncNow();
  }

  // Publishes state while this controller remains attached to the app.
  void _publish(AttendanceSyncState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  // Refreshes queue totals after changes have been flushed to Hive.
  Future<void> _refreshCounts() async {
    final events = await _cache.read();
    _publish(
      _state.copyWith(
        pendingCount: events
            .where((event) => event.status == AttendanceSyncStatus.pending)
            .length,
        rejectedCount: events
            .where((event) => event.status == AttendanceSyncStatus.rejected)
            .length,
      ),
    );
  }

  // Schedules newly saved actions without interrupting an existing sync pass.
  Future<void> _queueChanged() async {
    if (_disposed) return;
    try {
      await _refreshCounts();
      if (!_state.isSyncing && _state.pendingCount > 0 && _retry == null) {
        _schedule(const Duration(milliseconds: 300));
      }
    } catch (_) {
      _publish(
        _state.copyWith(isLoading: false, feedback: SyncFeedback.storageError),
      );
    }
  }

  // Attempts a shared sync pass for manual, reconnect and startup triggers.
  Future<void> syncNow() {
    if (_disposed || !_foreground) return Future.value();
    _retry?.cancel();
    _retry = null;
    return _running ??= _synchronize().whenComplete(() => _running = null);
  }

  // Updates delivery state and backs off after retryable API failures.
  Future<void> _synchronize() async {
    _publish(_state.copyWith(isSyncing: true, feedback: SyncFeedback.syncing));
    try {
      await _refreshCounts();
      if (_state.pendingCount == 0) {
        _attempt = 0;
        _publish(
          _state.copyWith(
            isLoading: false,
            isSyncing: false,
            feedback: SyncFeedback.upToDate,
          ),
        );
        return;
      }
      if (_state.connection == SyncConnection.offline) {
        _publish(
          _state.copyWith(
            isLoading: false,
            isSyncing: false,
            feedback: SyncFeedback.offline,
          ),
        );
        return;
      }
      final result = await _service.synchronize();
      if (_disposed) return;
      await _refreshCounts();
      final feedback = result.failure == null
          ? result.rejected > 0
                ? SyncFeedback.rejected
                : SyncFeedback.completed
          : switch (result.failure!) {
              ApiFailure.unavailable => SyncFeedback.serverUnavailable,
              ApiFailure.timeout => SyncFeedback.timeout,
              ApiFailure.server => SyncFeedback.serverUnavailable,
              ApiFailure.invalidResponse => SyncFeedback.invalidResponse,
            };
      _publish(
        _state.copyWith(
          isLoading: false,
          isSyncing: false,
          feedback: feedback,
          lastSyncedAt: result.synced > 0 ? DateTime.now().toUtc() : null,
        ),
      );
      if (result.failure != null) {
        _scheduleRetry();
      } else {
        _attempt = 0;
        if (_state.pendingCount > 0) {
          _schedule(const Duration(milliseconds: 300));
        }
      }
    } catch (_) {
      _publish(
        _state.copyWith(
          isLoading: false,
          isSyncing: false,
          feedback: SyncFeedback.storageError,
        ),
      );
      _scheduleRetry();
    }
  }

  // Starts a foreground retry timer while a network interface is available.
  void _schedule(Duration delay) {
    if (_disposed ||
        !_foreground ||
        _state.connection == SyncConnection.offline) {
      return;
    }
    _retry?.cancel();
    _retry = Timer(delay, () {
      _retry = null;
      syncNow();
    });
  }

  // Uses bounded delays instead of repeatedly hitting an unavailable server.
  void _scheduleRetry() {
    const delays = [5, 15, 30, 60];
    final seconds = delays[_attempt.clamp(0, delays.length - 1)];
    _attempt++;
    _schedule(Duration(seconds: seconds));
  }

  // Triggers synchronization when network connectivity becomes available again.
  void _connectionChanged(bool available) {
    if (_disposed) return;
    _publish(
      _state.copyWith(
        connection: available
            ? SyncConnection.available
            : SyncConnection.offline,
        feedback: !available && _state.pendingCount > 0 && !_state.isSyncing
            ? SyncFeedback.offline
            : null,
      ),
    );
    if (available) {
      _attempt = 0;
      _schedule(const Duration(milliseconds: 300));
    } else {
      _retry?.cancel();
      _retry = null;
    }
  }

  // Rechecks connectivity and saved actions when returning to the app.
  Future<void> _resume() async {
    _foreground = true;
    try {
      _connectionChanged(await _network.isAvailable());
    } catch (_) {
      _publish(_state.copyWith(connection: SyncConnection.unknown));
    }
    await syncNow();
  }

  // Stops scheduled retries while the app is in the background.
  void _pause() {
    _foreground = false;
    _retry?.cancel();
    _retry = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _retry?.cancel();
    _queueSubscription?.cancel();
    _networkSubscription?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }
}
