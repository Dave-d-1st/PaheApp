import 'dart:async';

import 'package:app/models/download.dart';
import 'package:app/repository/download_repo.dart';
import 'package:bloc/bloc.dart';
part 'download_event.dart';
part 'download_state.dart';
class DownloadBloc extends Bloc<DownloadEvent,DownloadState>{
  final DownloadRepo repo;
  
  StreamSubscription? sub;
  DownloadBloc({required this.repo}):super(DownloadState(repo)){
    on<AddDownload>(_downloadAdded);
    on<Started>(_onStarted);
    on<GroupCancel>(_groupCancel);
    on<Update>(_update);
    on<ChangeOrder>(_changeOrder);
    on<MoveGroupUp>(_moveGroupUp);
    on<PlayPause>(_playPause);
    on<Restore>(_restore);
    on<Cancel>(_cancel);

    add(Started());

  }
  @override
  Future<void> close() {
    sub?.cancel();
    return super.close();
  } 

  FutureOr<void> _downloadAdded(AddDownload event, Emitter<DownloadState> emit) async{
    await repo.addDownload(event.url,event.title);
    emit(DownloadState(repo));
  }

  FutureOr<void> _onStarted(event, Emitter<DownloadState> emit) {
    sub?.cancel();
    repo.startDownload();
    sub = repo.controller.stream.listen((value)=>add(Update()));
  }

  FutureOr<void> _update(event, Emitter<DownloadState> emit) {
    emit(DownloadState(repo));
  }

  FutureOr<void> _changeOrder(ChangeOrder event, Emitter<DownloadState> emit)async {
    var li = repo.downloading;
    final item = li.removeAt(event.oldIndex);
    li.insert(event.newIndex, item);
    emit(DownloadState(repo,li));
    await repo.changeOrder(event.oldIndex,event.newIndex);
    emit(DownloadState(repo));
  }

  FutureOr<void> _playPause(PlayPause event, Emitter<DownloadState> emit) {
    repo.playPause();
    emit(DownloadState(repo));
  }

  FutureOr<void> _restore(Restore event, Emitter<DownloadState> emit) async{
    await repo.restore(event.download);
    emit(DownloadState(repo));
  }

  FutureOr<void> _cancel(Cancel event, Emitter<DownloadState> emit) async {
    List li = repo.downloading;
    li.removeAt(event.index);
    emit(DownloadState(repo,li));
    await repo.cancel(event.index);
    emit(DownloadState(repo));
  }

  FutureOr<void> _groupCancel(GroupCancel event, Emitter<DownloadState> emit) async 
  {
    await repo.groupCancel(event.title);
    emit(DownloadState(repo));
  }

  FutureOr<void> _moveGroupUp(MoveGroupUp event, Emitter<DownloadState> emit) async{
    RegExp re = RegExp(r'(.+) - [\d+]');
    String groupTitle = re.allMatches(event.title).first.group(1)??"";
    Iterable<Download> groupDownload = repo.downloading.where((value)=>(re.allMatches(value.title).first.group(1)??"")==groupTitle);
    for(int i=0; i<groupDownload.length;i++){
      await repo.changeOrder(repo.downloading.indexWhere((test)=>test==groupDownload.elementAt(i)), i);
    }
    emit(DownloadState(repo));
  }
}

