import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:app/bloc/anime/anime_bloc.dart';
import 'package:app/models/home_item.dart';
import 'package:app/models/pahe.dart';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saf_util/saf_util.dart';
import 'package:saf_util/saf_util_platform_interface.dart';

class HomeRepo {
  Map<String, String> headers = {
    "Cookie":
        "__ddgid_=sE1YjW2vvFeZ9eMN; __ddgmark_=lxBaq42Dv71DNn34; __ddg2_=u2F6XKyQ9gVjlihp; __ddg1_=qbup7B4r1G6i5TWkt7RT;SERVERID=janna;XSRF-TOKEN=eyJpdiI6IjMwejVVQWpqYzBCZ0Z1YmhsZnZXM3c9PSIsInZhbHVlIjoiQ25Mdno0cUJyUTc0cU1rUW1NWVB0RXo5R1BkZFhBM1hRd1VObmYxSTRKTUNKZTZHdmF3VWdJbyswcWZMdmM1SUtONmlDc293VGRvbER4MFd3eDNGVEZpZC92L05QNVpjSmxGTEhzMlA3UGh0Wk5wSXVqK01KRXZCc2lWRkVZQXIiLCJtYWMiOiJlZjQxZjJlNzFkNWFlOTc2YjgwOTY5OTQyY2VhMDg2OTg3YTQyNDBjMTdlY2ZiMzllMjE0ZmE0YzI4ZTFiMzg1IiwidGFnIjoiIn0%3D; laravel_session=eyJpdiI6Im5STkE5Q040dm1pVFFxQzdOR2d2RXc9PSIsInZhbHVlIjoiVTVaQmEvVEd0MVBBVVJ4bjMrVS94RXYzbTAwMnpFelhkVXYxTWFRSFJXSFVPZ2dzNkEyRXlXNW9neXdPeTlUQ0pISzZ2T0c0TUxiOVRnaW14N21OQTBkMW1JbWdEK0FvdFptTWxKQmcrc2pDbWRQMk9kbDkvMnZYSmVuVGhMQnciLCJtYWMiOiI5Yzc5ZmMzNjVlNDAzZDc4MTEzN2VjNjMzNTliZjExY2EyYzQyYzMyMjNiNWIzYTlhODEwMzEyMzk4MzQxODkzIiwidGFnIjoiIn0%3D"
  };
  Map<int, HomeItem> get homeInfos {
    Box box = Hive.box('offline');
    return {for (var key in box.keys) key: box.get(key)};
  }

  final Map<String, List<int>> playtime = {};
  Future<Directory> get docPath async {
    return await getApplicationDocumentsDirectory();
  }

  Future<void> addItem({AnimeState? state, HomeItem? item}) async {
    if (state != null) {
      Directory path = Directory("${(await docPath).path}\\HomeLib\\posters");
      if (!path.existsSync()) {
        await path.create(recursive: true);
      }
      var fileName = state.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      File poster = File("${path.path}\\$fileName.png");
      if (!await poster.exists()) {
        await poster.create();
      }

      Uint8List bytes = state.image;
      await poster.writeAsBytes(bytes, flush: true);
      Box box = Hive.box("offline");
      int id = box.keys.isEmpty ? 0 : box.keys.last;
      id++;
      HomeItem item = HomeItem(
          session: RegExp(r'id=(.+)&sort')
                  .allMatches(state.session ?? '')
                  .first
                  .group(1) ??
              "",
          height: state.imgHeight,
          homeId: id,
          title: state.title,
          subtitle: state.subtitle,
          summary: state.summary,
          id: state.id,
          imageUrl: state.imageUrl,
          imagePath: poster.path,
          episodes: state.episodes ?? []);
      box.put(id, item);
    } else if (item != null) {
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

      // Box box = Hive.box("offline");
      // box.put(item.homeId, item);
    }
  }

  Future<void> deleteItem({AnimeState? state, HomeItem? item}) async {
    if (state != null) {
      Directory path = Directory("${(await docPath).path}\\HomeLib\\posters");
      var fileName = state.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      File poster = File("${path.path}\\$fileName.png");
      poster.delete();
      Box box = Hive.box("offline");
      await box.deleteAt(homeInfos.values
          .toList()
          .indexWhere((value) => value.title == state.title));
    } else if (item != null) {
      Directory path = Directory("${(await docPath).path}\\HomeLib\\posters");
      var fileName = item.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      File poster = File("${path.path}\\$fileName.png");
      poster.delete();
      Box box = Hive.box("offline");
      await box.delete(item.homeId);
    }
  }

  void getPlayTime(String episode) {
    Box box = Hive.box('playtime');
    Map time = box.get(episode, defaultValue: {});
    if (time.isNotEmpty) {
      int currentTime = time["duration"];
      int totalTime = time["total"];

      playtime[episode] = [currentTime, totalTime];
    }
  }

  Future<HomeItem> refresh(HomeItem item) async {
    var r = await http.get(
        Uri.parse("https://animepahe.ru/anime/${item.session}/"),
        headers: headers);
    if (r.statusCode == 200) {
      return await getRefresh(r, item: item);
    } else {
      var r = await http.get(
          Uri.parse("https://animepahe.ru/api?m=search&q=${item.title}"),
          headers: headers);
      Map jsonResult = json.decode(r.body);
      var result =
          (jsonResult['data'] as List).where((value) => value['id'] == item.id);
      if (result.isNotEmpty) {
        r = await http.get(
            Uri.parse("https://animepahe.ru/anime/${result.first['session']}/"),
            headers: headers);
        return await getRefresh(r, item: item);
      }
    }
    return item;
  }

  Future<HomeItem> getRefresh(http.Response r,
      {HomeItem? item, String? sess, int? id}) async {
    var soup = BeautifulSoup(r.body);
    String title =
        soup.find('div', class_: 'title-wrapper')?.h1?.find("span")?.text ?? '';
    String subtitle = soup.find('div', class_: 'title-wrapper')?.h2?.text ?? '';
    Map summary = {
      "synopsis": soup.find("div", class_: "anime-synopsis")?.text,
      "details": [
        for (var n
            in soup.find("div", class_: "col-sm-4 anime-info")?.findAll("p") ??
                [])
          n?.text
              ?.trim()
              .replaceAll("  ", "")
              .replaceAll('\n', '')
              .replaceAll(":", ": ")
              .replaceAll(":  ", ": ")
      ]
    };
    int epiPage = 1;
    bool nextPage = true;
    List episodes = [];
    Box box = Hive.box("offline");
    do {
      r = await http.get(
          Uri.parse(
              "https://animepahe.ru/api?m=release&id=${item?.session ?? sess}&sort=episode_asc&page=$epiPage"),
          headers: headers);
      var response = jsonDecode(r.body);
      List datas = response['data'];
      for (var data in datas) {
        Map info = {
          "anime_title": data["duration"],
          "id": data['id'],
          "episode": data['episode'],
          "episode2": data['episode2'],
          "snapshot": data["snapshot"],
          "anime_session": item?.session ?? sess,
          "session": data['session']
        };
        episodes.add(Pahe(data: info));
      }
      epiPage++;
      nextPage = response['next_page_url'] != null ? true : false;
    } while (nextPage);
    if (item != null) {
      HomeItem newItem = HomeItem(
          title: title,
          homeId: item.homeId,
          session: item.session,
          subtitle: subtitle,
          summary: summary,
          id: item.id,
          imageUrl: item.imageUrl,
          imagePath: item.imagePath,
          episodes: episodes,
          height: item.height);
      // box = Hive.box("offline");
      // await box.put(item.homeId, newItem);
      return newItem;
    } else {
      Directory path = Directory("${(await docPath).path}\\HomeLib\\posters");
      if (!path.existsSync()) {
        await path.create(recursive: true);
      }
      var fileName = title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      File poster = File("${path.path}\\$fileName.png");
      if (!await poster.exists()) {
        await poster.create();
      }
      int homeId = box.keys.isEmpty ? 0 : box.keys.last;
      homeId++;
      var uri =
          soup.find('div', class_: "anime-poster")?.find('img')?['data-src'] ??
              '';
      Uint8List image = (await http.get(Uri.parse(uri))).bodyBytes;
      final buffer = await ImmutableBuffer.fromUint8List(image);
      final descriptor = await ImageDescriptor.encoded(buffer);
      double imgHeight = descriptor.height.toDouble();
      descriptor.dispose();
      buffer.dispose();
      HomeItem newItem = HomeItem(
          title: title,
          homeId: homeId,
          session: sess ?? '',
          subtitle: subtitle,
          summary: summary,
          id: id,
          imageUrl: uri,
          imagePath: poster.path,
          episodes: episodes,
          height: imgHeight);
      // box = Hive.box("offline");
      // await box.put(newItem.homeId, newItem);
      return newItem;
    }
  }

  void migrate() async {
    Box box = Hive.box("settings");
    var deez = box.get("path");
    if (Platform.isAndroid) {
      var util = SafUtil();
      Map<String, List> simple = {};
      List migratees = await util.list((await util.list(deez))
          .firstWhere((value) => value.name == "Migrate")
          .uri);
      for (SafDocumentFile epi in migratees) {
        String aniName = RegExp(r'AnimePahe_(.+)_-_(\d+|\d+-\d+)_(?:BD_)?(\d+)')
                .firstMatch(epi.name)
                ?.group(1) ??
            "";
        // String epiName = RegExp(r'AnimePahe_(.+)_-_(\d+|\d+-\d+)_(?:BD_)?(\d+)').firstMatch(epi.name)?.group(2)??"";
        if (simple[aniName] == null) {
          simple[aniName] = [epi];
        } else {
          simple[aniName]?.add(epi);
        }
      }
      for (String key in simple.keys) {
        print(key);
        var r = await http.get(
            Uri.parse("https://animepahe.ru/api?m=search&q=$key"),
            headers: headers);
        Map jsonResult = json.decode(r.body);
        var result = (jsonResult['data'] as List).first;
        if (result.isNotEmpty) {
          r = await http.get(
              Uri.parse(
                  "https://animepahe.ru/anime/${result['session']}/"),
              headers: headers);
          HomeItem item = await getRefresh(r,
              sess: result['session'], id: result['id']);
          print(item.title);
        }
      }
    }
    print("object");
  }
}
