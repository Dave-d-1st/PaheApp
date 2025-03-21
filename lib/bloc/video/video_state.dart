part of 'video_bloc.dart';

class AniVideoState {
  PaheStatus status;
  List resolutions;
  String currentResolution;
  String videoUrl;
  String title;
  String? previous;
  String? next;
  Duration? playTime;
  AniVideoState(
      {data,
      this.status = PaheStatus.done
      }):
      title = data['title']??'',
      resolutions = data['res']??[],
      currentResolution = data['curRes']??'',
      videoUrl = data["videoUrl"]??'',
      previous = data['prev'],
      next = data['next'],
      playTime=data['playTime'];
}
