// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_request_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeaveRequestModelAdapter extends TypeAdapter<LeaveRequestModel> {
  @override
  final int typeId = 11;

  @override
  LeaveRequestModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LeaveRequestModel(
      id: fields[0] as String,
      employeeId: fields[1] as String,
      type: fields[2] as LeaveType,
      startDate: fields[3] as String,
      endDate: fields[4] as String,
      reason: fields[5] as String,
      status: fields[6] as LeaveRequestStatus,
      submittedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LeaveRequestModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.employeeId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.endDate)
      ..writeByte(5)
      ..write(obj.reason)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.submittedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveRequestModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
