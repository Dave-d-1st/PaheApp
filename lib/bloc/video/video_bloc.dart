import 'dart:async';

import 'package:app/bloc/pahe/pahe_bloc.dart';
import 'package:app/repository/video_repo.dart';
import 'package:bloc/bloc.dart';

part 'video_event.dart';
part 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent,AniVideoState>{
  final VideoRepo repo;
  VideoBloc({required this.repo}) :
  super(AniVideoState(data: {},status: PaheStatus.searching)){
    on<StartVideo>(_videoStarted);
    on<ChangeRes>(_resChanged);
    on<PlayTime>(_updateTime);
  }

  FutureOr<void> _videoStarted(StartVideo event, Emitter<AniVideoState> emit) async{
    emit(AniVideoState(data: {},status: PaheStatus.searching));
    var data = await repo.getVideo(event.session);
    emit(AniVideoState(data: data));
  }

  FutureOr<void> _resChanged(ChangeRes event, Emitter<AniVideoState> emit) async{
   emit(AniVideoState(data: {},status: PaheStatus.searching)); 
   var data = await repo.changeRes(event.res ,event.eng,);
   emit(AniVideoState(data: data));
  }

  FutureOr<void> _updateTime(PlayTime event, Emitter<AniVideoState> emit) {
    repo.updateTime(event.episode,event.playTime,event.totalDur);
  }
}