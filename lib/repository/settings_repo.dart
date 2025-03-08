import 'package:hive/hive.dart';

class SettingsRepository {
  String get theme {
    final box =  Hive.box("settings");
    final String theme = box.get("theme",defaultValue: 'dark');
    return theme;
  }

  String get storagePath{
    final box = Hive.box("settings");
    final String path = box.get("path",defaultValue: '');
    return path;
  }

  void changeTheme(){
    final box =  Hive.box("settings");
    if(theme=="light"){
      box.put("theme", "dark");
    } else{
      box.put("theme", "light");
    }
  }

  void changeSPath(String newpath){
    final box =  Hive.box("settings");
    box.put("path", newpath);
  }
}