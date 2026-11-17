import 'package:hive/hive.dart';

part 'attendance_sync_status.g.dart';

@HiveType(typeId: 7)
enum AttendanceSyncStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  synced,
  @HiveField(2)
  rejected,
}
