import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
part 'download.g.dart';
@HiveType(typeId: 3)
enum DownloadStatus {
  @HiveField(0)
  done,
  @HiveField(1)
  running,
  @HiveField(2)
  error,
  @HiveField(3)
  enqueued,
  @HiveField(4)
  paused
  }

@HiveType(typeId: 2)
class Download extends Equatable{
  final int id;
  final String downloadUrl;
  final int? size;
  final String title;
  final num speed;
  final String session;
  final double progress;
  final String? filename;
  @HiveField(0)
  final Map data;
  final int currentSize;
  @HiveField(1)
  final DownloadStatus status;
  Download(this.data,{this.status= DownloadStatus.enqueued}):
  id = data['id'],
  session = data['session'],
  filename = data['name'],
  currentSize = data['current']??0,
  size = data['size']??0,
  downloadUrl = data['url'],
  title = data['title'],
  speed = data['speed']??0,
  progress = data['progress']??0;

  @override
  String toString() {
    return "Download(id: $id, title: $title)";
  }
  @override
  List<Object?> get props => [id,downloadUrl,title,];
}