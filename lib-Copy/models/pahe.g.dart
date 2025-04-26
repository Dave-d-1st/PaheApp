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
    return Pahe();
  }

  @override
  void write(BinaryWriter writer, Pahe obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.imageUrl)
      ..writeByte(2)
      ..write(obj.episode)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.animeSession)
      ..writeByte(5)
      ..write(obj.episodeSession)
      ..writeByte(6)
      ..write(obj.episode2);
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
