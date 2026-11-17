import 'package:hive/hive.dart';

part 'attendance_record_model.g.dart';

@HiveType(typeId: 2)
class AttendanceRecordModel {
  const AttendanceRecordModel({
    required this.id,
    required this.date,
    required this.checkIn,
    this.checkOut,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String date;
  @HiveField(2)
  final DateTime checkIn;
  @HiveField(3)
  final DateTime? checkOut;

  // Parses an attendance session with UTC event timestamps.
  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id'] as String,
      date: json['date'] as String,
      checkIn: DateTime.parse(json['check_in'] as String).toUtc(),
      checkOut: json['check_out'] == null
          ? null
          : DateTime.parse(json['check_out'] as String).toUtc(),
    );
  }

  // Calculates elapsed time, freezing unfinished past-day sessions at midnight.
  Duration workingDuration(DateTime now, DateTime endOfDay) {
    final end = checkOut ?? (now.isBefore(endOfDay) ? now : endOfDay);
    return end.isBefore(checkIn) ? Duration.zero : end.difference(checkIn);
  }
}
