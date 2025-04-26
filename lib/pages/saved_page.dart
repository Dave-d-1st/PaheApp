import 'dart:collection';
import 'dart:io';

import 'package:app/bloc/download/download_bloc.dart';
import 'package:app/bloc/home/home_bloc.dart';
import 'package:app/bloc/video/video_bloc.dart';
import 'package:app/models/download.dart';
import 'package:app/models/home_item.dart';
import 'package:app/models/pahe.dart';
import 'package:app/pages/video_page.dart';
import 'package:app/repository/video_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SavedPage extends StatelessWidget {
  final HomeItem item;
  const SavedPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            var newItem = await context.read<HomeBloc>().refresh(Refresh(item));
            if (newItem != null && context.mounted) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SavedPage(item: newItem)));
            }
          },
          child: Scaffold(
              appBar: AppBar(
                actions: [
                  PopupMenuButton(
                      onSelected: (value) {
                        var bloc = context.read<DownloadBloc>();
                        List downloaded =
                            List.from(bloc.state.currentDownloads).map((value) {
                          List segments = Platform.isWindows
                              ? value.uri.pathSegments
                              : Uri.parse(value.uri)
                                  .pathSegments
                                  .last
                                  .split("/");
                          String episodeAmount =
                              segments.elementAt(segments.length - 2);
                          return "${segments.elementAt(segments.length - 3)} - ${episodeAmount.contains('-') ? '${int.parse(episodeAmount.split("-").first)}-${int.parse(episodeAmount.split("-").last)}' : int.parse(episodeAmount)}";
                        }).toList();
                        Iterable downloading =
                            List<Download>.from(bloc.state.downloading)
                                .map((value) => value.title);
                        List notDownloaded =
                            List<Pahe>.from(item.episodes).where((value) {
                          String tit =
                              "${item.title} - ${(value.episode2 != null && value.episode2 != 0) ? '${value.episode}-${value.episode2}' : value.episode}";
                          return !(downloaded.contains(
                                  tit.replaceAll(RegExp(r'[^\w\s-]'), "")) ||
                              downloading.contains(tit));
                        }).toList();
                        if (value == 3) {
                          List downList = notDownloaded.sublist(
                              0,
                              3 <= notDownloaded.length
                                  ? 3
                                  : notDownloaded.length);
                          for (Pahe pahe in downList) {
                            String tit =
                                "${item.title} - ${(pahe.episode2 != null && pahe.episode2 != 0) ? '${pahe.episode}-${pahe.episode2}' : pahe.episode}";
                            bloc.add(AddDownload(
                                "${pahe.animeSession}/${pahe.episodeSession}",
                                tit));
                          }
                        }
                        if (value == 5) {
                          List downList = notDownloaded.sublist(
                              0,
                              5 <= notDownloaded.length
                                  ? 5
                                  : notDownloaded.length);
                          for (Pahe pahe in downList) {
                            String tit =
                                "${item.title} - ${(pahe.episode2 != null && pahe.episode2 != 0) ? '${pahe.episode}-${pahe.episode2}' : pahe.episode}";
                            bloc.add(AddDownload(
                                "${pahe.animeSession}/${pahe.episodeSession}",
                                tit));
                          }
                        }
                        if (value == 10) {
                          List downList = notDownloaded.sublist(
                              0,
                              10 <= notDownloaded.length
                                  ? 10
                                  : notDownloaded.length);
                          for (Pahe pahe in downList) {
                            String tit =
                                "${item.title} - ${(pahe.episode2 != null && pahe.episode2 != 0) ? '${pahe.episode}-${pahe.episode2}' : pahe.episode}";
                            bloc.add(AddDownload(
                                "${pahe.animeSession}/${pahe.episodeSession}",
                                tit));
                          }
                        }
                        if (value is String) {
                          for (Pahe pahe in notDownloaded) {
                            String tit =
                                "${item.title} - ${(pahe.episode2 != null && pahe.episode2 != 0) ? '${pahe.episode}-${pahe.episode2}' : pahe.episode}";
                            bloc.add(AddDownload(
                                "${pahe.animeSession}/${pahe.episodeSession}",
                                tit));
                          }
                        }
                      },
                      itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 3,
                              child: Text("Next 3 Episodes"),
                            ),
                            PopupMenuItem(
                              value: 5,
                              child: Text("Next 5 Episodes"),
                            ),
                            PopupMenuItem(
                              value: 10,
                              child: Text("Next 10 Episodes"),
                            ),
                            PopupMenuItem(
                              value: "Unwatched",
                              child: Text("Unwatched"),
                            ),
                          ],
                      icon: Icon(Icons.download_outlined))
                ],
              ),
              body: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Poster(item: item),
                  ),
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.summary['synopsis'] ?? ""),
                            SizedBox(
                              height: 20,
                            ),
                            for (var n in item.summary['details'] ?? [])
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: Text(n),
                              ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                for (var n in item.summary['genre'] ?? [])
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 5.0, left: 5.0),
                                      child: Text(n),
                                    ),
                                  )
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverList.list(children: [
                    for (Pahe pahe in item.episodes)
                      EpisodeHome(
                        pahe: pahe,
                        title: item.title,
                        subtitle: item.subtitle,
                      )
                  ])
                ],
              )),
        ));
  }
}

class EpisodeHome extends StatelessWidget {
  const EpisodeHome(
      {super.key, required this.pahe, required this.title, this.subtitle});

  final Pahe pahe;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    var bloc = context.read<HomeBloc>();

    var episodeTitle =
        "$title - ${(pahe.episode2 != null && pahe.episode2 != 0) ? '${pahe.episode}-${pahe.episode2}' : pahe.episode}";
    bloc.add(GetPlayTime(episode: episodeTitle));
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      List<int>? duration = state.playtime[episodeTitle];
      int currentDuration = duration?.first ?? 0;
      int totalDuration = duration?[1] ?? 1;
      return GestureDetector(
        onLongPress: (){
          print("Pressed Long");
        },
        child: Slidable(
          key: Key(episodeTitle),
          endActionPane:
              ActionPane(extentRatio: 0.1, motion: ScrollMotion(), children: [
            SlidableAction(
              onPressed: (context) {
                var downloadBloc = context.read<DownloadBloc>();
                String tit =
                    "$title - ${(pahe.episode2 != null && pahe.episode2 != 0) ? '${pahe.episode}-${pahe.episode2}' : pahe.episode}";
                downloadBloc.add(AddDownload(
                    "${pahe.animeSession}/${pahe.episodeSession}", tit));
              },
              icon: Icons.download,
            )
          ]),
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Colors.blue,
              Colors.black
            ], stops: [
              currentDuration / totalDuration,
              currentDuration / totalDuration
            ])),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Divider(
                    height: 0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    title: Text(
                        "Episode - ${(pahe.episode2 != null && pahe.episode2 != 0) ? '${pahe.episode}-${pahe.episode2}' : pahe.episode}"),
                    onTap: () {
                      var repo = VideoRepo();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              settings: RouteSettings(arguments: episodeTitle),
                              builder: (context) => RepositoryProvider.value(
                                    value: repo,
                                    child: BlocProvider(
                                      create: (context) => VideoBloc(repo: repo),
                                      child: VideoPage(
                                        session:
                                            "${pahe.animeSession}/${pahe.episodeSession}",
                                        title: episodeTitle,
                                      ),
                                    ),
                                  )));
                    },
                    trailing: DownloadButton(
                        pahe: pahe,
                        subtitle: subtitle,
                        title:
                            "$title - ${(pahe.episode2 != null && pahe.episode2 != 0) ? '${pahe.episode}-${pahe.episode2}' : pahe.episode}"),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class Poster extends StatelessWidget {
  final HomeItem item;
  const Poster({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    var bloc = context.read<HomeBloc>();
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 600,
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Image.file(File(item.imagePath)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          width: MediaQuery.of(context).size.width,
          height: item.height > 600 ? 600 : item.height,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 20),
              ),
              Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 20.0, color: Colors.grey),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, homeState) {
                      return IconButton(
                        onPressed: () {
                          bloc.add(SavedItem(item: item));
                        },
                        icon: Icon(homeState.homeInfos.containsKey(item.homeId)
                            ? Icons.favorite
                            : Icons.favorite_outline),
                        color: Colors.blue,
                      );
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}

class DownloadButton extends StatelessWidget {
  const DownloadButton(
      {super.key, required this.pahe, required this.title, this.subtitle});
  final Pahe pahe;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    var bic = context.read<DownloadBloc>();
    return BlocBuilder<DownloadBloc, DownloadState>(
        buildWhen: (previous, current) {
      return Queue.from(current.downloading)
          .map((value) => value.title)
          .contains(title);
    }, builder: (context, state) {
      Download? download = Queue.from(state.downloading).firstWhere(
        (value) => value.title == title,
        orElse: () => null,
      );

      var present = state.currentDownloads.where((value) {
        List segments = Platform.isWindows
            ? value.uri.pathSegments
            : Uri.parse(value.uri).pathSegments.last.split("/");
        String currentEpisode = segments.elementAtOrNull(segments.length - 2);
        if (title.endsWith("1-5") && currentEpisode == '1-5') {}
        return (currentEpisode.contains("-")
                ? (int.tryParse(currentEpisode.split('-').first) ==
                    int.tryParse(title.split(' - ').last.split("-").first))
                : (int.tryParse(currentEpisode) ==
                    int.tryParse(title.split(' - ').last.split("-").first))) &&
            (segments.elementAtOrNull(segments.length - 3) ==
                    title.split(' - ').first ||
                segments.elementAtOrNull(segments.length - 3) ==
                    title
                        .split(' - ')
                        .first
                        .replaceAll(RegExp(r'[^\w\s-]'), ""));
      });
      return Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: present.isNotEmpty
                ? 0
                : download?.status == DownloadStatus.error
                    ? 1
                    : download?.status == DownloadStatus.enqueued
                        ? null
                        : download?.progress ?? 0,
            color: download?.status == DownloadStatus.error ? Colors.red : null,
          ),
          IconButton(
              onPressed: () {
                bic.add(AddDownload(
                    "${pahe.animeSession}/${pahe.episodeSession}", title));
              },
              icon: Container(
                decoration: present.isNotEmpty
                    ? BoxDecoration(
                        color: Color.fromARGB(199, 191, 223, 252),
                        shape: BoxShape.circle,
                      )
                    : null,
                child: Icon(
                  present.isEmpty ? Icons.download : Icons.check,
                  color: present.isEmpty ? Colors.white : Colors.black,
                ),
              ))
        ],
      );
    });
  }
}
