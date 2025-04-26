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
  String get watchRes{
    final box = Hive.box("settings");
    final String path = box.get("resolution",defaultValue: '');
    return path;
  }
  String get downloadRes{
    final box = Hive.box("settings");
    final String path = box.get("downloadRes",defaultValue: '');
    return path;
  }

  bool get fallBackRes{
    final box = Hive.box("settings");
    final bool path = box.get("fallBackResHigh",defaultValue: false);
    return path;
  }

  bool get getM3u8{
    final box = Hive.box("settings");
    final bool path = box.get("getM3u8",defaultValue: false);
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
      SafDocumentFile? path = await util.pickDirectory(persistablePermission: true);
      result = path?.uri;
    }
    final box =  Hive.box("settings");
    box.put("path", result??'');
    }

  void changeFallback() {
    final box = Hive.box("settings");
    box.put("fallBackResHigh",!fallBackRes);
  }

  void changeWatchRes(String res){
    final box = Hive.box("settings");
    box.put("resolution",res);
  }

  void changeDownloadRes(String res) {
    final box = Hive.box("settings");
    box.put("downloadRes",res);
  }

  void changem3u8() {
    final box = Hive.box("settings");
    box.put("getM3u8",!getM3u8);
  }
}