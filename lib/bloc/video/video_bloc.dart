import 'dart:async';

import 'package:app/bloc/pahe/pahe_bloc.dart';
import 'package:app/models/realtive_vid.dart';
import 'package:app/repository/video_repo.dart';
import 'package:bloc/bloc.dart';

part 'video_event.dart';
part 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, AniVideoState> {
  final VideoRepo repo;
  VideoBloc({required this.repo})
      : super(AniVideoState(data: {}, status: PaheStatus.searching)) {
    on<StartVideo>(_videoStarted);
    on<ChangeRes>(_resChanged);
    on<PlayTime>(_updateTime);
    on<Done>(_done);
  }

  FutureOr<void> _videoStarted(
      StartVideo event, Emitter<AniVideoState> emit) async {
    emit(AniVideoState(data: {}, status: PaheStatus.searching));
    try {
      var data = await repo.getVideo(event.session, event.title);
      print("Simp $data");
      if (data is Map) {
        emit(AniVideoState(data: data));
        print('saida');
      } else {
        emit(AniVideoState(data: {}, status: PaheStatus.error, error: data));
      }
    } catch (e) {
      if (e is Exception || e is Error) {
        emit(AniVideoState(data: {}, status: PaheStatus.error, error: e));
      }
    }
  }

  FutureOr<void> _resChanged(
      ChangeRes event, Emitter<AniVideoState> emit) async {
    emit(AniVideoState(data: {}, status: PaheStatus.searching));
    await Future.delayed(Duration(milliseconds: 300));
    var data = await repo.changeRes(event.res, event.eng);
    emit(AniVideoState(data: data));
  }

  FutureOr<void> _updateTime(PlayTime event, Emitter<AniVideoState> emit) {
    repo.updateTime(event.episode, event.playTime, event.totalDur);
  }

  FutureOr<void> _done(Done event, Emitter<AniVideoState> emit) {
    repo.done();
  }
}
