import '../../../core/network/api_service.dart';
import '../models/leave_balance_model.dart';

class LeaveBalanceService {
  LeaveBalanceService({String? baseUrl}) : _api = ApiService(baseUrl: baseUrl);
  final ApiService _api;

  // Loads the available casual and sick leave balances.
  Future<LeaveBalanceModel> fetchBalance() async {
    return LeaveBalanceModel.fromJson(await _api.get('/leave/balance'));
  }
}
