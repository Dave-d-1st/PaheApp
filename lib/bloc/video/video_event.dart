part of 'video_bloc.dart';

sealed class VideoEvent {}

class StartVideo extends VideoEvent{
  String session;
  StartVideo({required this.session});
}

class ChangeRes extends VideoEvent{
  String res;
  bool eng;
  ChangeRes({required this.res, required this.eng});
}

class PlayTime extends VideoEvent{
  String episode;
  Duration playTime;
  Duration totalDur;
  PlayTime({required this.episode,required this.playTime,required this.totalDur});
}