import 'package:hive/hive.dart';

part 'office_model.g.dart';

@HiveType(typeId: 0)
class OfficeModel {
  const OfficeModel({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMetres,
    required this.timezone,
  });

  @HiveField(0)
  final String name;
  @HiveField(1)
  final double latitude;
  @HiveField(2)
  final double longitude;
  @HiveField(3)
  final double radiusMetres;
  @HiveField(4)
  final String timezone;

  // Parses office configuration returned by the mock API.
  factory OfficeModel.fromJson(Map<String, dynamic> json) {
    return OfficeModel(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusMetres: (json['radius_metres'] as num).toDouble(),
      timezone: json['timezone'] as String,
    );
  }
}
