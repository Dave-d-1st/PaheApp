part of 'video_bloc.dart';

class AniVideoState {
  PaheStatus status;
  List resolutions;
  String currentResolution;
  String videoUrl;
  String title;
  RealtiveVid? previous;
  RealtiveVid? next;
  Duration? playTime;
  Object? error;
  AniVideoState(
      {data,
      this.status = PaheStatus.done,
      this.error
      }):
      title = data['title']??'',
      resolutions = data['res']??[],
      currentResolution = data['curRes']??'',
      videoUrl = data["videoUrl"]??'',
      previous = data['prev'],
      next = data['next'],
      playTime=data['playTime'];
}
