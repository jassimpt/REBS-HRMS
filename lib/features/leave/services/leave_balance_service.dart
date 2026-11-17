import '../../../core/network/api_service.dart';
import '../models/leave_balance_model.dart';

class LeaveBalanceService {
  final _api = ApiService();

  // Loads the available casual and sick leave balances.
  Future<LeaveBalanceModel> fetchBalance() async {
    return LeaveBalanceModel.fromJson(await _api.get('/leave/balance'));
  }
}
