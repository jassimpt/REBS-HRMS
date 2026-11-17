// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttendanceRecordModelAdapter extends TypeAdapter<AttendanceRecordModel> {
  @override
  final int typeId = 2;

  @override
  AttendanceRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttendanceRecordModel(
      id: fields[0] as String,
      date: fields[1] as String,
      checkIn: fields[2] as DateTime,
      checkOut: fields[3] as DateTime?,
      syncStatus: fields[4] == null
          ? AttendanceSyncStatus.synced
          : fields[4] as AttendanceSyncStatus,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceRecordModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.checkIn)
      ..writeByte(3)
      ..write(obj.checkOut)
      ..writeByte(4)
      ..write(obj.syncStatus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
