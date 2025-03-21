import 'dart:ffi';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class VideoRepo {
  Map<String, String> headers = {
    "Cookie":
        "__ddgid_=sE1YjW2vvFeZ9eMN; __ddgmark_=lxBaq42Dv71DNn34; __ddg2_=u2F6XKyQ9gVjlihp; __ddg1_=qbup7B4r1G6i5TWkt7RT;SERVERID=janna;XSRF-TOKEN=eyJpdiI6IjMwejVVQWpqYzBCZ0Z1YmhsZnZXM3c9PSIsInZhbHVlIjoiQ25Mdno0cUJyUTc0cU1rUW1NWVB0RXo5R1BkZFhBM1hRd1VObmYxSTRKTUNKZTZHdmF3VWdJbyswcWZMdmM1SUtONmlDc293VGRvbER4MFd3eDNGVEZpZC92L05QNVpjSmxGTEhzMlA3UGh0Wk5wSXVqK01KRXZCc2lWRkVZQXIiLCJtYWMiOiJlZjQxZjJlNzFkNWFlOTc2YjgwOTY5OTQyY2VhMDg2OTg3YTQyNDBjMTdlY2ZiMzllMjE0ZmE0YzI4ZTFiMzg1IiwidGFnIjoiIn0%3D; laravel_session=eyJpdiI6Im5STkE5Q040dm1pVFFxQzdOR2d2RXc9PSIsInZhbHVlIjoiVTVaQmEvVEd0MVBBVVJ4bjMrVS94RXYzbTAwMnpFelhkVXYxTWFRSFJXSFVPZ2dzNkEyRXlXNW9neXdPeTlUQ0pISzZ2T0c0TUxiOVRnaW14N21OQTBkMW1JbWdEK0FvdFptTWxKQmcrc2pDbWRQMk9kbDkvMnZYSmVuVGhMQnciLCJtYWMiOiI5Yzc5ZmMzNjVlNDAzZDc4MTEzN2VjNjMzNTliZjExY2EyYzQyYzMyMjNiNWIzYTlhODEwMzEyMzk4MzQxODkzIiwidGFnIjoiIn0%3D"
  };

  List? resolutions;

  String session='';

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

  void updateTime(String episode,Duration time,Duration total){
    var box = Hive.box('playtime');
    box.put(episode, {"duration":time.inSeconds,"total":total.inSeconds});
  }
  Future<Map> changeRes(String res, bool eng) async{
    var currentRes = resolutions
        ?.map(
          (element) {
            if (element['data-resolution'] == res &&
                (eng?element['data-audio'] == ("eng"):element['data-audio'] != ("eng"))) {
              return element;
            }
            if (resolutions!.indexOf(element) == resolutions!.length - 1) {
              return fallBackResHigh ? resolutions?.last : resolutions?.first;
            }
          },
        )
        .where((element) => element != null)
        .first;
    
    Uri uri = Uri.parse(currentRes?['data-src'] ?? '');
    http.Response r = await http.get(uri, headers: headers);
    BeautifulSoup soup = BeautifulSoup(r.body);
    var code = r.body.split("return p}")[2].split("</script>")[0];
    RegExp re = RegExp(r"'(.+)',(\d+),(\d+),'(\S+)'\.split\('\|'\)");
    var search = re.firstMatch(code);
    String vidUrl = m3u8Decoder(search?[1] ?? '', int.parse(search?[2] ?? ''),
        int.parse(search?[3] ?? ''), search?[4]!.split('|') ?? []);
    videoSession?[session][resolution] = vidUrl;
    data["curRes"] = currentRes?.text;
    data["videoUrl"] = vidUrl;
    return data;
  }

  Future getVideo(String sessio) async {
    session = sessio;
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
    Duration playTime = Duration(seconds: Hive.box('playtime').get(title,defaultValue: {"duration":null})['duration']??0);
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
            if (element['data-resolution'] ==
                    (resolution.replaceAll('p', '')) &&
                (element['data-audio'] != ("eng"))) {
              return element;
            }
            if (resolutions!.indexOf(element) == resolutions!.length - 1) {
              return fallBackResHigh ? (resolutions?.where((value)=>value['data-audio']!=("eng")).last) : resolutions?.where((value)=>value['data-audio']!=("eng")).first;
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
    String? next = videoSession?.keys.elementAtOrNull(
        (videoSession?.keys.toList().indexOf(session) ?? 0) + 1);
    String? previous = (videoSession?.keys.toList().indexOf(session) ?? 0) > 0
        ? videoSession?.keys.elementAtOrNull(
            (videoSession?.keys.toList().indexOf(session) ?? 0) - 1)
        : null;
    // print(videoSession?.keys.first);
    // print(videoSession?[session]);
    data = {
      'title': title,
      "res": resolutions?.map((value) => value.text).toList(),
      "curRes": currentRes?.text,
      "videoUrl": vidUrl,
      "prev": previous,
      "next": next,
      "playTime": playTime
    };
    return data;
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
}

void main() async {
  Hive.init("C:/Users/davem/Documents/Code/Flutter/anideeznutz");
  var bbox = await Hive.openBox("settings");
  print(bbox.get('resolution'));
  // var deez = VideoRepo();
  // deez.getVideo(
  //     "29e485ed-f18d-3507-0ffc-67d7fc571e5d/754e773354eb43b31aa7dadf8552e221a3f8a727c28fb0a7b87f647872990c10");
}
