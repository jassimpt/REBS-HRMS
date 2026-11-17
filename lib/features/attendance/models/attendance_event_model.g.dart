// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_event_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttendanceEventModelAdapter extends TypeAdapter<AttendanceEventModel> {
  @override
  final int typeId = 5;

  @override
  AttendanceEventModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttendanceEventModel(
      id: fields[0] as String,
      employeeId: fields[1] as String,
      sessionId: fields[2] as String,
      action: fields[3] as AttendanceAction,
      companyDate: fields[4] as String,
      occurredAt: fields[5] as DateTime,
      location: fields[6] as AttendanceLocationModel,
      status: fields[7] as AttendanceSyncStatus,
      rejectionCode: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceEventModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.employeeId)
      ..writeByte(2)
      ..write(obj.sessionId)
      ..writeByte(3)
      ..write(obj.action)
      ..writeByte(4)
      ..write(obj.companyDate)
      ..writeByte(5)
      ..write(obj.occurredAt)
      ..writeByte(6)
      ..write(obj.location)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.rejectionCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceEventModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
