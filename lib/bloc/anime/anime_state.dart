part of 'anime_bloc.dart';
class AnimeState {
  final PaheStatus status;
  final String image;
  final String title;
  final String subtitle;
  final Map summary;
  final List recommends;
  final PaheRepo repo;
  final Map relations;
  final List? episodes;
  final int? id;
  final String? session;
  final BeautifulSoup soup;
  static final RegExp comp = RegExp(r'(\d+|\?) (Episodes|Episode) \((.+)\)');

  AnimeState({required this.repo, this.status = PaheStatus.searching,this.episodes,this.id,this.session}):
    soup = repo.soup,
    image = repo.soup.find('div', class_: "anime-poster")?.find('img')?['data-src']??'',
    title = repo.soup.find('div', class_: 'title-wrapper')?.h1?.find("span")?.text ??
              '',
    subtitle =
          repo.soup.find('div', class_: 'title-wrapper')?.h2?.text ?? '',
    summary = {
        "synopsis": repo.soup.find("div", class_: "anime-synopsis")?.text,
        "details": [
          for (var n in repo.soup
                  .find("div", class_: "col-sm-4 anime-info")
                  ?.findAll("p") ??
              [])
            n?.text
                ?.trim()
                .replaceAll("  ", "")
                .replaceAll('\n', '')
                .replaceAll(":", ": ")
                .replaceAll(":  ", ": ")
        ],
        "genre": [
          for (var n in repo.soup
                  .find("div", class_: "anime-genre font-weight-bold")
                  ?.findAll("li") ??
              [])
            n?.text?.trim()
        ],
      },
      relations = {
        for (var n in repo.soup
                .find("div", class_: "tab-content anime-relation")
                ?.children
                .where((x) => x.name == 'div')
                .toList() ??
            [])
          n.h4?.text: [
            for (var b in n
                .find("div", class_: 'row')
                .children
                .where((x) => x.name == "div")
                .toList())
              {
                "url": b.find('h5')?.a?['href']?.split("/").last,
                "img": b.find("img")?['data-src'],
                "name": b.find("h5")?.text,
                "type": b.find("strong")?.text,
                "episodes": comp.firstMatch(b.text)?[1],
                "status": comp.firstMatch(b.text)?[3],
                "season": b.findAll("a").last.text
              }
          ]
      },
      recommends = [
        for (var b in repo.soup
                .find("div", class_: "tab-content anime-recommendation row")
                ?.children
                .where((x) => x.name == "div")
                .toList()
                .sublist(1) ??
            [])
          {
            "url": b?.find('h5')?.a['href']?.split("/")?.last,
            "img": b?.find("img")?['data-src'],
            "name": b?.find("h5")?.text,
            "type": b?.find("strong")?.text,
            "episodes": comp.firstMatch(b?.text)?[1].toString() ?? '',
            "status": comp.firstMatch(b?.text)?[3].toString() ?? '',
            "season": b?.findAll("a")?.last?.text
          }
      ];

}