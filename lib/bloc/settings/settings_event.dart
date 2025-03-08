part of "settings_bloc.dart";

sealed class SettingsEvent {
  const SettingsEvent();
}

class ChangeTheme extends SettingsEvent{
  @override
  String toString() {
    // TODO: implement toString
    return "ChangeTheme()";
  }
  
}

class FilePicked extends SettingsEvent{

}