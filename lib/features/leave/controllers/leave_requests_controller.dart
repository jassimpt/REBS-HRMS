import 'package:flutter/widgets.dart';

import '../../../core/network/api_exception.dart';
import '../models/leave_balance_model.dart';
import '../models/leave_request_model.dart';
import '../models/leave_snapshot_model.dart';
import '../models/leave_submission_result.dart';
import '../services/leave_balance_service.dart';
import '../services/leave_cache_service.dart';
import '../services/leave_requests_service.dart';
import '../states/leave_requests_state.dart';

class LeaveRequestsController extends ChangeNotifier {
  LeaveRequestsController({String? baseUrl})
    : _requests = LeaveRequestsService(baseUrl: baseUrl),
      _balance = LeaveBalanceService(baseUrl: baseUrl) {
    _lifecycle = AppLifecycleListener(onResume: load);
    load();
  }

  final LeaveRequestsService _requests;
  final LeaveBalanceService _balance;
  final _cache = LeaveCacheService();
  late final AppLifecycleListener _lifecycle;
  LeaveRequestsState _state = const LeaveRequestsState();
  bool _busy = false;
  bool _disposed = false;
  bool _cacheRead = false;
  bool _reload = false;
  int _revision = 0;

  LeaveRequestsState get state => _state;

  // Publishes leave data only while its controller is active.
  void _publish(LeaveRequestsState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  // Restores cached history before refreshing requests and balance together.
  Future<void> load() async {
    if (_busy || _disposed) return;
    _busy = true;
    final revision = _revision;
    try {
      var cached = _state.data;
      if (!_cacheRead) {
        try {
          cached = await _cache.read();
          _cacheRead = true;
        } catch (_) {
          cached = _state.data;
        }
      }
      _publish(
        LeaveRequestsState(
          data: cached,
          isLoading: cached == null,
          isRefreshing: cached != null,
        ),
      );
      final results = await Future.wait<Object>([
        _requests.fetchRequests(),
        _balance.fetchBalance(),
      ]);
      if (_disposed) return;
      if (revision != _revision) {
        _reload = true;
        return;
      }
      final snapshot = LeaveSnapshotModel(
        requests: results[0] as List<LeaveRequestModel>,
        balance: results[1] as LeaveBalanceModel,
        savedAt: DateTime.now().toUtc(),
      );
      var cacheError = false;
      try {
        await _cache.save(snapshot);
      } catch (_) {
        cacheError = true;
      }
      if (revision != _revision) {
        _reload = true;
        return;
      }
      _publish(
        LeaveRequestsState(
          data: snapshot,
          isLoading: false,
          cacheError: cacheError,
        ),
      );
    } on ApiException catch (error) {
      _publish(
        LeaveRequestsState(
          data: _state.data,
          isLoading: false,
          failure: error.failure,
        ),
      );
    } catch (_) {
      _publish(
        LeaveRequestsState(
          data: _state.data,
          isLoading: false,
          failure: ApiFailure.invalidResponse,
        ),
      );
    } finally {
      _busy = false;
      if (_reload && !_disposed) {
        _reload = false;
        load();
      }
    }
  }

  // Applies a confirmed application immediately without losing an in-flight refresh.
  Future<void> addSubmitted(LeaveSubmissionResult result) async {
    if (_disposed) return;
    _revision++;
    final requests = [
      ...?_state.data?.requests.where(
        (request) => request.id != result.request.id,
      ),
      result.request,
    ]..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    final snapshot = LeaveSnapshotModel(
      requests: List.unmodifiable(requests),
      balance: result.balance,
      savedAt: DateTime.now().toUtc(),
    );
    _publish(LeaveRequestsState(data: snapshot, isLoading: false));
    try {
      await _cache.save(snapshot);
    } catch (_) {
      _publish(
        LeaveRequestsState(data: snapshot, isLoading: false, cacheError: true),
      );
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _lifecycle.dispose();
    super.dispose();
  }
}
