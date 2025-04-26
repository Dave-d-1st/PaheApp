import 'package:app/bloc/home/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomObserver extends NavigatorObserver {
  final BuildContext context;
  CustomObserver(this.context);
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (route.settings.arguments != null||route.settings.name!="Popup") {
      context
          .read<HomeBloc>()
          .add(GetPlayTime(episode: route.settings.arguments.toString()));
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route.settings.arguments != null||route.settings.name=="Popup") {
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    }else{
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.didPush(route, previousRoute);
  }
}
