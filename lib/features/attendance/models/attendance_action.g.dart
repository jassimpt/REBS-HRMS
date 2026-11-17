// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_action.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttendanceActionAdapter extends TypeAdapter<AttendanceAction> {
  @override
  final int typeId = 6;

  @override
  AttendanceAction read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AttendanceAction.checkIn;
      case 1:
        return AttendanceAction.checkOut;
      default:
        return AttendanceAction.checkIn;
    }
  }

  @override
  void write(BinaryWriter writer, AttendanceAction obj) {
    switch (obj) {
      case AttendanceAction.checkIn:
        writer.writeByte(0);
        break;
      case AttendanceAction.checkOut:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceActionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
