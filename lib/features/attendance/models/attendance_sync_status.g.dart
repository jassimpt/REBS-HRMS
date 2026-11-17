// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_sync_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttendanceSyncStatusAdapter extends TypeAdapter<AttendanceSyncStatus> {
  @override
  final int typeId = 7;

  @override
  AttendanceSyncStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AttendanceSyncStatus.pending;
      case 1:
        return AttendanceSyncStatus.synced;
      case 2:
        return AttendanceSyncStatus.rejected;
      default:
        return AttendanceSyncStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, AttendanceSyncStatus obj) {
    switch (obj) {
      case AttendanceSyncStatus.pending:
        writer.writeByte(0);
        break;
      case AttendanceSyncStatus.synced:
        writer.writeByte(1);
        break;
      case AttendanceSyncStatus.rejected:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceSyncStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
