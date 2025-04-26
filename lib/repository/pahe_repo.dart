import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart' as http;
import 'package:app/models/pahe.dart';

class PaheRepo {
  final List episodes = [];
  BeautifulSoup soup = BeautifulSoup('');
  Uint8List image = Uint8List(0);
  dynamic error;
  double imgHeight = 0;
  Map? search;
  Map<String, String> headers = {
    "Cookie":
        "__ddgid_=sE1YjW2vvFeZ9eMN; __ddgmark_=lxBaq42Dv71DNn34; __ddg2_=u2F6XKyQ9gVjlihp; __ddg1_=qbup7B4r1G6i5TWkt7RT;SERVERID=janna;XSRF-TOKEN=eyJpdiI6IjMwejVVQWpqYzBCZ0Z1YmhsZnZXM3c9PSIsInZhbHVlIjoiQ25Mdno0cUJyUTc0cU1rUW1NWVB0RXo5R1BkZFhBM1hRd1VObmYxSTRKTUNKZTZHdmF3VWdJbyswcWZMdmM1SUtONmlDc293VGRvbER4MFd3eDNGVEZpZC92L05QNVpjSmxGTEhzMlA3UGh0Wk5wSXVqK01KRXZCc2lWRkVZQXIiLCJtYWMiOiJlZjQxZjJlNzFkNWFlOTc2YjgwOTY5OTQyY2VhMDg2OTg3YTQyNDBjMTdlY2ZiMzllMjE0ZmE0YzI4ZTFiMzg1IiwidGFnIjoiIn0%3D; laravel_session=eyJpdiI6Im5STkE5Q040dm1pVFFxQzdOR2d2RXc9PSIsInZhbHVlIjoiVTVaQmEvVEd0MVBBVVJ4bjMrVS94RXYzbTAwMnpFelhkVXYxTWFRSFJXSFVPZ2dzNkEyRXlXNW9neXdPeTlUQ0pISzZ2T0c0TUxiOVRnaW14N21OQTBkMW1JbWdEK0FvdFptTWxKQmcrc2pDbWRQMk9kbDkvMnZYSmVuVGhMQnciLCJtYWMiOiI5Yzc5ZmMzNjVlNDAzZDc4MTEzN2VjNjMzNTliZjExY2EyYzQyYzMyMjNiNWIzYTlhODEwMzEyMzk4MzQxODkzIiwidGFnIjoiIn0%3D"
  };

  Future getSearch(String searchTerm)async{
    
    try {
  var url = Uri.parse("https://animepahe.ru/api?m=search&q=$searchTerm");
  http.Response r = await http.get(url,headers:headers);
  Map jsonResult = json.decode(r.body);
  search = jsonResult;
} on Exception catch (e) {
  search = {"Error":e};
}
  }
  void startSearch()async{
    search ={'Load':"Load"};
  }
  Future getContent(int pageNum) async {
    try {
      List nonError = episodes.whereType<Pahe>().toList();
      episodes.clear();
      episodes.addAll(nonError);
      Uri url = Uri.parse("https://animepahe.ru/api?m=airing&page=$pageNum");
      http.Response r = await http.get(url, headers: headers);
      List datas = json.decode(r.body)['data'];
      for (var data in datas) {
        var pahe = Pahe(data: data);
        episodes.add(pahe);
      }
      return episodes;
    } catch (e) {
      return episodes.add(e);
    }
  }

  Future getAnimeInfo(String aniUrl) async {
    try {
      error=null;
      Uri url = Uri.parse(aniUrl); 
      http.Response r = await http.get(url, headers: headers);
      soup = BeautifulSoup(r.body);
      image = (await http.get(Uri.parse(soup.find('div', class_: "anime-poster")?.find('img')?['data-src']??''))).bodyBytes;
      final buffer = await ImmutableBuffer.fromUint8List(image);
      final descriptor = await ImageDescriptor.encoded(buffer);
      imgHeight = descriptor.height.toDouble();
      descriptor.dispose();
      buffer.dispose();
    } catch (e) {
      error=e;
    }
  }

  Future getEpisodes(String url) async{
    try{
      Uri uri = Uri.parse(url);
      http.Response r = await http.get(uri,headers: headers);
      var response = jsonDecode(r.body);
      return response;
    } catch(e){
      return e;
    }
  }
  void clear() {
    episodes.clear();
  }
}
