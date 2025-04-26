part of "settings_bloc.dart";

class SettingsState {
  final ThemeData theme; 
  final String storagePath;
  final bool fallBackRes;
  final bool getM3u8;
  final String watchRes;
  final String downloadRes;

  SettingsState({required SettingsRepository repo}):
    theme = ThemeData(useMaterial3: true,colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue,brightness: repo.theme=='light'?Brightness.light:Brightness.dark,surface: repo.theme=='light'?null:Colors.black)),
    storagePath = repo.storagePath,
    fallBackRes = repo.fallBackRes,
    watchRes = repo.watchRes,
    downloadRes = repo.downloadRes,
    getM3u8=repo.getM3u8;
  
  @override
  String toString() {
    return "SettingsState(theme: ${theme.brightness}, storagePath: $storagePath)";
  }
}
