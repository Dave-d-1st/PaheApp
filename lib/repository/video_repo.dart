import 'dart:convert';
import 'dart:io';

import 'package:app/models/home_item.dart';
import 'package:app/models/pahe.dart';
import 'package:app/models/realtive_vid.dart';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dio/dio.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util.dart';
import 'package:saf_util/saf_util_platform_interface.dart';

class VideoRepo {
  Map<String, String> headers = {
    "Cookie":
        "__ddgid_=sE1YjW2vvFeZ9eMN; __ddgmark_=lxBaq42Dv71DNn34; __ddg2_=u2F6XKyQ9gVjlihp; __ddg1_=qbup7B4r1G6i5TWkt7RT;SERVERID=janna;XSRF-TOKEN=eyJpdiI6IjMwejVVQWpqYzBCZ0Z1YmhsZnZXM3c9PSIsInZhbHVlIjoiQ25Mdno0cUJyUTc0cU1rUW1NWVB0RXo5R1BkZFhBM1hRd1VObmYxSTRKTUNKZTZHdmF3VWdJbyswcWZMdmM1SUtONmlDc293VGRvbER4MFd3eDNGVEZpZC92L05QNVpjSmxGTEhzMlA3UGh0Wk5wSXVqK01KRXZCc2lWRkVZQXIiLCJtYWMiOiJlZjQxZjJlNzFkNWFlOTc2YjgwOTY5OTQyY2VhMDg2OTg3YTQyNDBjMTdlY2ZiMzllMjE0ZmE0YzI4ZTFiMzg1IiwidGFnIjoiIn0%3D; laravel_session=eyJpdiI6Im5STkE5Q040dm1pVFFxQzdOR2d2RXc9PSIsInZhbHVlIjoiVTVaQmEvVEd0MVBBVVJ4bjMrVS94RXYzbTAwMnpFelhkVXYxTWFRSFJXSFVPZ2dzNkEyRXlXNW9neXdPeTlUQ0pISzZ2T0c0TUxiOVRnaW14N21OQTBkMW1JbWdEK0FvdFptTWxKQmcrc2pDbWRQMk9kbDkvMnZYSmVuVGhMQnciLCJtYWMiOiI5Yzc5ZmMzNjVlNDAzZDc4MTEzN2VjNjMzNTliZjExY2EyYzQyYzMyMjNiNWIzYTlhODEwMzEyMzk4MzQxODkzIiwidGFnIjoiIn0%3D"
  };

  List? resolutions;
  List? androidPath;

  String session = '';
  String get path {
    Box box = Hive.box("settings");
    return box.get("path");
  }

  bool get fallBackRes {
    Box box = Hive.box("settings");
    return box.get("fallBackResHigh");
  }

  bool get getM3u8 {
    Box box = Hive.box("settings");
    return box.get("getM3u8");
  }

  Future<List> get currentDownloads async {
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
                  downloads.add(resolution);
                }
              }
            }
          }
        }
      }
    }
    if (Platform.isAndroid) {
      var util = SafUtil();
      var downloadPath = (await util.list(path))
          .singleWhere((value) => value.name == "Downloads");
      List downloaded = await util.list(downloadPath.uri);
      for (SafDocumentFile animes in downloaded) {
        if (animes.isDir) {
          for (SafDocumentFile episodes in await util.list(animes.uri)) {
            if (episodes.isDir) {
              for (SafDocumentFile resolution
                  in await util.list(episodes.uri)) {
                if (resolution.isDir &&
                    (await util.list(resolution.uri)).isNotEmpty) {
                  downloads.add(resolution);
                }
              }
            }
          }
        }
      }
    }
    return downloads;
  }

  Map data = {};
  String get resolution {
    final box = Hive.box("settings");
    final String res = box.get('resolution');
    return res;
  }

  bool get fallBackResHigh {
    final box = Hive.box("settings");
    final bool fallBack = box.get("fallBackResHigh");
    return fallBack;
  }

  Map? videoSession;

  void updateTime(String episode, Duration time, Duration total) {
    var box = Hive.box('playtime');
    box.put(episode, {"duration": time.inSeconds, "total": total.inSeconds});
  }

  Future<Map> changeRes(String res, bool eng) async {
    RegExp regExp = RegExp(r'\d+');
    Iterable<Match> matches = regExp.allMatches(res);
    String result = matches.map((match) => match.group(0)).join();
    if (resolutions?.first is Variant) {
      Variant currentRes = resolutions?.firstWhere((e) =>
          (e.format.height == int.tryParse(result)) &&
          (res.contains(". U") ? e.format.label == null : true));
      if (currentRes.format.label != null) {
        data["videoUrl"] = currentRes.url.toString();
        data["curRes"] = "${currentRes.format.height}p";
      } else {
        String path2 =
            "${(await getApplicationDocumentsDirectory()).path}/HomeLib/index.m3u8";
        print(File(path2).readAsLinesSync()
          ..removeLast()
          ..removeLast()
          ..add(
              '#EXT-X-STREAM-INF:BANDWIDTH=${currentRes.format.bitrate},RESOLUTION=${currentRes.format.width}x${currentRes.format.height},AUDIO="audio",SUBTITLES="subs"')
          ..add(currentRes.url.toString()));
        final buffer = StringBuffer();
        for (var line in File(path2).readAsLinesSync()
          ..removeLast()
          ..removeLast()
          ..add(
              '#EXT-X-STREAM-INF:BANDWIDTH=${currentRes.format.bitrate},RESOLUTION=${currentRes.format.width}x${currentRes.format.height},AUDIO="audio",SUBTITLES="subs"')
          ..add(currentRes.url.toString())) {
          buffer.writeln(line);
        }
        File(path2).writeAsString(buffer.toString());
        data["videoUrl"] = path2;
        data["curRes"] = "${currentRes.format.height}p . U";
        print("${currentRes.format.height}p . U");
      }
    } else {
      var currentRes = resolutions
          ?.map(
            (element) {
              if (element['data-resolution'] == result &&
                  (eng
                      ? element['data-audio'] == ("eng")
                      : element['data-audio'] != ("eng"))) {
                return element;
              }
              if (resolutions!.indexOf(element) == resolutions!.length - 1) {
                return fallBackResHigh ? resolutions?.last : resolutions?.first;
              }
            },
          )
          .where((element) => element != null)
          .first;
      if (!eng) {
        String animeTitle = data['title'].split(" - ").first;
        String episode = data['title'].split(" - ").last;
        dynamic dir = List.from(await currentDownloads).singleWhere((value) {
          List segments = Platform.isWindows
              ? value.uri.pathSegments
              : (Uri.parse(value.uri).pathSegments.last.split("/")..add(''));
          return animeTitle.replaceAll(RegExp(r'[^\w\s-]'), "") ==
                  segments.elementAtOrNull(segments.length - 4) &&
              episode == segments.elementAtOrNull(segments.length - 3) &&
              "${segments.elementAtOrNull(segments.length - 2)}" == result;
        }, orElse: () => null);
        if (dir is SafDocumentFile) {
          var stream = SafStream();
          var newPath = (await getExternalCacheDirectories())?.first;
          newPath ??= await getApplicationCacheDirectory();
          dir = (await SafUtil().list(dir.uri)).first;
          Directory player = Directory("${newPath.path}/player/");
          if (!(await player.exists())) await player.create(recursive: true);
          await stream.copyToLocalFile(
              dir.uri, "${newPath.path}/player/video.mp4");
          dir = Directory("${newPath.path}/player/");
        }
        if (dir != null) {
          data["curRes"] = currentRes?.text;
          data["videoUrl"] = dir.path;
          return data;
        }
      }
      Uri uri = Uri.parse(currentRes?['data-src'] ?? '');
      http.Response r = await http.get(uri, headers: headers);
      var code = r.body.split("return p}")[2].split("</script>")[0];
      RegExp re = RegExp(r"'(.+)',(\d+),(\d+),'(\S+)'\.split\('\|'\)");
      var search = re.firstMatch(code);
      String vidUrl = m3u8Decoder(search?[1] ?? '', int.parse(search?[2] ?? ''),
          int.parse(search?[3] ?? ''), search?[4]!.split('|') ?? []);
      videoSession?[session][resolution] = vidUrl;
      data["curRes"] = currentRes?.text;
      data["videoUrl"] = vidUrl;
    }
    return data;
  }

  Future initializeOffline(String episodeTitle,
      [bool useHighest = false]) async {
    String animeTitle = episodeTitle.split(" - ").first;
    String episode = episodeTitle.split(" - ").last;
    dynamic dir = List.from(await currentDownloads).where((value) {
      List segments = Platform.isWindows
          ? value.uri.pathSegments
          : (Uri.parse(value.uri).pathSegments.last.split("/")..add(''));
      return animeTitle.replaceAll(RegExp(r'[^\w\s-]'), "") ==
              segments.elementAtOrNull(segments.length - 4) &&
          episode == segments.elementAtOrNull(segments.length - 3) &&
          (useHighest
              ? true
              : "${segments.elementAtOrNull(segments.length - 2)}p" ==
                  resolution);
    });
    if (dir is Iterable && dir.isNotEmpty) {
      dir = dir.length > 1 ? dir.last : dir.single;
    } else {
      dir = null;
    }
    if (dir is SafDocumentFile) {
      var stream = SafStream();
      var newPath = (await getExternalCacheDirectories())?.first;
      newPath ??= await getApplicationCacheDirectory();
      androidPath = (Uri.parse(dir.uri).pathSegments.last.split("/")..add(''));
      dir = (await SafUtil().list(dir.uri)).first;
      Directory player = Directory("${newPath.path}/player/");
      if (!(await player.exists())) await player.create(recursive: true);
      await stream.copyToLocalFile(dir.uri, "${newPath.path}/player/video.mp4");
      dir = Directory("${newPath.path}/player/");
    }
    return dir;
  }

  Future getVideo(String sessio, [String? episodeTitle]) async {
    session = sessio;
    if (episodeTitle != null) {
      var dir = await initializeOffline(episodeTitle);
      if (dir != null) {
        try {
          await initializeOnline();
          data["videoUrl"] = dir.listSync().first.path;
          List segments =
              Platform.isWindows ? dir.uri.pathSegments : androidPath ?? [];
          String usedRes = segments.elementAtOrNull(segments.length - 2);
          List resolutions = data['res'];
          int index =
              resolutions.indexWhere((value) => value.contains(usedRes));
          if (index >= 0) resolutions.removeAt(index);
          resolutions.insert(index, "Offline · ${usedRes}p");
          data['res'] = resolutions;
          data['curRes'] = "Offline · ${usedRes}p";
          return data;
        } on http.ClientException {
          print("Error");
          fallBackOffline(episodeTitle, dir);
          return data;
        }
      }
    }
    try {
      await initializeOnline();
      return data;
    } on http.ClientException catch (e) {
      if (episodeTitle != null) {
        var dir = await initializeOffline(episodeTitle, true);
        if (dir != null) {
          fallBackOffline(episodeTitle, dir);
        } else {
          return e;
        }
        print("Error");
        return data;
      }
    }
  }

  void fallBackOffline(String episodeTitle, dir) {
    String animeTitle = episodeTitle.split(" - ").first;
    String episode = episodeTitle.split(" - ").last;

    Box box = Hive.box("offline");
    List episodes = (box.values
                .singleWhere((value) => value.title == animeTitle) as HomeItem?)
            ?.episodes ??
        [];
    Pahe pahe = episodes.singleWhere((value) =>
        "${(value.episode2 != null && value.episode2 != 0) ? '${value.episode}-${value.episode2}' : value.episode}" ==
        episode);
    int paheIndex = episodes.indexOf(pahe);
    Pahe? after = paheIndex == episodes.length - 1
        ? null
        : episodes.elementAtOrNull(paheIndex + 1);
    Pahe? before =
        paheIndex == 0 ? null : episodes.elementAtOrNull(paheIndex - 1);
    RealtiveVid? next = after != null
        ? RealtiveVid(
            session: "${after.animeSession}/${after.episodeSession}",
            title:
                "$animeTitle - ${(after.episode2 != null && after.episode2 != 0) ? '${after.episode}-${after.episode2}' : after.episode}",
          )
        : null;
    RealtiveVid? prev = before != null
        ? RealtiveVid(
            session: "${before.animeSession}/${before.episodeSession}",
            title:
                "$animeTitle - ${(before.episode2 != null && before.episode2 != 0) ? '${before.episode}-${before.episode2}' : before.episode}",
          )
        : null;

    Duration playTime = Duration(
        seconds: Hive.box('playtime').get(episodeTitle,
                defaultValue: {"duration": null})['duration'] ??
            0);

    List segments = Platform.isWindows ? dir.uri.pathSegments : androidPath;
    data = {
      'title': episodeTitle,
      "res": ["Offline · ${segments.elementAtOrNull(segments.length - 2)}p"],
      "curRes": "Offline · ${segments.elementAtOrNull(segments.length - 2)}p",
      "next": next,
      "prev": prev,
      "videoUrl": dir.listSync().first.path,
      "playTime": playTime
    };
  }

  Future<void> initializeOnline() async {
    if (session.startsWith("https:")) {
      Uri uri = Uri.parse(session);
      http.Response r = await http.get(uri, headers: headers);
      BeautifulSoup soup = BeautifulSoup(r.body);
      String title = soup.find("div", class_: "video-title")?.text ?? '';
      Duration playTime = Duration(
          seconds: Hive.box('playtime')
                  .get(title, defaultValue: {"duration": null})['duration'] ??
              0);
      resolutions = [];
      RealtiveVid? next = soup.find("a", attrs: {"rel": "next"}) != null
          ? RealtiveVid(
              session: soup.find("a", attrs: {"rel": "next"})?['href'] ?? '')
          : null;
      RealtiveVid? prev = soup.find("a", attrs: {"rel": "prev"}) != null
          ? RealtiveVid(
              session: soup.find("a", attrs: {"rel": "prev"})?['href'] ?? '')
          : null;
      Uri url = Uri.parse(soup.find("iframe", id: "anime-js-0")?['src'] ??
          soup.find("iframe", id: "cizgi-js-0")?['src'] ??
          '');
      Map<String, String> header = {
        "Referer": "https://www.wcofun.org/",
      };
      r = await http.get(url, headers: header);
      var soupe = BeautifulSoup(r.body);
      RegExp pattern = RegExp(r'getJSON\(\"(.+)\"');
      var group = pattern.firstMatch(soupe.prettify())?.group(1);
      uri = Uri.parse("https://embed.watchanimesub.net$group");
      header["X-Requested-With"] = "XMLHttpRequest";
      header['Referer'] = url.toString();
      r = await http.get(uri, headers: header);
      Map jsoned = json.decode(r.body
          .replaceAll('"enc"', '"480p"')
          .replaceAll('"hd"', '"720p"')
          .replaceAll('"fhd"', '"1080p"'));
      for (var res in const ['480p', '720p', '1080p']) {
        if (jsoned[res] != null && jsoned[res] != '') {
          String lin = jsoned['server'] + "/getvid?evid=${jsoned[res]}";
          var vari = Variant(
              url: Uri.parse(lin),
              format: Format(
                  label: res, height: int.tryParse(res.replaceAll("p", ''))),
              videoGroupId: null,
              audioGroupId: null,
              subtitleGroupId: null,
              captionGroupId: null);
          resolutions?.add(vari);
        }
      }
      print(soup.find("iframe", id: "anime-js-1")?['src'] != null);
      if ((soup.find("iframe", id: "anime-js-1")?['src'] != null)?
          ((resolutions?.map((e)=>e.format.height)??[]).contains(resolution) ? getM3u8 : true):false) {
            print(2);
        r = await http.get(
            Uri.parse(soup.find("iframe", id: "anime-js-1")?['src'] ?? ''),
            headers: header);
        soup = BeautifulSoup(r.body);
        String m3u8Link = BeautifulSoup(soup.find("video")?.nodes[1].text ?? '')
                .find('source')?['src'] ??
            '';
        var dio = Dio();
        var rd = await dio.get(m3u8Link);
        var playlist =
            await HlsPlaylistParser.create().parseString(rd.realUri, rd.data);
        if (playlist is HlsMasterPlaylist) {
          Variant? video = List.from(playlist.variants).singleWhere(
            (element) =>
                element.format.height ==
                int.tryParse(resolution.replaceAll("p", "")),
            orElse: () => null,
          );
          var audio = List.from(playlist.audios).firstWhere(
            (element) => element.format.language.contains('eng'),
            orElse: () => null,
          );
          if (video == null || audio == null) {
            String link = jsoned['server'] +
                "/getvid?evid=${jsoned[resolution] ?? fallBackRes ? jsoned['1080'] : jsoned['480']}";

            if (jsoned['720'] == "" && jsoned['1080'] == "") {
              link = jsoned['server'] + "/getvid?evid=${jsoned['480']}";
            } else if (jsoned['720'] != "" && jsoned['1080'] == "") {
              link = jsoned['server'] + "/getvid?evid=${jsoned['720']}";
            }
            data = {
              'title': title.trim(),
              "res": resolutions,
              "curRes": "",
              "videoUrl": link,
              "prev": prev,
              "next": next,
              "playTime": playTime
            };
            return;
          }
          final buffer = StringBuffer();
          buffer.writeln('#EXTM3U');
          buffer.writeln(
              '#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="${audio.groupId}",LANGUAGE="${audio.format.language}",NAME="${audio.name}",URI="${audio.url}"');
          buffer.writeln(
              '#EXT-X-STREAM-INF:BANDWIDTH=${video.format.bitrate},RESOLUTION=${video?.format.width}x${video.format.height},AUDIO="audio",SUBTITLES="subs"');
          buffer.writeln(video.url);
          var path2 =
              "${(await getApplicationDocumentsDirectory()).path}/HomeLib/index.m3u8";
          await File(path2).writeAsString(buffer.toString());
          var variants = playlist.variants;
          variants.sort(
              (a, b) => a.format.height?.compareTo(b.format.height ?? 0) ?? 0);
          for (var varaint in variants) {
            resolutions?.add(varaint);
          }
          if (resolutions?.map((e) => e.format.label).contains(resolution) ??
              false) {
            String link = jsoned['server'] +
                "/getvid?evid=${jsoned[resolution] ?? jsoned[fallBackRes ? resolutions?.last : resolutions?.first]}";
            String rese = jsoned.entries
                .singleWhere(
                  (element) =>
                      element.value == link.split('/getvid?evid=').last,
                )
                .key;
            data = {
              'title': title.trim(),
              "res": resolutions?.map(
                (e) {
                  if (e is Variant) {
                    if (e.format.label == null) {
                      return "${e.format.height}p . U";
                    } else {
                      return e.format.label;
                    }
                  }
                },
              ).toList(),
              "curRes": rese,
              "videoUrl": link,
              "prev": prev,
              "next": next,
              "playTime": playTime
            };
          } else {
            data = {
              'title': title.trim(),
              "res": resolutions?.map(
                (e) {
                  if (e is Variant) {
                    if (e.format.label == null) {
                      return "${e.format.height}p . U";
                    } else {
                      return e.format.label;
                    }
                  }
                },
              ).toList(),
              "curRes": "${video.format.height}p . U",
              "videoUrl": path2,
              "prev": prev,
              "next": next,
              "playTime": playTime
            };
          }
        }
      } else {
        print(3);
        String link = jsoned['server'] +
            "/getvid?evid=${jsoned[resolution] ?? jsoned[fallBackRes ? resolutions?.last : resolutions?.first]}";
        String rese = jsoned.entries
            .singleWhere(
              (element) => element.value == link.split('/getvid?evid=').last,
            )
            .key;
        print(resolutions);
        data = {
          'title': title.trim(),
          "res": resolutions?.map(
            (e) {
              if (e is Variant) {
                if (e.format.label == null) {
                  return "${e.format.height} . U";
                } else {
                  return e.format.label;
                }
              }
            },
          ).toList(),
          "curRes": rese,
          "videoUrl": link,
          "prev": prev,
          "next": next,
          "playTime": playTime
        };
      }
    } else {
      Uri uri = Uri.parse("https://animepahe.ru/play/$session");
      http.Response r = await http.get(uri, headers: headers);
      BeautifulSoup soup = BeautifulSoup(r.body);
      String title =
          soup.find("div", class_: "theatre-info")!.h1!.children[1].text +
              soup
                  .find("div", class_: "theatre-info")!
                  .h1!
                  .innerHtml
                  .split("a>")
                  .last
                  .split("<span")
                  .first;
      Duration playTime = Duration(
          seconds: Hive.box('playtime')
                  .get(title, defaultValue: {"duration": null})['duration'] ??
              0);
      videoSession ??= {
        for (var link in soup
                .find("div", id: "scrollArea")
                ?.findAll('a', class_: "dropdown-item") ??
            [])
          if (link["href"] != null)
            link['href'].replaceAll("/play/", ''): {
              "title": '',
              "720p": '',
              "360p": '',
              "1080p": '',
            }
      };
      resolutions = soup.find("div", id: "resolutionMenu")?.findAll("button");
      var currentRes = resolutions
          ?.map(
            (element) {
              print(element['data-audio']);
              if (element['data-resolution'] ==
                      (resolution.replaceAll('p', '')) &&
                  (element['data-audio'] != "eng")) {
                return element;
              }
              if (resolutions!.indexOf(element) == resolutions!.length - 1) {
                return fallBackResHigh
                    ? resolutions
                        ?.where((value) => value['data-audio'] == 'jpn')
                        .last
                    : resolutions
                        ?.where((value) => value['data-audio'] == 'jpn')
                        .first;
              }
            },
          )
          .where((element) => element != null)
          .first;
      headers['referer'] = uri.toString();
      uri = Uri.parse(currentRes?['data-src'] ?? '');
      r = await http.get(uri, headers: headers);
      soup = BeautifulSoup(r.body);
      var code = r.body.split("return p}")[2].split("</script>")[0];
      RegExp re = RegExp(r"'(.+)',(\d+),(\d+),'(\S+)'\.split\('\|'\)");
      var search = re.firstMatch(code);
      String vidUrl = m3u8Decoder(search?[1] ?? '', int.parse(search?[2] ?? ''),
          int.parse(search?[3] ?? ''), search?[4]!.split('|') ?? []);
      videoSession?[session][resolution] = vidUrl;
      videoSession?[session]['title'] = title;
      var elementAtOrNull = videoSession?.keys.elementAtOrNull(
          (videoSession?.keys.toList().indexOf(session) ?? 0) + 1);
      RealtiveVid? next = elementAtOrNull != null
          ? RealtiveVid(session: elementAtOrNull)
          : null;
      RealtiveVid? previous =
          (videoSession?.keys.toList().indexOf(session) ?? 0) > 0
              ? RealtiveVid(
                  session: videoSession?.keys.elementAtOrNull(
                      (videoSession?.keys.toList().indexOf(session) ?? 0) - 1))
              : null;
      data = {
        'title': title,
        "res": resolutions?.map((value) => value.text).toList(),
        "curRes": currentRes?.text,
        "videoUrl": vidUrl,
        "prev": previous,
        "next": next,
        "playTime": playTime
      };
    }
  }

  String m3u8Decoder(String text, int a, int m, List<String> k) {
    String alphabet = '0123456789abcdefghijklmnopqrstuvwxyz';
    String e(c) {
      var las = c < a ? null : e(c ~/ a);
      c = c % a;
      var fir = c > 35 ? String.fromCharCode(c + 29) : alphabet[c];
      return las != null ? "$las$fir" : fir;
    }

    Map d = {};
    m--;
    while (m >= 0) {
      d[e(m)] = k[m] != '' ? k[m] : e(m);
      m--;
    }
    String mni(e) {
      return d[e[0]];
    }

    var m3u8Url = text.replaceAllMapped(
      RegExp(r"\b\w+\b"),
      (match) => mni(match),
    );
    return m3u8Url
        .split("source=")[1]
        .split(";")[0]
        .replaceAll(r"\", "")
        .replaceAll("'", "");
  }

  void done() async {
    if (Platform.isAndroid) {
      var newPath = (await getExternalCacheDirectories())?.first;
      newPath ??= await getApplicationCacheDirectory();
      Directory dir = Directory("${newPath.path}/player/");
      if (await dir.exists()) {
        for (var file in dir.listSync()) {
          if (file is File) {
            await file.delete();
          }
        }
      }
    }
  }
}
