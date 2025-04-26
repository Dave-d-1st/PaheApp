// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pahe.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaheAdapter extends TypeAdapter<Pahe> {
  @override
  final int typeId = 1;

  @override
  Pahe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pahe(
      data: (fields[0] as Map).cast<dynamic, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Pahe obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
