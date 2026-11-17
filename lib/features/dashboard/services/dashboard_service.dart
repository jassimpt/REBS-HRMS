import '../../../core/network/api_service.dart';
import '../models/employee_model.dart';

class DashboardService {
  final _api = ApiService();

  // Loads employee details and configurable office settings.
  Future<EmployeeModel> fetchEmployee() async {
    return EmployeeModel.fromJson(await _api.get('/employee/me'));
  }
}
