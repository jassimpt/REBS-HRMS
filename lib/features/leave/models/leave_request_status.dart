import 'package:hive/hive.dart';

part 'leave_request_status.g.dart';

@HiveType(typeId: 10)
enum LeaveRequestStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  approved,
  @HiveField(2)
  rejected,
}
