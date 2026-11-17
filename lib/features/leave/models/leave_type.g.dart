// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeaveTypeAdapter extends TypeAdapter<LeaveType> {
  @override
  final int typeId = 9;

  @override
  LeaveType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LeaveType.casual;
      case 1:
        return LeaveType.sick;
      default:
        return LeaveType.casual;
    }
  }

  @override
  void write(BinaryWriter writer, LeaveType obj) {
    switch (obj) {
      case LeaveType.casual:
        writer.writeByte(0);
        break;
      case LeaveType.sick:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
