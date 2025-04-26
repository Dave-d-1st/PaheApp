import 'package:app/bloc/anime/anime_bloc.dart';
import 'package:app/bloc/pahe/pahe_bloc.dart';
import 'package:app/models/pahe.dart';
import 'package:app/pages/anime_page.dart';
import 'package:app/repository/pahe_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class SearchDel extends SearchDelegate {
  final PaheBloc bloc;
  final List searchList = [];
  SearchDel({required this.bloc});
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          onPressed: () {
            buildResults(context);
          },
          icon: const Icon(Icons.search),
        ),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          searchList.clear();
          Navigator.of(context).pop();
        },
        icon: Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    bloc.add(GetSearch(searchTerm: query));
    return BlocBuilder<PaheBloc, PaheState>(
      bloc: bloc,
      builder: (context, state) {
        searchList.clear();
        if ((state.search ?? {}).isNotEmpty) {
          if((state.search ?? {}).containsKey("Load")){
            return ListView(
          children: [ Padding(
            padding: const EdgeInsets.all(3.0),
            child: Center(child: CircularProgressIndicator()),
          )]
        );
          }
          if((state.search ?? {}).containsKey("Error")){
            
            return ListView(
          children: [ Padding(
            padding: const EdgeInsets.all(3.0),
          child: Center(child: state.search?["Error"] is ClientException?Text("No Internet"):Text("${state.search?["Error"]}")),
          )]
        );
          }

          for (var data in state.search?['data']) {
            Widget img =
                CircleAvatar(foregroundImage: NetworkImage(data['poster']),onForegroundImageError: (exception, stackTrace){},backgroundColor: Colors.grey,child: Icon(Icons.broken_image));
            Widget title = Text(
              data['title'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
            Widget title2 = Text(
                "${data['type']}-${data['episodes'] != 0 ? data['episodes'] : '?'} Episode${data['episodes'] != 1 ? 's' : ''} (${data['status']})");
            Widget title3 = Text("${data['season']} ${data['year']}",
                maxLines: 1, overflow: TextOverflow.ellipsis);
            searchList.add(ListTile(
                leading: img,
                title: title,
                onTap: () {
                  var repo = context.read<PaheRepo>();
                  Map info = {
                    "anime_title": data['title'],
                    "id": data['id'],
                    "episode": -1,
                    "snapshot": data['poster'],
                    'anime_session': data['session'],
                    'session': ""
                  };
                  close(context, '');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider(
                                      create: (context) =>
                                          AnimeBloc(repo: repo),
                                    ),
                                    BlocProvider.value(value: bloc)
                                  ],
                                  child: AnimePage(
                                    pahe: Pahe(data: info),
                                  ))));
                },
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title2, title3],
                )));
          }
        }
        return ListView.builder(
            itemCount: searchList.length,
            itemBuilder: (context, index) {
              return searchList[index];
            });
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
return ListView.builder(
        itemCount: searchList.length,
        itemBuilder: (context, index) {
          return searchList[index];
        });
  }
}
