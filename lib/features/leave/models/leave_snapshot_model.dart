import 'package:hive/hive.dart';

import 'leave_balance_model.dart';
import 'leave_request_model.dart';

part 'leave_snapshot_model.g.dart';

@HiveType(typeId: 12)
class LeaveSnapshotModel {
  const LeaveSnapshotModel({
    required this.requests,
    required this.balance,
    required this.savedAt,
  });

  @HiveField(0)
  final List<LeaveRequestModel> requests;
  @HiveField(1)
  final LeaveBalanceModel balance;
  @HiveField(2)
  final DateTime savedAt;
}
