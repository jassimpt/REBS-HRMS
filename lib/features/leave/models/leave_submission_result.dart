import 'leave_balance_model.dart';
import 'leave_request_model.dart';

class LeaveSubmissionResult {
  const LeaveSubmissionResult({required this.request, required this.balance});

  final LeaveRequestModel request;
  final LeaveBalanceModel balance;
}
