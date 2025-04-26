import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util.dart';
import 'package:hive/hive.dart';
import 'package:app/models/download.dart';
import 'package:app/scripts/downloader.dart';
import 'package:http/http.dart' as http;

class DownloadRepo {
  List<Download> get downloading {
    Box<Download> box = Hive.box<Download>("download");
    List<Download> values = box.values.toList();
    values.sort(
      (a, b) => a.id.compareTo(b.id),
    );
    return values;
  }

  int? currentid;
  List get currentDownloads {
    List downloads = [];
    if (Platform.isWindows) {
      Directory downloadPath = Directory(path);
      for (FileSystemEntity animes in downloadPath.listSync()) {
        if (animes is Directory) {
          for (FileSystemEntity episodes in animes.listSync()) {
            if (episodes is Directory) {
              for (FileSystemEntity resolution in episodes.listSync()) {
                if (resolution is Directory &&
                    resolution.listSync().isNotEmpty) {
                  downloads.add(episodes);
                }
              }
            }
          }
        }
      }
    }
    if (Platform.isAndroid) {
      var util = SafUtil();

      util.list(path).then((value) {
        value.where((value) => value.isDir).forEach((value) {
          util.list(value.uri).then(
              (value) => value.where((value) => value.isDir).forEach((value) {
                    util.list(value.uri).then((value) =>
                        value.where((value) => value.isDir).forEach((value) {
                          util.list(value.uri).then((value) => value
                                  .where((value) => value.isDir)
                                  .forEach((value) async {
                                if ((await util.list(value.uri)).isNotEmpty) {
                                  downloads.add(value);
                                }
                              }));
                        }));
                  }));
        });
      });
    }
    return downloads;
  }

  final StreamController controller = StreamController.broadcast();
  bool running = false;
  String get path {
    Box box = Hive.box("settings");
    return box.get("path");
  }

  bool paused = true;
  Future<void> addDownload(String url, String title) async {
    Box<Download> box = Hive.box<Download>("download");
    int id = 0;
    await Future.delayed(Duration.zero);
    if (currentid == null) {
      id = downloading.isNotEmpty
          ? downloading.toList().reduce((a, b) => a.id > b.id ? a : b).id + 1
          : 1;
      currentid = id;
    } else {
      id = (currentid ?? 0) + 1;
      currentid = id;
    }
    Map data = {"title": title, "url": "", "id": id, "session": url};

    var download = Download(data);
    await box.put(id, download);
    controller.add(0);
    await Future.delayed(Duration.zero);
    try {
      String downloadLink = await Downloader().getDownloadLink(url);
      data = {"title": title, "url": downloadLink, "id": id, "session": url};
      download = Download(data);
      await box.put(id, download);
    } catch (e) {
      data = {"title": title, "url": "", "id": id, "session": url};
      download = Download(data, status: DownloadStatus.error);
      await box.put(id, download);
    }
    startDownload();
  }

  void startDownload() async {
    if (running) {
      return;
    }
    running = true;
    Box<Download> box = Hive.box<Download>("download");
    var client = http.Client();
    var nonErrorDownloading =
        downloading.where((value) => value.status != DownloadStatus.error);
    while (nonErrorDownloading.isNotEmpty) {
      if (paused) {
        running = false;
        return;
      }
      int size = 0;
      int bufferSize = 0;
      Download download = nonErrorDownloading.first;
      if (download.downloadUrl == "") {
        nonErrorDownloading =
            downloading.where((value) => value.status != DownloadStatus.error);
        await Future.delayed(Duration(seconds: 1));
        continue;
      }
      try {
        var getRequest = http.Request('GET', Uri.parse(download.downloadUrl));
        var request = await client.send(getRequest);
        int filesize = request.contentLength ?? 0;
        String filename = download.title.replaceAll(RegExp(r'[^\w\s-]'), "");
        Map data = download.data;
        data['size'] = filesize;
        data['name'] = filename.replaceAll(RegExp(r'[^\w\s-]'), "");
        String res = "720";
        String dir = filename.split(" - ").first;
        String episode = filename.split(" - ").last;

        File file = Platform.isAndroid
            ? File(
                "${(await getExternalCacheDirectories())?.first.path ?? (await getApplicationDocumentsDirectory()).path}/Downloads/cache/$filename")
            : File("$path/Downloads/cache/$filename");
        if (await file.exists()) {
          getRequest = http.Request('GET', Uri.parse(download.downloadUrl));
          size = (await file.readAsBytes()).length;
          getRequest.headers.addAll({"Range": "bytes=$size-"});
          request = await client.send(getRequest);
        }
        await file.create(recursive: true);
        var sink = file.openWrite(mode: FileMode.writeOnlyAppend);
        DateTime startTime = DateTime.now();
        await for (var chunk in request.stream) {
          if (paused) {
            await sink.flush();
            await sink.close();
            client.close();
            running = false;
            return;
          }
          if (downloading.isEmpty || download != downloading.first) {
            break;
          }
          size += chunk.length;
          bufferSize += chunk.length;
          sink.add(chunk);
          data['progress'] = size / filesize;
          data['current'] = size;
          if (size > 0) {
            DateTime currentTime = DateTime.now();
            int elapsedTimeInSeconds =
                currentTime.difference(startTime).inSeconds;
            if (elapsedTimeInSeconds > 0) {
              double rate = bufferSize / elapsedTimeInSeconds;
              data['speed'] = rate;
              controller.add(0);
              bufferSize = 0;
              startTime = DateTime.now();
            }
          }
          await box.put(
              download.id, Download(data, status: DownloadStatus.running));
        }
        if (paused) {
          await sink.flush();
          await sink.close();
          client.close();
          running = false;
          return;
        }
        if (downloading.isEmpty || download != downloading.first) {
          await sink.flush();
          await sink.close();
          nonErrorDownloading = downloading
              .where((value) => value.status != DownloadStatus.error);
          continue;
        }
        await sink.flush();
        await sink.close();
        if (Platform.isWindows) {
          await Directory("$path\\$dir\\$episode\\$res\\")
              .create(recursive: true);
          await file.rename("$path\\$dir\\$episode\\$res\\$filename.mp4");
        }
        if (Platform.isAndroid) {
          var util = SafUtil();
          var downloadPath = await util.mkdirp(
              (await util.mkdirp(
                      (await util.mkdirp(
                              (await util.mkdirp(path, ["Downloads"])).uri,
                              [dir]))
                          .uri,
                      [episode]))
                  .uri,
              [res]);
          var stream = SafStream();
          await stream.writeFileBytes(downloadPath.uri, "$filename.mp4",
              "video/mp4", await file.readAsBytes());
          await file.delete();
        }

        controller.add(0);
        await Future.delayed(Duration.zero);
        box.delete(download.id);
        Future.delayed(Duration(seconds: 1)).then((value) => controller.add(0));
        nonErrorDownloading =
            downloading.where((value) => value.status != DownloadStatus.error);
      } on Exception catch (e) {
        await box.put(
            download.id, Download(download.data, status: DownloadStatus.error));
        controller.add(0);
      }
    }
    client.close();
    running = false;
  }

  Future<void> changeOrder(int oldIndex, int newIndex) async {
    List<Download> newList = downloading;
    int firstId = 1;
    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    Box<Download> box = Hive.box<Download>("download");
    await box.clear();
    for (Download value in newList) {
      Map data = value.data;
      data['id'] = firstId;
      Download down = Download(data, status: value.status);
      box.put(down.id, down);
      firstId++;
    }
  }

  void playPause() async {
    paused = !paused;
    if (!paused) {
      Iterable errorDownloading =
          downloading.where((value) => value.status == DownloadStatus.error);
      for (Download error in errorDownloading) {
        await restore(error);
      }
      running = false;

      startDownload();
    }
  }

  Future<void> restore(Download download) async {
    Box<Download> box = Hive.box<Download>("download");
    Map data = download.data;
    try {
      String newLink = await Downloader().getDownloadLink(download.session);
      data['url'] = newLink;
      Download newDown = Download(data);
      if (newDown.id == box.get(newDown.id)?.id) {
        await box.put(download.id, newDown);
      }
    } catch (e) {
      Download newDown = Download(data, status: DownloadStatus.error);
      if (newDown.id == box.get(newDown.id)?.id) {
        await box.put(download.id, newDown);
      }
      controller.add(0);
    }
  }

  Future<void> cancel(int index) async {
    Download download = downloading.elementAt(index);
    File file = File(
        "${(await getApplicationDocumentsDirectory()).path}/Downloads/cache/${download.filename}");
    if (await file.exists()) {
      await file.delete();
    }
    Box<Download> box = Hive.box<Download>("download");
    await box.delete(download.id);
  }

  Future<void> groupCancel(String title) async {
    RegExp re = RegExp(r'(.+) - [\d+]');
    String groupTitle = re.allMatches(title).first.group(1) ?? "";
    for (int i = 0; i <= downloading.length - 1; i++) {
      String elementTitle =
          re.allMatches(downloading.elementAt(i).title).first.group(1) ?? "";
      if (elementTitle == groupTitle) {
        await cancel(i);
        i--;
      }
    }
  }
}
