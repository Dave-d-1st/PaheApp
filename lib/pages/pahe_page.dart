import 'package:app/bloc/pahe/pahe_bloc.dart';
import 'package:app/models/episode.dart';
import 'package:app/models/pahe.dart';
import 'package:app/models/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';

class PahePage extends StatefulWidget {
  PahePage({super.key});

  @override
  State<PahePage> createState() => _PahePageState();
}

class _PahePageState extends State<PahePage> {
  late PaheBloc bloc;
  final ScrollController controller = ScrollController();
  bool _snackBar = false;
  @override
  void initState() {
    bloc = context.read<PaheBloc>();
    controller.addListener(() {
      if (controller.offset >= (controller.position.maxScrollExtent * 3 / 4)) {
        bloc.add(StartPage());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bloc.add(StartPage());
    return BlocBuilder<PaheBloc, PaheState>(buildWhen: (previous, current) {
      return previous.episodeInfos != current.episodeInfos;
    }, builder: (context, state) {
      WidgetsBinding.instance.addPostFrameCallback((d) {
        if (state.status == PaheStatus.done) {
          if (controller.offset == controller.position.maxScrollExtent) {
            bloc.add(StartPage());
          }
        }
      });
      return Scaffold(
          appBar: AppBar(
            title: Image.asset("assets/images/animepahe_icon.png"),
            actions: [
              IconButton(
                  onPressed: () {
                    showSearch(
                        context: context, delegate: SearchDel(bloc: bloc));
                  },
                  icon: Icon(Icons.search))
            ],
          ),
          body: Builder(builder: (context) {
            switch (state.status) {
              case PaheStatus.searching:
                return Center(child: CircularProgressIndicator());
              case PaheStatus.done:
                double width = MediaQuery.of(context).size.width;
                List<Widget> deez = [];
                if (state.episodeInfos.whereType<Exception>().isNotEmpty) {
                  var first2 = state.episodeInfos.whereType<Exception>().first;
                  if (first2 is ClientException) {
                    if (!_snackBar) {
                      _snackBar = true;
                      WidgetsBinding.instance.addPostFrameCallback(
                        (timeStamp) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                                SnackBar(
                                  content: Text("No Internet"),
                                ),
                              )
                              .closed
                              .then((value) {
                            if (context.mounted) {
                              _snackBar = false;
                            }
                          });
                        },
                      );
                    }
                  } else {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (timeStamp) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                              SnackBar(content: Text("$first2")),
                            )
                            .closed
                            .then((value) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                          }
                        });
                      },
                    );
                  }
                }
                for (var pahe in state.episodeInfos) {
                  if (pahe is Pahe) {
                    deez.add(Episode(pahe: pahe,title: "${pahe.title} - ${(pahe.episode2 != null && pahe.episode2 != 0) ? '${pahe.episode}-${pahe.episode2}' : pahe.episode}",));
                  }
                }
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                  child: GridView.count(
                      controller: controller,
                      crossAxisCount: width >= 2000 ? 5 : width ~/ 350,
                      childAspectRatio: 1.7,
                      crossAxisSpacing: 10,
                      children: deez),
                );
              case PaheStatus.error:
                var error = state.episodeInfos.firstWhere(
                    (element) => element is Exception,
                    orElse: () => null);
                if (error is ClientException) {
                  return Center(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("No Internet"),
                      FilledButton(
                          onPressed: () {
                            bloc.add(StartPage());
                          },
                          child: Text("Refresh"))
                    ],
                  ));
                } else {
                  return Center(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("$error"),
                      FilledButton(onPressed: () {}, child: Text("Refresh"))
                    ],
                  ));
                }
            }
          }));
    });
  }
}
