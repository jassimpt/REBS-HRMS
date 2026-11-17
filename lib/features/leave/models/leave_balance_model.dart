import 'package:hive/hive.dart';

part 'leave_balance_model.g.dart';

@HiveType(typeId: 3)
class LeaveBalanceModel {
  const LeaveBalanceModel({required this.casual, required this.sick});

  @HiveField(0)
  final int casual;
  @HiveField(1)
  final int sick;

  int get total => casual + sick;

  // Serializes the available days for mock API responses.
  Map<String, dynamic> toJson() => {'casual': casual, 'sick': sick};

  // Parses the remaining balance for each supported leave type.
  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceModel(
      casual: json['casual'] as int,
      sick: json['sick'] as int,
    );
  }
}
