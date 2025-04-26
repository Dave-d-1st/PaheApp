import 'dart:async';
import 'dart:typed_data';

import 'package:app/bloc/wco/wco_bloc.dart';
import 'package:app/repository/wco_repo.dart';
import 'package:bloc/bloc.dart';

part 'wcos_state.dart';
part 'wcos_event.dart';

class WcosBloc extends Bloc<WcosEvent,WcosState>{
  WcosBloc(this.repo):super(WcosState({})){
    on<GetAnimeInfo>(_getAniInfo);
  }
  final WcoRepo repo;


  FutureOr<void> _getAniInfo(GetAnimeInfo event, Emitter<WcosState> emit) async{
    emit(WcosState({},status: WcoStatus.searching));
    var data = await repo.getAniInfo(event.url);
    emit(WcosState(data));
  }
}