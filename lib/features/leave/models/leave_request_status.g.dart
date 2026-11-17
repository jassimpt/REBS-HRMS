// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_request_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeaveRequestStatusAdapter extends TypeAdapter<LeaveRequestStatus> {
  @override
  final int typeId = 10;

  @override
  LeaveRequestStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LeaveRequestStatus.pending;
      case 1:
        return LeaveRequestStatus.approved;
      case 2:
        return LeaveRequestStatus.rejected;
      default:
        return LeaveRequestStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, LeaveRequestStatus obj) {
    switch (obj) {
      case LeaveRequestStatus.pending:
        writer.writeByte(0);
        break;
      case LeaveRequestStatus.approved:
        writer.writeByte(1);
        break;
      case LeaveRequestStatus.rejected:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveRequestStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
