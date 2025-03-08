// import 'package:app/bloc/anime/anime_state.dart';
import 'package:app/bloc/anime/anime_bloc.dart';
import 'package:app/models/pahe.dart';
import 'package:equatable/equatable.dart';
import 'package:app/repository/pahe_repo.dart';
import 'package:bloc/bloc.dart';

part 'pahe_state.dart';
part 'pahe_event.dart';
class PaheBloc extends Bloc<PaheEvent,PaheState>{
  bool working = false;
  PaheBloc({required PaheRepo repo}):
    _paheRepo = repo,
    super(PaheState(repo: repo)){
      on<StartPage>(_pageStarted);
      on<GetSearch>(_searched);
    }
  

  int currentPage = 1;
  final PaheRepo _paheRepo;

  Future<void> _searched(GetSearch event, Emitter<PaheState> emit) async{
    print("Sex");
    await _paheRepo.getSearch(event.searchTerm);
    emit(PaheState(repo: _paheRepo,status: PaheStatus.done));

  }

  Future<void> _pageStarted(PaheEvent event, Emitter<PaheState> emit)async{
    print("sex");
    if(working) return;
    working=true;
    if(currentPage==1) 
    {_paheRepo.clear();
    emit(PaheState(repo: _paheRepo));}
    await _paheRepo.getContent(currentPage);
    currentPage+=1;
    // print(_paheRepo.episodes);
    emit(PaheState(repo: _paheRepo,status: PaheStatus.done));
    working=false;}
}