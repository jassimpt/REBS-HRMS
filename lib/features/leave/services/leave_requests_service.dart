import '../../../core/network/api_exception.dart';
import '../../../core/network/api_service.dart';
import '../models/leave_application_model.dart';
import '../models/leave_balance_model.dart';
import '../models/leave_request_model.dart';
import '../models/leave_submission_result.dart';

class LeaveRequestsService {
  LeaveRequestsService({String? baseUrl}) : _api = ApiService(baseUrl: baseUrl);
  final ApiService _api;

  // Loads leave history through the HTTP API.
  Future<List<LeaveRequestModel>> fetchRequests() async {
    final response = await _api.get('/leave/requests');
    final requests = (response['requests'] as List)
        .map((item) => LeaveRequestModel.fromJson(item as Map<String, dynamic>))
        .toList();
    requests.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return List.unmodifiable(requests);
  }

  // Submits an online application and verifies its request identity.
  Future<LeaveSubmissionResult> submit(
    LeaveApplicationModel application,
  ) async {
    final response = await _api.post('/leave/requests', application.toJson());
    final request = LeaveRequestModel.fromJson(
      response['request'] as Map<String, dynamic>,
    );
    if (request.id != application.id ||
        request.employeeId != application.employeeId ||
        request.type != application.type ||
        request.startDate != application.startDate ||
        request.endDate != application.endDate ||
        request.reason != application.reason.trim()) {
      throw const ApiException(ApiFailure.invalidResponse);
    }
    return LeaveSubmissionResult(
      request: request,
      balance: LeaveBalanceModel.fromJson(
        response['balance'] as Map<String, dynamic>,
      ),
    );
  }
}
