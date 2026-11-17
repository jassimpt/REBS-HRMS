// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'office_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfficeModelAdapter extends TypeAdapter<OfficeModel> {
  @override
  final int typeId = 0;

  @override
  OfficeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfficeModel(
      name: fields[0] as String,
      latitude: fields[1] as double,
      longitude: fields[2] as double,
      radiusMetres: fields[3] as double,
      timezone: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OfficeModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.latitude)
      ..writeByte(2)
      ..write(obj.longitude)
      ..writeByte(3)
      ..write(obj.radiusMetres)
      ..writeByte(4)
      ..write(obj.timezone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfficeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
