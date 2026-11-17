import 'package:hive/hive.dart';

import '../../../core/helpers/company_clock.dart';

part 'attendance_location_model.g.dart';

@HiveType(typeId: 8)
class AttendanceLocationModel {
  const AttendanceLocationModel({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.capturedAt,
  });

  @HiveField(0)
  final double latitude;
  @HiveField(1)
  final double longitude;
  @HiveField(2)
  final double accuracy;
  @HiveField(3)
  final DateTime capturedAt;

  // Parses the coordinates and GPS capture time of an attendance event.
  factory AttendanceLocationModel.fromJson(Map<String, dynamic> json) {
    return AttendanceLocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      capturedAt: DateTime.parse(json['captured_at'] as String).toUtc(),
    );
  }

  // Serializes location evidence for server-side validation.
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'captured_at': CompanyClock.utcTimestamp(capturedAt),
  };
}
