import 'dart:async';

import 'package:app/bloc/anime/anime_bloc.dart';
import 'package:app/models/home_item.dart';
import 'package:app/repository/home_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepo repo;
  HomeBloc({required this.repo}) : super(HomeState(repo: repo)) {
    on<AddHomeItem>(_itemAdded);
    on<SavedItem>(_computeItem);
    on<GetPlayTime>(_playTime);
    on<Update>(_update);
    on<Migrate>(_migrate);
  }

  FutureOr<void> _itemAdded(AddHomeItem event, Emitter<HomeState> emit) async {
    if (state.homeInfos.values.where((value)=>value.title==event.state.title).isNotEmpty) {
      await repo.deleteItem(state:event.state);
    } else {
      await repo.addItem(state:event.state);
    }
    emit(HomeState(repo: repo));
  }

  FutureOr<void> _computeItem(SavedItem event, Emitter<HomeState> emit)async{
    if (state.homeInfos.containsKey(event.item.homeId)) {
      await repo.deleteItem(item:event.item);
    } else {
      await repo.addItem(item:event.item);
    }
    emit(HomeState(repo: repo));
  }

  FutureOr<void> _playTime(GetPlayTime event, Emitter<HomeState> emit) {
    repo.getPlayTime(event.episode);
    emit(HomeState(repo: repo));
  }

  FutureOr<HomeItem?> refresh(Refresh event) async{
    HomeItem item =await repo.refresh(event.item);
    return item;
  }

  FutureOr<void> _update(Update event, Emitter<HomeState> emit) {
    emit(HomeState(repo: repo));
  }

  FutureOr<void> _migrate(Migrate event, Emitter<HomeState> emit) {
    repo.migrate();
  }
}
