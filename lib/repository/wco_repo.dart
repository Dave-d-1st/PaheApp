import 'dart:typed_data';
import 'dart:ui';

import 'package:app/models/wco_info.dart';
import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';

class WcoRepo {
  final List animes = [];

  Future<void> startWco() async {
    animes.clear();
    var r = await http.get(Uri.parse("https://www.wcofun.net/"));
    var soup = BeautifulSoup(r.body);
    var releaseMain = soup.find("div", class_: "recent-release-main");
    // do{
    List? map = releaseMain
        ?.find('div', id: "sidebar_right")
        ?.findAll('li')
        .map((value) {
      return {
        "title": value.text.trim(),
        "img": "http:${value.find('div', class_: 'img')?.a?.img?['src']}",
        "url": value.find('div', class_: 'img')?.a?['href'],
      };
    }).toList();
    animes.addAll(map ?? []);
  }

  Future search(String searchTerm) async {
    var r = await http.post(Uri.parse("https://www.wcofun.net/search"),
        body: {'catara': searchTerm, "konuara": "series"});
    print(r.statusCode);
    var soup = BeautifulSoup(r.body);
    animes.clear();
    animes.addAll([
      for (Bs4Element n
          in soup.find('div', id: "sidebar_right2")?.findAll('li') ?? [])
        {"title": (n.img?['alt']), 'img': n.img?['src'], 'url': n.a?['href']}
    ]);
  }

  Future getAniInfo(String url) async {
    var r = await http.get(Uri.parse(url));
    var soup = BeautifulSoup(r.body);
    String title = soup.find("div", class_: "h1-tag")?.text ?? '';
    String synopsis = soup.find("div", id: "sidebar_cat")?.p?.text ?? '';
    List genres = [
      for (var n in soup.find("div", id: "sidebar_cat")?.findAll('a') ?? [])
        n.text
    ];
    List episodes = [
      for (Bs4Element n in soup
              .find("div", id: "sidebar_right3")
              ?.findAll('div', class_: "cat-eps") ??
          [])
        WcoInfo(n.a?['href'] ?? "", n.text.trim())
    ];
    String imgLink = soup.find("div", id: "sidebar_cat")?.img?['src'] ?? '';
    Uint8List image = (await http.get(Uri.parse("https:$imgLink")))
        .bodyBytes;
    final buffer = await ImmutableBuffer.fromUint8List(image);
    final descriptor = await ImageDescriptor.encoded(buffer);
    double imgHeight = descriptor.height.toDouble();
    descriptor.dispose();
    buffer.dispose();
    return {
      'title':title,
      'syn':synopsis,
      'genres':genres,
      'episodes':episodes,
      'image':image,
      'height':imgHeight
    };
  }
}

void main() {
  WcoRepo().search("gumball");
}
