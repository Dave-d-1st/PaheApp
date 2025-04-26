
import 'dart:convert';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
void main() async {
  var dio = Dio();
  Map<String, String> header = {
    "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0",
  };
  var r = await dio.head("https://saturn.cizgifilmlerizle.com/getvid/b70-65yK9DiCQ-yvPptRNLbRdxTOSLCx_m5gvF6h3ItGExmXEpJ-HcjgRueHf31HdTQ412Hfhl11qAkqXNvrZb27csOo3-RqJS-51fWpwt-tTJcXUbORToe_8Dxze1BDk245IT5y3NPgIpRDyofBZxLtWM3qa06JxkEi6gYyhIWxot66dxQgriKb8uiAIdhPri7TAssc3IrSymgXGsQUd3hQRdIVUresTILaV-7CVO--_IuaNahDgaj5HnjEOiIW/index.m3u8",);//options:Options(headers: header));
  print(r.statusCode);
  print(r.headers);
  print(r.realUri);
  print(r.isRedirect);
}
// void main() async {
//   Map<String, String> header = {
//     "Referer": "https://www.wcofun.org/",
//     // "User-Agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36 Edg/115.0.1901.203",
//   };
//   String ref = "https://ndisk.cizgifilmlerizle.com/getvid?evid=tIiKGQAMV9Ltl3kdZvVdYwg1WdpQym-xfC0NVuozb_mTswj_wcuQpaNkuPntbFzlbMjfdIdJYWOACrD4YEoPi7GyhejBhbUsnTsUsO1vUwcTRbigRCLWlVr5cbdB26QyFmH5UhRF__m4vd4lzyJJd-1Fbg5CaRFk0m2wYVIhiX7u0PQ46caHgPyMbHJKQk4YfHw89otmm2KCc_rxNpNAMzyrVyEGL_ZLyxZ3uGnk5uIiGUL8GbRnidxTUw-mwEXYxdIT9H9klEoNyLtQ_2iEXFK9E9X8PNXkmdiHw43KadpasmzYnI1t-1VAdBt7nmgSBR3r1WIitlUuUHt3_bw-rF_hCbBm_-shb5HyzdES7ZBYMNXiCSRm5wRtgXhV6HxRsc7e7JuUwWtX8trzErqZs41MN6_LcvFRbvF3IINBO3yTcBoDuSCnZZZ3BRbxPCjnz51ABE6O-6Mk3QchDSDaK1Ao_aeGOMtpiw9keydM1C4";
//   Uri uri = Uri.parse(
//       "https://www.wcofun.net/the-amazing-world-of-gumball-season-6-episode-42-the-inquisition");
//   var r = await http.get(uri);
//   var soup = BeautifulSoup(r.body);
//   Uri url =
//       Uri.parse(soup.find("iframe", attrs: {'rel': 'nofollow'})?['src'] ?? '');
//   r = await http.get(url, headers: header);
//   soup = BeautifulSoup(r.body);
//   RegExp pattern = RegExp(r'getJSON\(\"(.+)\"');
//   var group = pattern.firstMatch(soup.prettify())?.group(1);
//   String split=group?.split("v=").last.split("/").last??'';
//   Map<String,dynamic> payload = {
//             'v':split,
//             "embed": "neptun",
//             'fullhd':'1'
//         };
//   uri = Uri.parse("https://embed.watchanimesub.net$group");
//   print(uri);
//   //https://embed.watchanimesub.net/inc/embed/getvidlink.php?v=Cartoons/The.Amazing.World.of.Gumball.S06E44.The.Inquisition.1080p.AMZN.WEB-DL.DD%2B5.1.H.264-CtrlHD.mp4&embed=ndisk&hd=1
//   header["X-Requested-With"] = "XMLHttpRequest";
//   print(1);
//   header['Referer'] = url.toString();
//   // header["Cookie"]="cf_clearance=aISvSer3W5rpVHBl84eQ5yIJj.ZgdUlxth2oLqbvV4w-1744633957-1.2.1.1-YIhtP1yMlO.s.l3XrjkYSI0mAt5hcrYWOwobhk07kKXLDRkBio3vUSEM2W4sQqnMXH3TFbpt0c4WoOpYiCpEWNzbPPzsTa37z36Is.X27ctG_M6QLo8DyPYggD40ur79MwHfZxnMdilEGCgvN19PgneNoNbJrgYULStmAmpeOKhov.o7GQEMztIGXSSTmMwcL5yF_8b6tGhZ_EBkEzyumLRhs2hEpEJO8PRPOIblHdPSNKoM2hMUOuKwmv4whGFPQAhzmXemjNahjQZpqoI96mcEwHpCs.3lIxY0ROj6rFgMew7XrizAFsPw530ce_WDtiD0CejIpfbpgBGcx0TPwdGG7zorH3crg9p4M77676Q";
  
//   r = await http.get(uri, headers: header);
//   print(1);
//   Map jsoned = json.decode(r.body);
//   print(jsoned['hd']);
//   //tIiKGQAMV9Ltl3kdZvVdYwg1WdpQym-xfC0NVuozb_mTswj_wcuQpaNkuPntbFzlbMjfdIdJYWOACrD4YEoPi7GyhejBhbUsnTsUsO1vUwcTRbigRCLWlVr5cbdB26QyFmH5UhRF__m4vd4lzyJJd-1Fbg5CaRFk0m2wYVIhiX7u0PQ46caHgPyMbHJKQk4YfHw89otmm2KCc_rxNpNAMzyrVyEGL_ZLyxZ3uGnk5uIiGUL8GbRnidxTUw-mwEXYxdIT9H9klEoNyLtQ_2iEXDqB7i7R4oM0NMyfUgRef0QHC2G9WUL08MkaGeCHRlk2b2jBoATgamkPgBygSiHrWv_gCCruy4vdDUitH52HOUtCnUCwtxVcg-jXmCeMyplX4umaHtLZbnBHh6IP7XAqqxPtN_Ajq_zsJhh2b7XSBjiJaLlvAkRtGlRB8mFMWRYNsdnKfDSbandZkYCh9mFCZpa2Uqfo847XP6gt_Msf0qc
//   //tIiKGQAMV9Ltl3kdZvVdYwg1WdpQym-xfC0NVuozb_mTswj_wcuQpaNkuPntbFzlbMjfdIdJYWOACrD4YEoPi7GyhejBhbUsnTsUsO1vUwcTRbigRCLWlVr5cbdB26QyFmH5UhRF__m4vd4lzyJJd5CABfFdlp4gtGDaGNQCauzEYEzSkDeJiG0lKu8NRowBSTpS364ojhwlEFcugnUSgeXmnkX8hqhmNsEa4qhOVNs2oFLShjyciJ6sYQXiWK5Zk1YvyHrefnQZJACkw17AXSDRsKF-h3i6W8C9Cx-wtPHZv2iD9gxnXt8bQHkFkJ_tUL8XBLv4-V1KgeSrh6VWQA
//   // return;
//   String link = '';
  
//   if (jsoned['hd'] == "" && jsoned['fhd'] == "") {
//     link = "${jsoned['server']}/getvid?evid=${jsoned['enc']}";
//   } else {
//     link = "${jsoned['server']}/getvid?evid=${jsoned['enc']}";
//   }
//   print(link);
//   print(link==ref);
// }


//https://ndisk.cizgifilmlerizle.com/getvid?evid=tIiKGQAMV9Ltl3kdZvVdYwg1WdpQym-xfC0NVuozb_mTswj_wcuQpaNkuPntbFzlbMjfdIdJYWOACrD4YEoPi7GyhejBhbUsnTsUsO1vUwcTRbigRCLWlVr5cbdB26Qy9J9foapxtwraJZQ3Ad8HeOVz0v9TBn3I43eACYuuLpV_4Ks4MPLSCVVpwbF4lCP6ejPfPzGrNV3mJUWvgJL0IWXkiNaxLhE73t90KSc01m7DCri-rn1kP6hj6jggi1m5PCyjYv2OI0allOVO8JvBHahU2QJtxITCzIv436xIH1H3wxgYR2kKsqBCRJs4L7GbEJvQ_koOV5ZxmVL7fE5hAQ