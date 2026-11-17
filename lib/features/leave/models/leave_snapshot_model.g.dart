// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_snapshot_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeaveSnapshotModelAdapter extends TypeAdapter<LeaveSnapshotModel> {
  @override
  final int typeId = 12;

  @override
  LeaveSnapshotModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LeaveSnapshotModel(
      requests: (fields[0] as List).cast<LeaveRequestModel>(),
      balance: fields[1] as LeaveBalanceModel,
      savedAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LeaveSnapshotModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.requests)
      ..writeByte(1)
      ..write(obj.balance)
      ..writeByte(2)
      ..write(obj.savedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveSnapshotModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
