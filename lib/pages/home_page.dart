import 'dart:io';

import 'package:app/bloc/home/home_bloc.dart';
import 'package:app/bloc/pahe/pahe_bloc.dart';
import 'package:app/models/home_item.dart';
import 'package:app/pages/saved_page.dart';
import 'package:app/repository/pahe_repo.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
// import 'package:app/bloc/settings/settings_bloc.dart';
import 'package:app/pages/pahe_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    var bloc = context.read<HomeBloc>();
    bloc.add(GetHomeItems());
    return Scaffold(
        appBar: AppBar(
          title: Text("Library"),
        ),
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: ExpandableFab(
            openButtonBuilder: RotateFloatingActionButtonBuilder(
              child: const Icon(Icons.add),
              fabSize: ExpandableFabSize.regular,
              shape: const CircleBorder(),
            ),
            closeButtonBuilder: DefaultFloatingActionButtonBuilder(
              child: const Icon(Icons.close),
              shape: const CircleBorder(),
            ),
            children: [
              FloatingActionButton(
                onPressed: () {
                  var pRepo = context.read<PaheRepo>();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BlocProvider(
                              create: (context) => PaheBloc(repo: pRepo),
                              child: PahePage())));
                },
                child: Image.asset('assets/images/pika_icon.png'),
              )
            ]),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return GridView.extent(
              maxCrossAxisExtent: 300,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.6,
              children: [
                for (MapEntry<String, HomeItem> homeItem
                    in state.homeInfos.entries)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SavedPage(item: homeItem.value)));
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              child:
                                  Image.file(File(homeItem.value.imagePath)),
                            ),
                            Text(
                              homeItem.value.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      ),
                    ),
                  )
              ],
            );
          },
        ));
  }
}
