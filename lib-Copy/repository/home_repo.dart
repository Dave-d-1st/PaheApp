import 'dart:io';
import 'dart:typed_data';
import 'package:app/bloc/anime/anime_bloc.dart';
import 'package:app/models/home_item.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HomeRepo {
  final Map<String, HomeItem> homeInfos = {};
  Future<Directory> get docPath async {
    return await getApplicationDocumentsDirectory();
  }

  Future<void> addItem({AnimeState? state,HomeItem? item}) async {
    if(state!=null){
    Directory path = Directory("${(await docPath).path}\\HomeLib\\posters");
    if (!path.existsSync()) {
      await path.create(recursive: true);
    }
    print('object');
    var fileName = state.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    File poster = File("${path.path}\\$fileName.png");
    if (!await poster.exists()) {
      await poster.create();
    }

    Uint8List bytes = state.image;
    await poster.writeAsBytes(bytes, flush: true);
    HomeItem item = HomeItem(
        height: state.imgHeight,
        title: state.title,
        subtitle: state.subtitle,
        summary: state.summary,

        id: state.id,
        imageUrl: state.imageUrl,
        imagePath: poster.path,
        episodes: state.episodes??[]);
    homeInfos[state.title] = item;
    Box box = Hive.box("offline");
    box.put(state.title, item);}

    if(item!=null){
    Directory path = Directory("${(await docPath).path}\\HomeLib\\posters");
    if (!path.existsSync()) {
      await path.create(recursive: true);
    }
    var fileName = item.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    File poster = File("${path.path}\\$fileName.png");
    if (!await poster.exists()) {
      await poster.create();
    }

    Uint8List bytes = item.image;
    await poster.writeAsBytes(bytes, flush: true);

    homeInfos[item.title] = item;
    Box box = Hive.box("offline");
    box.put(item.title, item);
    }
  }

  Future<void> deleteItem({AnimeState? state,HomeItem? item}) async {
    if(state!=null){
    Directory path = Directory("${(await docPath).path}\\HomeLib\\posters");
    var fileName = state.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    File poster = File("${path.path}\\$fileName.png");
    poster.delete();
    Box box = Hive.box("offline");
    homeInfos.remove(state.title);
    box.delete(state.title);}else if(item!=null){
      Directory path = Directory("${(await docPath).path}\\HomeLib\\posters");
    var fileName = item.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    File poster = File("${path.path}\\$fileName.png");
    poster.delete();
    Box box = Hive.box("offline");
    homeInfos.remove(item.title);
    box.delete(item.title);
    }
  }

  void getItems() {
    Box box = Hive.box('offline');
    homeInfos.addAll({for (var key in box.keys) key: box.get(key)});
  }
}

void main() {
  Map dic = {"s": 1};
}
