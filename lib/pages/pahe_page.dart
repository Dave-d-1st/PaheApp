import 'package:app/bloc/pahe/pahe_bloc.dart';
import 'package:app/models/episode.dart';
import 'package:app/models/pahe.dart';
import 'package:app/models/search_bar.dart';
import 'package:app/repository/pahe_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '';

class PahePage extends StatelessWidget {
  ScrollController controller;
  bool controllerListening = false;
  PahePage({super.key}) : controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    PaheBloc bloc = context.read<PaheBloc>();
    bloc.add(StartPage());
    if (!controllerListening) {
      controller.addListener(() {
        if (controller.offset >=
            (controller.position.maxScrollExtent * 3 / 4)) {
              print("Ran");
          bloc.add(StartPage());
          controllerListening = true;
        }
      });
    }
    print(controller);
    return BlocBuilder<PaheBloc, PaheState>(builder: (context, state) {
      WidgetsBinding.instance.addPostFrameCallback((d){
        if(state.status==PaheStatus.done){
          if(controller.offset==controller.position.maxScrollExtent){
            bloc.add(StartPage());
          }
      }});
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
            print(state.status);
            switch (state.status) {
              case PaheStatus.searching:
                return Center(child: CircularProgressIndicator());
              case PaheStatus.done:
                double width = MediaQuery.of(context).size.width;
                List<Widget> deez = [];
                for (var episode in state.episodeInfos) {
                  if (episode is Pahe) {
                    deez.add(Episode(pahe: episode));
                  }
                }
                return GridView.count(
                    controller: controller,
                    crossAxisCount: width >= 2000 ? 5 : width ~/ 350,
                    childAspectRatio: 1.7,
                    crossAxisSpacing: 10,
                    children: deez);
              case PaheStatus.error:
                if (state.episodeInfos.isEmpty) {
                  return Text("error");
                } else {
                  return Text("There were values but error");
                }
            }
          }));
    });
  }
}
