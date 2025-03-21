import 'dart:io';

import 'package:app/bloc/pahe/pahe_bloc.dart';
import 'package:app/bloc/video/video_bloc.dart';
import 'package:app/repository/video_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPage extends StatelessWidget {
  final String session;
  Duration currentDur = Duration.zero;
  VideoPage({super.key, required this.session});
  late final player = Player();
  late final controller = VideoController(player);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    VideoBloc bloc = context.read<VideoBloc>();
    PaheBloc bblo = context.read<PaheBloc>();
    bloc.add(StartVideo(session: session));
    return BlocBuilder<VideoBloc, AniVideoState>(builder: (context, state) {
      return Scaffold(
          appBar: state.status == PaheStatus.searching
              ? AppBar(
                  leading: IconButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        SystemChrome.setPreferredOrientations(
                            DeviceOrientation.values);
                        await player.dispose();
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
                  return Text("Error");
                case PaheStatus.done:
                  player.open(Media(state.videoUrl));
                  player.stream.bufferingPercentage.listen((value) {
                    if (player.state.position == Duration.zero &&
                        value == 100) {
                      if (state.title != '') {
                        player.seek(state.playTime ?? Duration.zero);
                        player.stream.position.listen((value) {
                          if ((value - currentDur).inMilliseconds > 1000 &&
                              value.compareTo(Duration.zero) >= 0) {
                            bblo.add(Update());
                            bloc.add(PlayTime(
                                episode: state.title,
                                playTime: value,
                                totalDur: player.state.duration));
                            currentDur = value;
                          }
                        });
                      }
                    }
                  });
                  if (Platform.isWindows) {
                    var materialDesktopVideoControlsThemeData =
                        getDesktopControls(context, state, bloc);
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
              Navigator.of(context).pop();
              try{
              await player.dispose();}
              catch(e){print(e);}
              SystemChrome.setPreferredOrientations(DeviceOrientation.values);
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
                    onTap: () {
                      RegExp regExp = RegExp(r'\d+');
                      Iterable<Match> matches = regExp.allMatches(res);
                      String result =
                          matches.map((match) => match.group(0)).join();
                      bloc.add(
                          ChangeRes(res: result, eng: res.endsWith("eng")));
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
          state.previous is String
              ? MaterialCustomButton(
                  onPressed: () async {
                    var repo = context.read<VideoRepo>();
                    var bloc = context.read<PaheBloc>();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RepositoryProvider.value(
                                  value: repo,
                                  child: MultiBlocProvider(
                                    providers: [
                                      BlocProvider(
                                        create: (context) =>
                                            VideoBloc(repo: repo),
                                      ),
                                      BlocProvider.value(value: bloc)
                                    ],
                                    child: VideoPage(
                                        session: state.previous ?? ''),
                                  ),
                                )));
                    await player.dispose();
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
          state.next is String
              ? MaterialCustomButton(
                  onPressed: () async {
                    var repo = context.read<VideoRepo>();
                    var bloc = context.read<PaheBloc>();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RepositoryProvider.value(
                                value: repo,
                                child: MultiBlocProvider(
                                  providers: [
                                    BlocProvider(
                                      create: (context) =>
                                          VideoBloc(repo: repo),
                                    ),
                                    BlocProvider.value(value: bloc)
                                  ],
                                  child: VideoPage(session: state.next ?? ''),
                                ))));
                    await player.dispose();
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
      BuildContext context, AniVideoState state, VideoBloc bloc) {
    return MaterialDesktopVideoControlsThemeData(topButtonBar: [
      MaterialCustomButton(
        onPressed: () async {
          Navigator.of(context).pop();
          await player.dispose();
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
                onTap: () {
                  RegExp regExp = RegExp(r'\d+');
                  Iterable<Match> matches = regExp.allMatches(res);
                  String result = matches.map((match) => match.group(0)).join();
                  bloc.add(ChangeRes(res: result, eng: res.endsWith("eng")));
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
      state.previous is String
          ? MaterialCustomButton(
              onPressed: () async {
                var repo = context.read<VideoRepo>();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RepositoryProvider.value(
                              value: repo,
                              child: BlocProvider(
                                create: (context) => VideoBloc(repo: repo),
                                child: VideoPage(session: state.previous ?? ''),
                              ),
                            )));
                await player.dispose();
              },
              icon: Icon(Icons.skip_previous),
            )
          : SizedBox(),
      MaterialPlayOrPauseButton(),
      state.next is String
          ? MaterialCustomButton(
              onPressed: () async {
                var repo = context.read<VideoRepo>();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RepositoryProvider.value(
                              value: repo,
                              child: BlocProvider(
                                create: (context) => VideoBloc(repo: repo),
                                child: VideoPage(session: state.next ?? ''),
                              ),
                            )));
                await player.dispose();
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
