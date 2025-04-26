part of "settings_bloc.dart";

class SettingsState {
  final ThemeData theme; 
  final String storagePath;

  SettingsState({required SettingsRepository repo}):
    theme = ThemeData(useMaterial3: true,colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue,brightness: repo.theme=='light'?Brightness.light:Brightness.dark,surface: repo.theme=='light'?null:Colors.black)),
    storagePath = repo.storagePath;
  
  @override
  String toString() {
    // TODO: implement toString
    return "SettingsState(theme: ${theme.brightness}, storagePath: $storagePath)";
  }
}
