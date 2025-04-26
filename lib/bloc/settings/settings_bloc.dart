import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:app/repository/settings_repo.dart';
part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent,SettingsState>{
  SettingsBloc({required SettingsRepository setrepo}) : 
    _setrepo = setrepo,
    super(SettingsState(repo:setrepo)){
    on<ChangeTheme>(_onThemeChanged);
    on<FilePicked>(_onfilePicked);
    on<ChangegetM3u8>(_changem3u8);
    on<ChangeFallbackRes>(_changeFallback);
    on<ChangeWatchRes>(_changeWatchRes);
    on<ChangeDownloadRes>(_changeDownloadRes);
  }
  
  final SettingsRepository _setrepo;
  void _onThemeChanged(ChangeTheme event, Emitter<SettingsState> emit){
    _setrepo.changeTheme();
    emit(SettingsState(repo: _setrepo));
  }

  void _onfilePicked(FilePicked event, Emitter<SettingsState> emit)async{
    
      await _setrepo.changeSPath();
      emit(SettingsState(repo: _setrepo));
  }

  FutureOr<void> _changeFallback(ChangeFallbackRes event, Emitter<SettingsState> emit) {
    _setrepo.changeFallback();
    emit(SettingsState(repo: _setrepo));
  }

  FutureOr<void> _changeWatchRes(ChangeWatchRes event, Emitter<SettingsState> emit) {
    _setrepo.changeWatchRes(event.res);
    emit(SettingsState(repo: _setrepo));
  }

  FutureOr<void> _changeDownloadRes(ChangeDownloadRes event, Emitter<SettingsState> emit) {
    _setrepo.changeDownloadRes(event.res);
    emit(SettingsState(repo: _setrepo));
  }

  FutureOr<void> _changem3u8(ChangegetM3u8 event, Emitter<SettingsState> emit) {
    _setrepo.changem3u8();
    emit(SettingsState(repo: _setrepo));
  }
}