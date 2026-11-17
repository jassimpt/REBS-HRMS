import 'package:hive/hive.dart';

import 'office_model.dart';

part 'employee_model.g.dart';

@HiveType(typeId: 1)
class EmployeeModel {
  const EmployeeModel({
    required this.id,
    required this.name,
    required this.department,
    required this.designation,
    required this.office,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String department;
  @HiveField(3)
  final String designation;
  @HiveField(4)
  final OfficeModel office;

  // Parses the preconfigured employee and office details.
  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      department: json['department'] as String,
      designation: json['designation'] as String,
      office: OfficeModel.fromJson(json['office'] as Map<String, dynamic>),
    );
  }
}
