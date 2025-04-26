import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'dart:math';
class Downloader {
  List li = [
    "",
    "split",
    "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+/",
    "slice",
    "indexOf",
    "",
    "",
    ".",
    "pow",
    "reduce",
    "reverse",
    "0"
  ];
  String deez([a, b, c]) {
    List<String> d = li[2].split('');
    var f = d.sublist(0, c);

    dynamic g = a.toString().split('').reversed;

    int sumer = 0;
    int nutz(bc, cd) {
      bc += cd * pow(b, sumer);
      sumer++;
      return bc;
    }

    g = g.fold(0, (value, element) => nutz(value, int.parse(element)));
    String h = '';
    while (g > 0) {
      h = f[(g % c).toInt()] + h;
      g = (g - (g % c)) / c;
    }

    return h != "" ? h : li[11];
  }

  String tokenExtractor(ab, bc, c, int de, ef, fg) {
    String ir = '';
    int mi = ab.length;
    int x = 0;
    while (x < mi) {
      String s = '';
      while (ab[x] != c[ef]) {
        s += ab[x];
        x++;
      }
      int im = c.length;
      for (int y = 0; y < im; y++) {
        RegExp pattern = RegExp('${c[y]}');
        s = s.replaceAll(pattern, y.toString());
      }
      ir += String.fromCharCode(int.parse(deez(s, ef, 10)) - de);
      x++;
    }
    return ir;
  }

  String setToken(String input) {
    String? data = RegExp(r'[\S]+\",[\d]+,\"[\S]+\",[\d]+,[\d]+,[\d]+')
        .firstMatch(input)?[0];
    List parameters = data!.split(',');
    var para1 = parameters[0].replaceAll("\"", '').split('))}(')[1];
    int para2 = int.parse(parameters[1]);
    String para3 = parameters[2].replaceAll("\"", '');
    int para4 = int.parse(parameters[3]);
    int para5 = int.parse(parameters[4]);
    int para6 = int.parse(parameters[5]);
    dynamic pageData = tokenExtractor(para1, para2, para3, para4, para5, para6);
    pageData = BeautifulSoup(pageData);
    Bs4Element inputField = pageData.find("input", attrs: {"name": "_token"});
    return inputField['value'] ?? "";
  }

  Future<String> getDownloadLink(session) async {
    final box = Hive.box("settings");
    final String resolution = box.get("resolution",defaultValue: '');
    final bool fallBackHigh = box.get("fallBackResHigh",defaultValue: false);
    dynamic url =
        "https://animepahe.ru/play/$session";
    url = Uri.parse(url);
    Map<String, String>? headers = {
      "Cookie":
          "__ddgid_=sE1YjW2vvFeZ9eMN; __ddgmark_=lxBaq42Dv71DNn34; __ddg2_=u2F6XKyQ9gVjlihp; __ddg1_=qbup7B4r1G6i5TWkt7RT;SERVERID=janna;XSRF-TOKEN=eyJpdiI6IjMwejVVQWpqYzBCZ0Z1YmhsZnZXM3c9PSIsInZhbHVlIjoiQ25Mdno0cUJyUTc0cU1rUW1NWVB0RXo5R1BkZFhBM1hRd1VObmYxSTRKTUNKZTZHdmF3VWdJbyswcWZMdmM1SUtONmlDc293VGRvbER4MFd3eDNGVEZpZC92L05QNVpjSmxGTEhzMlA3UGh0Wk5wSXVqK01KRXZCc2lWRkVZQXIiLCJtYWMiOiJlZjQxZjJlNzFkNWFlOTc2YjgwOTY5OTQyY2VhMDg2OTg3YTQyNDBjMTdlY2ZiMzllMjE0ZmE0YzI4ZTFiMzg1IiwidGFnIjoiIn0%3D; laravel_session=eyJpdiI6Im5STkE5Q040dm1pVFFxQzdOR2d2RXc9PSIsInZhbHVlIjoiVTVaQmEvVEd0MVBBVVJ4bjMrVS94RXYzbTAwMnpFelhkVXYxTWFRSFJXSFVPZ2dzNkEyRXlXNW9neXdPeTlUQ0pISzZ2T0c0TUxiOVRnaW14N21OQTBkMW1JbWdEK0FvdFptTWxKQmcrc2pDbWRQMk9kbDkvMnZYSmVuVGhMQnciLCJtYWMiOiI5Yzc5ZmMzNjVlNDAzZDc4MTEzN2VjNjMzNTliZjExY2EyYzQyYzMyMjNiNWIzYTlhODEwMzEyMzk4MzQxODkzIiwidGFnIjoiIn0%3D"
    };
    var r = await http.get(url, headers: headers);
    BeautifulSoup soup = BeautifulSoup(r.body);
    Bs4Element? dropdown = soup.find('div', id: "pickDownload");
    var linksSoup = dropdown!.findAll('a');
    Bs4Element? linkSoup;
    for (var x in linksSoup) {
      if (x.text.contains(resolution) && !x.text.contains("eng")) {
        linkSoup = x;
      }
    }
    linkSoup ??= fallBackHigh?linksSoup.last:linksSoup.first;
    String link = linkSoup['href']??'';
    Map<String, String> headersp = {
      "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36 Edg/115.0.1901.203"
    };
    r = await http.get(Uri.parse(link), headers: headersp);
    soup = BeautifulSoup(r.body);
    url = soup.find("script");
    RegExp pattern = RegExp(r'https://kwik.(\w+)/f/(.+)"\).html');
    dynamic id = pattern.firstMatch(url.innerHtml);
    var sec = id?[1];
    id = id?[2];
    url = Uri.parse('https://kwik.$sec/f/$id');
    r = await http.get(url, headers: headersp);
    String token = setToken(r.body);
    Map<String, String> head = {
      "origin": "https://kwik.$sec",
      "referer": url.toString(),
      "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36 Edg/115.0.1901.203",
      "cookie": r.headers['set-cookie'] ?? ''
    };
    Map<String, String> payload = {"_token": token};
    url = Uri.parse('https://kwik.$sec/d/$id');
    r = await http.post(url, headers: head, body: payload);
    return r.headers['location'] ?? '';
  }
}

