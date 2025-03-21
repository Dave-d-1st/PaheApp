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
    on<GetHomeItems>(_getItems);
    on<SavedItem>(_computeItem); //TODO SavedItem is a vary terrible name change that shit
  }

  FutureOr<void> _itemAdded(AddHomeItem event, Emitter<HomeState> emit) async {
    if (state.homeInfos.containsKey(event.state.title)) {
      await repo.deleteItem(state:event.state);
    } else {
      await repo.addItem(state:event.state);
    }
    emit(HomeState(repo: repo));
  }

  FutureOr<void> _getItems(GetHomeItems event, Emitter<HomeState> emit) {
    repo.getItems();
    emit(HomeState(repo: repo));
  }

  FutureOr<void> _computeItem(SavedItem event, Emitter<HomeState> emit)async{
    if (state.homeInfos.containsKey(event.item.title)) {
      await repo.deleteItem(item:event.item);
    } else {
      await repo.addItem(item:event.item);
    }
    emit(HomeState(repo: repo));
  }
}
