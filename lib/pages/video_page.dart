import 'dart:io';

import 'package:app/bloc/pahe/pahe_bloc.dart';
import 'package:app/bloc/video/video_bloc.dart';
import 'package:app/models/realtive_vid.dart';
import 'package:app/repository/video_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPage extends StatefulWidget {
  final String session;
  final String? title;

  VideoPage({super.key, required this.session, this.title});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  Duration currentDur = Duration.zero;

  late VideoBloc bloc;
  late final player = Player();

  late final controller = VideoController(player);
  @override
  void initState() {
    bloc = context.read<VideoBloc>();
    super.initState();
  }

  @override
  void dispose()async {
    bloc.add(Done());
    super.dispose();
    await player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bloc = context.read<VideoBloc>();
    if (!bloc.isClosed) {
      bloc.add(StartVideo(
        session: widget.session,
        title: widget.title,
      ));
    }
    return BlocBuilder<VideoBloc, AniVideoState>(builder: (context, state) {
      print(state.status);
      return Scaffold(
          appBar: state.status == PaheStatus.searching ||
                  state.status == PaheStatus.error
              ? AppBar(
                  leading: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.arrow_back)),
                )
              : null,
          body: Builder(
            builder: (context) {
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
                      Text(state.error is ClientException
                          ? "No Internet"
                          : "${state.error}"),
                      FilledButton(
                          onPressed: () => bloc.add(StartVideo(
                                session: widget.session,
                                title: widget.title,
                              )),
                          child: Text("Refresh"))
                    ],
                  ));
                case PaheStatus.done:
                  print(state.title);
                  player.open(Media(state.videoUrl,httpHeaders: {"user-agent": "Dart/3.7 (dart:io)"}));
                  player.stream.error.listen((event) {
                    print(event);
                  },);
                  player.stream.bufferingPercentage.listen((value) {
                    if (player.state.position == Duration.zero &&
                        value == 100) {
                      if (state.title != '') {
                        player.seek(state.playTime ?? Duration.zero);
                        player.stream.position.listen((value) {
                          if ((value - currentDur).abs() >
                                  Duration(seconds: 1) &&
                              value.compareTo(Duration.zero) >= 0) {
                            if (!bloc.isClosed) {
                              bloc.add(PlayTime(
                                  episode: state.title.trim(),
                                  playTime: value,
                                  totalDur: player.state.duration));
                            }
                            currentDur = value;
                          }
                        });
                      }
                    }
                  });
                  if (Platform.isWindows) {
                    var materialDesktopVideoControlsThemeData =
                        getDesktopControls(context, bloc);
                    return MaterialDesktopVideoControlsTheme(
                      normal: materialDesktopVideoControlsThemeData,
                      fullscreen: materialDesktopVideoControlsThemeData,
                      child: Video(
                        controller: controller,
                      ),
                    );
                  } else {
                    var materialVideoControlsThemeData =
                        getAndroidControls(context, state, bloc);
                    return MaterialVideoControlsTheme(
                      normal: materialVideoControlsThemeData,
                      fullscreen: materialVideoControlsThemeData,
                      child: Video(
                        controller: controller,
                      ),
                    );
                  }
              }
            },
          ));
    });
  }

  MaterialVideoControlsThemeData getAndroidControls(
      BuildContext context, AniVideoState state, VideoBloc bloc) {
    return MaterialVideoControlsThemeData(
        seekGesture: true,
        seekOnDoubleTap: true,
        volumeGesture: true,
        brightnessGesture: true,
        seekBarAlignment: Alignment.topCenter,
        seekBarContainerHeight: 50,
        bottomButtonBar: [
          MaterialPositionIndicator()
        ],
        topButtonBar: [
          MaterialCustomButton(
            onPressed: () async {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            icon: Icon(Icons.arrow_back),
          ),
          Spacer(),
          Expanded(
            flex: 5,
            child: Center(
              child: Text(
                state.title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
          Spacer(),
          PopupMenuButton(
            routeSettings: RouteSettings(name: "Popup"),
            itemBuilder: (context) {
              return [
                for (String res in state.resolutions)
                  PopupMenuItem(
                    onTap: () {
                      bloc.add(
                          ChangeRes(res: res, eng: res.endsWith("eng")));
                    },
                    child: Text(
                      res,
                      style: TextStyle(
                          color: res == state.currentResolution
                              ? Colors.blue
                              : null),
                    ),
                  )
              ];
            },
          )
        ],
        primaryButtonBar: [
          Spacer(),
          state.previous is RealtiveVid
              ? MaterialCustomButton(
                  onPressed: () async {
                    var repo = context.read<VideoRepo>();

                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            settings: RouteSettings(arguments: state.title),
                            builder: (context) => RepositoryProvider.value(
                                  value: repo,
                                  child: BlocProvider(
                                    create: (context) => VideoBloc(repo: repo),
                                    child: VideoPage(
                                      session: state.previous?.session ?? '',
                                      title: state.previous?.title,
                                    ),
                                  ),
                                )));
                  },
                  icon: Icon(
                    Icons.skip_previous,
                    size: 48,
                  ),
                )
              : SizedBox(),
          Spacer(),
          MaterialPlayOrPauseButton(
            iconSize: 48,
          ),
          Spacer(),
          state.next is RealtiveVid
              ? MaterialCustomButton(
                  onPressed: () async {
                    var repo = context.read<VideoRepo>();

                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            settings: RouteSettings(arguments: state.title),
                            builder: (context) => RepositoryProvider.value(
                                  value: repo,
                                  child: BlocProvider(
                                    create: (context) => VideoBloc(repo: repo),
                                    child: VideoPage(
                                      session: state.next?.session ?? '',
                                      title: state.next?.title,
                                    ),
                                  ),
                                )));
                  },
                  icon: Icon(
                    Icons.skip_next,
                    size: 48,
                  ),
                )
              : SizedBox(
                  width: 48,
                ),
          Spacer()
        ]);
  }

  MaterialDesktopVideoControlsThemeData getDesktopControls(
      BuildContext context, VideoBloc bloc) {
    AniVideoState state = bloc.state;
    return MaterialDesktopVideoControlsThemeData(topButtonBar: [
      MaterialCustomButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(Icons.arrow_back),
      ),
      Spacer(),
      Text(
        state.title,
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
      Spacer(),
      PopupMenuButton(
        itemBuilder: (context) {
          return [
            for (String res in state.resolutions)
              PopupMenuItem(
                value: res,
                onTap: () {

                  bloc.add(ChangeRes(
                    res: res,
                    eng: res.endsWith("eng"),
                  ));
                },
                child: Text(
                  res,
                  style: TextStyle(
                      color:
                          res == state.currentResolution ? Colors.blue : null),
                ),
              )
          ];
        },
      )
    ], bottomButtonBar: [
      state.previous is RealtiveVid
          ? MaterialCustomButton(
              onPressed: () async {
                var repo = context.read<VideoRepo>();

                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        settings: RouteSettings(arguments: state.title),
                        builder: (context) => RepositoryProvider.value(
                              value: repo,
                              child: BlocProvider(
                                create: (context) => VideoBloc(repo: repo),
                                child: VideoPage(
                                  session: state.previous?.session ?? '',
                                  title: state.previous?.title,
                                ),
                              ),
                            )));
              },
              icon: Icon(Icons.skip_previous),
            )
          : SizedBox(),
      MaterialPlayOrPauseButton(),
      state.next is RealtiveVid
          ? MaterialCustomButton(
              onPressed: () async {
                var repo = context.read<VideoRepo>();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        settings: RouteSettings(arguments: state.title),
                        builder: (context) => RepositoryProvider.value(
                              value: repo,
                              child: BlocProvider(
                                create: (context) => VideoBloc(repo: repo),
                                child: VideoPage(
                                  session: state.next?.session ?? '',
                                  title: state.next?.title,
                                ),
                              ),
                            )));
              },
              icon: Icon(Icons.skip_next),
            )
          : SizedBox(),
      MaterialDesktopVolumeButton(),
      MaterialDesktopPositionIndicator(),
      Spacer(),
      MaterialDesktopFullscreenButton()
    ]);
  }
}
