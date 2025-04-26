import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:app/repository/settings_repo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent,SettingsState>{
  SettingsBloc({required SettingsRepository setrepo}) : 
    _setrepo = setrepo,
    super(SettingsState(repo:setrepo)){
    on<ChangeTheme>(_onThemeChanged);
    on<FilePicked>(_onfilePicked);
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

  @override
  void onTransition(Transition<SettingsEvent, SettingsState> transition) {
    print(transition);
    super.onTransition(transition);
  }
}