// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HomeItemAdapter extends TypeAdapter<HomeItem> {
  @override
  final int typeId = 0;

  @override
  HomeItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HomeItem(
      title: fields[0] as String,
      subtitle: fields[1] as String,
      summary: (fields[2] as Map).cast<dynamic, dynamic>(),
      id: fields[3] as int?,
      imageUrl: fields[4] as String,
      imagePath: fields[5] as String,
      episodes: (fields[6] as List).cast<dynamic>(),
      height: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, HomeItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.subtitle)
      ..writeByte(2)
      ..write(obj.summary)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.imagePath)
      ..writeByte(6)
      ..write(obj.episodes)
      ..writeByte(7)
      ..write(obj.height);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
