import 'package:hive/hive.dart';

part 'attendance_action.g.dart';

@HiveType(typeId: 6)
enum AttendanceAction {
  @HiveField(0)
  checkIn,
  @HiveField(1)
  checkOut,
}
