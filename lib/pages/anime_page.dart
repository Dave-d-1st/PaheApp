

import 'dart:io';

import 'package:app/bloc/anime/anime_bloc.dart';
import 'package:app/bloc/home/home_bloc.dart';
import 'package:app/bloc/pahe/pahe_bloc.dart';
import 'package:app/models/episode.dart';
import 'package:app/models/pahe.dart';
import 'package:app/repository/pahe_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnimePage extends StatefulWidget {
  AnimePage({super.key, required this.pahe});
  final Pahe pahe;

  @override
  State<AnimePage> createState() => _AnimePageState();
}

class _AnimePageState extends State<AnimePage> {
  Map tabContents = {};
  int selectedTab = 0;

  void tabs(AnimeState state) {
    tabContents.clear();
    if (state.summary.isNotEmpty) {
      Map summary = state.summary;
      String synopsis = summary['synopsis'];
      List details = summary['details'];
      List genre = summary['genre'];
      tabContents[Text("Summary")] = SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(synopsis),
              SizedBox(
                height: 20,
              ),
              for (var n in details)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(n),
                ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  for (var n in genre)
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5.0, left: 5.0),
                        child: Text(n),
                      ),
                    )
                ],
              )
            ],
          ),
        ),
      );
    }
    if (state.relations.values.isNotEmpty) {
      List<Widget> lstChildren = [];
      for (var relationTitle in state.relations.entries) {
        lstChildren.add(ListTile(
          title: Text(
            relationTitle.key,
            style: TextStyle(fontSize: 20),
          ),
          tileColor: Colors.black,
        ));
        for (var relation in relationTitle.value) {
          Widget img =
              CircleAvatar(foregroundImage: NetworkImage(relation['img']),onForegroundImageError: (exception, stackTrace){},backgroundColor: Colors.grey,child: Icon(Icons.broken_image));
          Widget title = Text(
            relation['name'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
          Widget title2 = Text(
              "${relation['type']}-${relation['episodes'] != 0 ? relation['episodes'] : '?'} Episode${relation['episodes'] != 1 ? 's' : ''} (${relation['status']})");
          Widget title3 = Text("${relation['season']}",
              maxLines: 1, overflow: TextOverflow.ellipsis);
          lstChildren.add(ListTile(
              onTap: () {
                Map data = {
                  "anime_title": relation['name'],
                  "id": -1,
                  "episode": -1,
                  "snapshot": relation['img'],
                  'anime_session': relation['url'],
                  'session': ""
                };
                var repo = context.read<PaheRepo>();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => BlocProvider(
                          create: (context)=>AnimeBloc(repo: repo),
                          child: AnimePage(
                            pahe: Pahe(data: data),
                          ),
                        )));
              },
              leading: img,
              tileColor: Colors.black,
              title: title,
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title2, title3],
              )));
        }
      }
      tabContents[Text("Relations")] = SliverList.list(
        children: lstChildren,
      );
    }

    if (state.recommends.isNotEmpty) {
      List<Widget> gridChildren = [];
      for (var recommend in state.recommends) {
        Widget img =
            CircleAvatar(foregroundImage: NetworkImage(recommend['img']),onForegroundImageError: (exception, stackTrace){},backgroundColor: Colors.grey,child: Icon(Icons.broken_image));
        Widget title = Text(
          recommend['name'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
        Widget title2 = Text(
            "${recommend['type']}-${recommend['episodes'] != 0 ? recommend['episodes'] : '?'} Episode${recommend['episodes'] != 1 ? 's' : ''} (${recommend['status']})");
        Widget title3 = Text("${recommend['season']}",
            maxLines: 1, overflow: TextOverflow.ellipsis);
        gridChildren.add(ListTile(
            onTap: () {
              Map data = {
                "anime_title": recommend['name'],
                "id": -1,
                "episode": -1,
                "snapshot": recommend['img'],
                'anime_session': recommend['url'],
                'session': ""
              };
              var repo = context.read<PaheRepo>();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => BlocProvider(
                          create: (context)=>AnimeBloc(repo: repo),
                      child: AnimePage(
                        pahe: Pahe(data: data),
                      ))));
            },
            leading: img,
            tileColor: Colors.black,
            title: title,
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title2, title3],
            )));
      }
      tabContents[Text("Recommendations")] = SliverList.list(
        children: gridChildren,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AnimeBloc bloc = context.read<AnimeBloc>();

    if (tabContents.isEmpty) {
      bloc.add(StartAniPage(url: widget.pahe.animeSession));
    }
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(),
        body: BlocBuilder<AnimeBloc, AnimeState>(
          builder: (context, state) {
            switch (state.status) {
              case PaheStatus.searching:
                return Center(
                  child: CircularProgressIndicator(),
                );
              case PaheStatus.error:
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Error"),
                      FilledButton(onPressed: (){
                        bloc.add(StartAniPage(url: widget.pahe.animeSession));
                      }, child: Text("Refresh"))
                    ],
                  ),
                );
              case PaheStatus.done:
                tabs(state);
                return DefaultTabController(
                    length: tabContents.length,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Poster(state: state),
                        ),
                        SliverToBoxAdapter(
                            child: Material(
                          color: Colors.black,
                          child: TabBar(
                              onTap: (value) => {
                                    setState(() {
                                      selectedTab = value;
                                    })
                                  },
                              tabs: [
                                for (var n in tabContents.keys)
                                  Tab(
                                    child: n,
                                  ),
                              ]),
                        )),
                        selectedTab == 0
                            ? SliverToBoxAdapter(
                                child: tabContents.values.toList()[selectedTab],
                              )
                            : tabContents.values.toList()[selectedTab],
                        SliverGrid.count(
                          childAspectRatio: 1.7,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          crossAxisCount:
                              MediaQuery.of(context).size.width >= 2000
                                  ? 5
                                  : MediaQuery.of(context).size.width ~/ 350,
                          children: [
                            for (var data in state.episodes ?? [])
                              Episode(
                                pahe: data,
                                title: state.title,
                              )
                          ],
                        )
                      ],
                    ));
            }
          },
        ),
      ),
    );
  }
}

class Poster extends StatelessWidget {
  final AnimeState state;
  const Poster({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    var bloc = context.read<HomeBloc>();
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
            child: Image.memory(state.image,errorBuilder: (context, error, stackTrace) => Container(
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
          height: state.imgHeight > maxHeight ? maxHeight : state.imgHeight,
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
              Text(
                state.subtitle,
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
                          bloc.add(AddHomeItem(state: state));
                        },
                        icon: Icon(homeState.homeInfos.values.where((value)=>value.title==state.title).isNotEmpty
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
