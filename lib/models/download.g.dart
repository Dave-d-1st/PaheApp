// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadAdapter extends TypeAdapter<Download> {
  @override
  final int typeId = 2;

  @override
  Download read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Download(
      (fields[0] as Map).cast<dynamic, dynamic>(),
      status: fields[1] as DownloadStatus,
    );
  }

  @override
  void write(BinaryWriter writer, Download obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.data)
      ..writeByte(1)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DownloadStatusAdapter extends TypeAdapter<DownloadStatus> {
  @override
  final int typeId = 3;

  @override
  DownloadStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DownloadStatus.done;
      case 1:
        return DownloadStatus.running;
      case 2:
        return DownloadStatus.error;
      case 3:
        return DownloadStatus.enqueued;
      case 4:
        return DownloadStatus.paused;
      default:
        return DownloadStatus.done;
    }
  }

  @override
  void write(BinaryWriter writer, DownloadStatus obj) {
    switch (obj) {
      case DownloadStatus.done:
        writer.writeByte(0);
        break;
      case DownloadStatus.running:
        writer.writeByte(1);
        break;
      case DownloadStatus.error:
        writer.writeByte(2);
        break;
      case DownloadStatus.enqueued:
        writer.writeByte(3);
        break;
      case DownloadStatus.paused:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
