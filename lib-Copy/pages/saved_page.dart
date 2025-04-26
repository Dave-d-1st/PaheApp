import 'dart:io';

import 'package:app/bloc/home/home_bloc.dart';
import 'package:app/models/home_item.dart';
import 'package:app/models/pahe.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SavedPage extends StatelessWidget {
  final HomeItem item;
  const SavedPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return Scaffold(
      appBar: AppBar(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Poster(item: item),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.summary['synopsis']),
                  SizedBox(height: 20,),
                  for(var n in item.summary['details'])Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(n),
              ),
              SizedBox(
              height: 20,
            ),Row(
              children: [
                for (var n in item.summary['genre'])
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
          ),
          SliverList.list(children: [for(Pahe item in item.episodes) 
          Column(
            children: [
              Divider(),
              ListTile(title: Text("Episode - ${item.episode}"),),
            ],
          )])
        ],
      ));
  }
}
// Test this link: https://vault-99.kwikie.ru/stream/99/01/a684ab6104ed84e198c66901e1803e761ff4ad5b109a61bbb1417867e814dd13/uwu.m3u8
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
            maxHeight: 700,
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
                height: item.height> 700 ? 700 : item.height,
              ),
        Column(
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
                BlocBuilder<HomeBloc,HomeState>(
                  builder:(context,homeState){
                    // print(homeState);
                    return IconButton(
                    onPressed: () {
                      bloc.add(SavedItem(item: item));
                    },
                    icon: Icon(homeState.homeInfos.containsKey(item.title)?Icons.favorite:Icons.favorite_outline),
                    color: Colors.blue,
                  );},
                )
              ],
            )
          ],
        ),
      ],
    );
  }
}
