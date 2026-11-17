// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_snapshot_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DashboardSnapshotModelAdapter
    extends TypeAdapter<DashboardSnapshotModel> {
  @override
  final int typeId = 4;

  @override
  DashboardSnapshotModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DashboardSnapshotModel(
      employee: fields[0] as EmployeeModel,
      attendance: (fields[1] as List).cast<AttendanceRecordModel>(),
      leaveBalance: fields[2] as LeaveBalanceModel,
      savedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DashboardSnapshotModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.employee)
      ..writeByte(1)
      ..write(obj.attendance)
      ..writeByte(2)
      ..write(obj.leaveBalance)
      ..writeByte(3)
      ..write(obj.savedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardSnapshotModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
