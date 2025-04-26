part of "settings_bloc.dart";

sealed class SettingsEvent {
  const SettingsEvent();
}

class ChangeTheme extends SettingsEvent{
  @override
  String toString() {
    return "ChangeTheme()";
  } 
}

class FilePicked extends SettingsEvent{
}

class ChangeWatchRes extends SettingsEvent{
  final String res;
  ChangeWatchRes(this.res);
}
class ChangeDownloadRes extends SettingsEvent{
  final String res;
  ChangeDownloadRes(this.res);
}
class ChangeFallbackRes extends SettingsEvent{

}
class ChangegetM3u8 extends SettingsEvent{
  
}