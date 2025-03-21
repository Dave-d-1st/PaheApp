import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:saf_util/saf_util.dart';
import 'package:saf_util/saf_util_platform_interface.dart';

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

  Future<void> changeSPath()async{
    String? result;
    if(Platform.isWindows){
      result =await FilePicker.platform.getDirectoryPath(
        dialogTitle: "Pick a Folder",
        lockParentWindow: true
      );}
    if(Platform.isAndroid){
      final util = SafUtil();
      SafDocumentFile? path = await util.pickDirectory();
      result = path?.uri;
    }
    final box =  Hive.box("settings");
    box.put("path", result??'');
    }
}