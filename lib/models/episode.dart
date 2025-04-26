import 'dart:collection';
import 'dart:io';

import 'package:app/bloc/anime/anime_bloc.dart';
import 'package:app/bloc/download/download_bloc.dart';
import 'package:app/bloc/home/home_bloc.dart';
import 'package:app/bloc/pahe/pahe_bloc.dart';
import 'package:app/bloc/video/video_bloc.dart';
import 'package:app/models/download.dart';
import 'package:app/models/pahe.dart';
import 'package:app/pages/anime_page.dart';
import 'package:app/pages/video_page.dart';
import 'package:app/repository/pahe_repo.dart';
import 'package:app/repository/video_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Episode extends StatelessWidget {
  const Episode({super.key, required this.pahe, this.title});
  final Pahe pahe;
  final String? title;
  @override
  Widget build(BuildContext context) {
    var bloc = context.read<HomeBloc>();
    var episodeTitle =
        "${title ?? pahe.title} - ${(pahe.episode2 != null && pahe.episode2 != 0) ? '${pahe.episode}-${pahe.episode2}' : pahe.episode}";
    bloc.add(GetPlayTime(episode: episodeTitle));
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      List<int>? duration = state.playtime[episodeTitle];
      int? currentDuration = duration?.first;
      int? totalDuration = duration?[1];
      return Stack(
        alignment: Alignment.bottomRight,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
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
              child: Image.network(
                pahe.imageUrl,
                errorBuilder: (context, error, stackTrace) => Padding(
                  padding: const EdgeInsets.only(bottom:8.0),
                  child: Container(
                      color: Colors.grey,
                      width: double.infinity,
                      height: double.infinity,
                      child: Icon(Icons.broken_image)),
                ),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Title(pahe: pahe),
                pahe.completed
                    ? Icon(
                        Icons.check,
                        color: Colors.green,
                      )
                    : Text(
                        pahe.episode2 == 0
                            ? "${pahe.episode}"
                            : "${pahe.episode}-${pahe.episode2}",
                        style: TextStyle(shadows: [
                          Shadow(
                            blurRadius: 3.0,
                            color: Color.fromARGB(255, 0, 0, 0),
                          )
                        ], fontWeight: FontWeight.bold))
              ],
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            padding: EdgeInsets.only(top: 12),
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.loose,
              children: [
                CircularProgressIndicator(value: 0),
                DownloadButton(
                  pahe: pahe,
                  title: episodeTitle,
                )
              ],
            ),
          ),
          LinearProgressIndicator(
            value: (currentDuration ?? 0) / ((totalDuration ?? 1)<=0?1:(totalDuration ?? 1)),
            color: Colors.red,
            backgroundColor: Colors.transparent,
          )
        ],
      );
    });
  }
}

class DownloadButton extends StatelessWidget {
  const DownloadButton({super.key, required this.pahe, required this.title});
  final Pahe pahe;
  final String title;

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
        
        return (currentEpisode.contains("-")
            ? (int.tryParse(currentEpisode.split('-').first) ==
                int.tryParse(title.split(' - ').last.split("-").first))
            : (int.tryParse(currentEpisode) ==
                    int.tryParse(title.split(' - ').last.split("-").first))) &&
                (segments.elementAtOrNull(segments.length - 3) ==
                        title.split(' - ').first ||
                    segments.elementAtOrNull(segments.length - 3) ==
                        title.split(' - ').first
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
              icon: Icon(
                present.isEmpty ? Icons.download : Icons.check,
                color: present.isEmpty ? Colors.white : Colors.blue,
                shadows: present.isEmpty
                    ? null
                    : [Shadow(color: Colors.black, blurRadius: 30.0)],
              ))
        ],
      );
    });
  }
}

class Title extends StatefulWidget {
  const Title({
    super.key,
    required this.pahe,
  });

  final Pahe pahe;

  @override
  State<Title> createState() => _TitleState();
}

class _TitleState extends State<Title> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return widget.pahe.title.split(":").first.contains(RegExp(r'^\d{2}'))
        ? Text(
            widget.pahe.title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 3.0,
                    color: Color.fromARGB(255, 0, 0, 0),
                  )
                ],
                decoration: _isHovered
                    ? TextDecoration.underline
                    : TextDecoration.none),
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          )
        : TextButton(
            onPressed: () {
              var repo = context.read<PaheRepo>();
              var bboc = context.read<PaheBloc>();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MultiBlocProvider(providers: [
                  BlocProvider(
                    create: (context) => AnimeBloc(repo: repo),
                  ),
                  BlocProvider.value(value: bboc)
                ], child: AnimePage(pahe: widget.pahe)),
              ));
            },
            onHover: (value) {
              setState(() {
                _isHovered = value;
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              minimumSize: Size(0, 0),
              maximumSize: Size(200, 100),
              shape: BeveledRectangleBorder(),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              overlayColor: Colors.transparent,
            ),
            child: Text(
              widget.pahe.title,
              style: TextStyle(
                  shadows: [
                    Shadow(
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    )
                  ],
                  decoration: _isHovered
                      ? TextDecoration.underline
                      : TextDecoration.none),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          );
  }
}
