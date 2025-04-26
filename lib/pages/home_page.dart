import 'dart:io';

import 'package:app/bloc/home/home_bloc.dart';
import 'package:app/bloc/pahe/pahe_bloc.dart';
import 'package:app/bloc/wco/wco_bloc.dart';
import 'package:app/models/home_item.dart';
import 'package:app/pages/download_page.dart';
import 'package:app/pages/saved_page.dart';
import 'package:app/pages/settings_page.dart';
import 'package:app/pages/wco_page.dart';
import 'package:app/repository/pahe_repo.dart';
import 'package:app/repository/wco_repo.dart';
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:app/pages/pahe_page.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _key = GlobalKey<ExpandableFabState>();
  bool searching = false;
  final controller = TextEditingController();
  final FocusNode node = FocusNode();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    node.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {

  // }
  @override
  Widget build(BuildContext context) {
    // throw Error();
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: searching
                ? Row(
                    children: [
                      IconButton(
                          onPressed: () async {
                            controller.clear();
                            setState(() {
                              searching = false;
                            });
                            await Future.delayed(Duration(seconds: 1));
                            node.requestFocus();
                          },
                          icon: Icon(Icons.arrow_back)),
                      Flexible(
                        child: TextField(
                          focusNode: node,
                          decoration: InputDecoration(
                              hintText: "Search", border: InputBorder.none),
                          controller: controller,
                        ),
                      )
                    ],
                  )
                : Text("Library"),
            actions: [
              
              IconButton(
                  onPressed: () {
                    setState(() {
                      searching = true;
                    });
                  },
                  icon: Icon(Icons.search)),
              IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => DownloadPage()));
                },
                icon: Icon(Icons.download),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsPage()));
                  },
                  icon: Icon(Icons.settings))
            ],
          ),
          floatingActionButtonLocation: ExpandableFab.location,
          floatingActionButton: ExpandableFab(
              key: _key,
              overlayStyle: ExpandableFabOverlayStyle(
                  color: Colors.black.withAlpha(200), blur: 5),
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
                  heroTag: null,
                  backgroundColor: Colors.amber,
                  onPressed: () {
                    final state = _key.currentState;
                    if (state != null) {
                      state.toggle();
                    }
                    var wRepo = context.read<WcoRepo>();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BlocProvider(
                                create: (context) => WcoBloc(wRepo),
                                child: WcoPage())));
                  },
                  child: Image.asset(
                    'assets/images/WcoFuun.ico',
                    scale: 1.5,
                  ),
                ),
                FloatingActionButton(
                  heroTag: null,
                  onPressed: () {
                    final state = _key.currentState;
                    if (state != null) {
                      state.toggle();
                    }
                    var pRepo = context.read<PaheRepo>();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BlocProvider(
                                create: (context) => PaheBloc(repo: pRepo),
                                child: PahePage())));
                  },
                  child: Image.asset('assets/images/pika_icon.png'),
                ),
              ]),
          body: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              var entries2 = state.homeInfos.values.where((value) => controller
                  .text
                  .split(" ")
                  .where((e) => e != '')
                  .every((val) =>
                      value.title.toLowerCase().contains(val.toLowerCase())));
              return GridView.extent(
                maxCrossAxisExtent: 300,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.58,
                children: [
                  for (HomeItem homeItem in entries2.toList().reversed)
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
                                        SavedPage(item: homeItem)));
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  child: Image.file(
                                    File(homeItem.imagePath),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              Text(
                                homeItem.title,
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
          )),
    );
  }
}
