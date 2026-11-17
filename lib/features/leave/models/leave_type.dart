import 'package:hive/hive.dart';

part 'leave_type.g.dart';

@HiveType(typeId: 9)
enum LeaveType {
  @HiveField(0)
  casual,
  @HiveField(1)
  sick,
}
