import 'dart:math';

import 'package:app/bloc/anime/anime_bloc.dart';
import 'package:app/bloc/home/home_bloc.dart';
import 'package:app/bloc/pahe/pahe_bloc.dart';
import 'package:app/bloc/video/video_bloc.dart';
import 'package:app/models/pahe.dart';
import 'package:app/pages/anime_page.dart';
import 'package:app/pages/video_page.dart';
import 'package:app/repository/home_repo.dart';
import 'package:app/repository/pahe_repo.dart';
import 'package:app/repository/video_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class Episode extends StatelessWidget {
  const Episode({super.key, required this.pahe, this.title});
  final Pahe pahe;
  final String? title;
  @override
  Widget build(BuildContext context) {
    Box box = context.select<PaheBloc, Box>(
      (value) => value.state.box,
    );

    return SizedBox(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                var repo = VideoRepo();
                var bboc = context.read<PaheBloc>();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RepositoryProvider.value(
                              value: repo,
                              child: MultiBlocProvider(
                                providers: [
                                  BlocProvider(
                                    create: (context) => VideoBloc(repo: repo),
                                  ),
                                  BlocProvider.value(
                                    value: bboc,
                                  ),
                                ],
                                child: VideoPage(
                                  session:
                                      "${pahe.animeSession}/${pahe.episodeSession}",
                                ),
                              ),
                            )));
              },
              child: Image.network(
                pahe.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Title(pahe: pahe),
                Text(pahe.episode2==0?"${pahe.episode}":"${pahe.episode}-${pahe.episode2}",
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
                IconButton(onPressed: () {}, icon: Icon(Icons.download))
              ],
            ),
          ),
          LinearProgressIndicator(
            value: (box.get("${title ?? pahe.title} - ${pahe.episode}",
                    defaultValue: {'duration': 0})['duration']) /
                (box.get("${title ?? pahe.title} - ${pahe.episode}",
                    defaultValue: {'total': 1})['total']),
            color: Colors.red,
            backgroundColor: Colors.transparent,
          )
        ],
      ),
    );
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
