import 'package:app/bloc/wco/wco_bloc.dart';
import 'package:app/bloc/wcos/wcos_bloc.dart';
import 'package:app/pages/wcos_page.dart';
import 'package:app/repository/wco_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WcoPage extends StatefulWidget {
  const WcoPage({super.key});

  @override
  State<WcoPage> createState() => _WcoPageState();
}

class _WcoPageState extends State<WcoPage> {
  bool searching = false;
  bool loaded = false;
  final controller = TextEditingController();
  final FocusNode node = FocusNode();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
    node.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var bloc = context.read<WcoBloc>();
    if (!loaded) {
      bloc.add(StartWco());
    }
    return Scaffold(
        appBar: AppBar(
          title: searching
              ? Row(
                  children: [
                    Flexible(
                      child: TextField(
                        onEditingComplete: () {
                          bloc.add(GetSearch(controller.text));
                        },
                        focusNode: node,
                        decoration: InputDecoration(
                            hintText: "Search", border: InputBorder.none),
                        controller: controller,
                      ),
                    ),
                  ],
                )
              : Text("WcoFun"),
          backgroundColor: Colors.orange,
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    searching = true;
                  });
                  Future.delayed(Duration(milliseconds: 500)).then((value)=>node.requestFocus());
                },
                icon: Icon(Icons.search)),
          ],
        ),
        body: BlocBuilder<WcoBloc, WcoState>(builder: (context, state) {
          print(state.status);
          switch (state.status) {
            case WcoStatus.error:
              return Text("Error");
            case WcoStatus.searching:
              return Center(child: CircularProgressIndicator());
            case WcoStatus.done:
              loaded = true;
              return GridView.extent(
                maxCrossAxisExtent: 300,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.58,
                children: [
                  for (Map anime in state.animes)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            var repo = context.read<WcoRepo>();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BlocProvider(
                                        create: (context) => WcosBloc(repo),
                                        child: WcosPage(url: anime['url']))));
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  child: Image.network(
                                    anime["img"],
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              Text(
                                anime['title'],
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
          }
        }));
  }
}
