import 'dart:async';

import 'package:app/repository/wco_repo.dart';
import 'package:bloc/bloc.dart';
part 'wco_event.dart';
part 'wco_state.dart';

class WcoBloc extends Bloc<WcoEvent,WcoState>{
  final WcoRepo repo;
  WcoBloc(this.repo):super(WcoState(repo)){
    on<StartWco>(_wcoStarted);
    on<GetSearch>(_search);
  }

  FutureOr<void> _wcoStarted(StartWco event, Emitter<WcoState> emit) async{
    emit(WcoState(repo,WcoStatus.searching));
    await repo.startWco();
    emit(WcoState(repo));

  }

  Future<void> _search(GetSearch event, Emitter<WcoState> emit) async {
    emit(WcoState(repo,WcoStatus.searching));
    await repo.search(event.searchTerm);
    emit(WcoState(repo));
  }
}