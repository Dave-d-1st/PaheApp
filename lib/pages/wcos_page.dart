import 'dart:collection';
import 'dart:io';

import 'package:app/bloc/download/download_bloc.dart';
import 'package:app/bloc/home/home_bloc.dart';
import 'package:app/bloc/video/video_bloc.dart';
import 'package:app/bloc/wco/wco_bloc.dart';
import 'package:app/bloc/wcos/wcos_bloc.dart';
import 'package:app/models/download.dart';
import 'package:app/models/wco_info.dart';
import 'package:app/pages/video_page.dart';
import 'package:app/repository/video_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class WcosPage extends StatelessWidget {
  const WcosPage({super.key,required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    context.read<WcosBloc>().add(GetAnimeInfo(url));
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<WcosBloc,WcosState>(builder: (context,state){
        switch(state.status){
          case WcoStatus.searching:
            return Center(child: CircularProgressIndicator());
          case WcoStatus.error:
            return Center(child: Text("Error"));
          case WcoStatus.done:
            return CustomScrollView(slivers: [
              SliverToBoxAdapter(
                child: Poster(state: state),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(state.synopsis),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(children: [
                    for(var genre in state.genres)
                    Row(
                      children: [
                        Text(genre),
                          SizedBox(width: 10,)
                      ],
                    )
                  ],),
                ),
              ),
              SliverList.list(children: [
                for(WcoInfo wco in state.episodes)
               EpisodeHome(wco: wco,title:state.title) 
              ])
            ],);
        }
      }),
    );
  }
}

class EpisodeHome extends StatelessWidget {
  const EpisodeHome(
      {super.key, required this.wco, required this.title});

  final WcoInfo wco;
  final String title;

  @override
  Widget build(BuildContext context) {
    var bloc = context.read<HomeBloc>();

    bloc.add(GetPlayTime(episode: wco.title.trim()));
    
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      List<int>? duration = state.playtime[wco.title.trim()];
      
      // print(duration);
      int currentDuration = duration?.first ?? 0;
      int totalDuration = duration?[1] ?? 1;
      return GestureDetector(
        onLongPress: (){
          print("Pressed Long");
        },
        child: Slidable(
          key: Key(wco.title),
          endActionPane:
              ActionPane(extentRatio: 0.1, motion: ScrollMotion(), children: [
            SlidableAction(
              onPressed: (context) {
                var downloadBloc = context.read<DownloadBloc>();
                downloadBloc.add(AddDownload(
                    wco.url, wco.title));
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
                    title: Text(wco.title.replaceAll(RegExp("$title:? ?"), '')),
                    onTap: () {
                      var repo = VideoRepo();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              settings: RouteSettings(arguments: wco.title),
                              builder: (context) => RepositoryProvider.value(
                                    value: repo,
                                    child: BlocProvider(
                                      create: (context) => VideoBloc(repo: repo),
                                      child: VideoPage(
                                        session:
                                            wco.url,
                                        title: wco.title,
                                      ),
                                    ),
                                  )));
                    },
                    trailing: DownloadButton(
                        wco: wco,
                        title:wco.title
                            ),
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
  final WcosState state;
  const Poster({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    // var bloc = context.read<HomeBloc>();
    double maxHeight = Platform.isAndroid ? 600 : 700;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Image.memory(state.image??Uint8List(0),errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey,
                      width: double.infinity,
                      height: double.infinity,
                      child: Icon(Icons.broken_image)),),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          width: MediaQuery.of(context).size.width,
          height: state.imageHeight > maxHeight ? maxHeight : state.imageHeight,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0,right: 8.0),
          child: Column(
            children: [
              Text(
                state.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 20),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // BlocBuilder<HomeBloc, HomeState>(
                  //   builder: (context, homeState) {
                  //     return IconButton(
                  //       onPressed: () {
                  //         bloc.add(AddHomeItem(state: state));
                  //       },
                  //       icon: Icon(homeState.homeInfos.values.where((value)=>value.title==state.title).isNotEmpty
                  //           ? Icons.favorite
                  //           : Icons.favorite_outline),
                  //       color: Colors.blue,
                  //     );
                  //   },
                  // )
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
      {super.key, required this.wco, required this.title});
  final WcoInfo wco;
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
                    wco.title, title));
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
