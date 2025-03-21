import 'dart:io';

import 'package:app/bloc/home/home_bloc.dart';
import 'package:app/models/home_item.dart';
import 'package:app/models/pahe.dart';
import 'package:app/repository/home_repo.dart';
import 'package:app/repository/pahe_repo.dart';
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:hive/hive.dart';
import 'package:app/repository/settings_repo.dart';
import 'package:app/bloc/settings/settings_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'package:app/pages/home_page.dart';
import 'package:app/pages/start_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  Hive.init("${(await getApplicationDocumentsDirectory()).path}/HomeLib");
  Hive.registerAdapter(HomeItemAdapter());
  Hive.registerAdapter(PaheAdapter());
  // print(await Directory("${(await getApplicationDocumentsDirectory()).path}/HomeLib").list().toList());
  await Hive.openBox("playtime");
  await Hive.openBox("offline");
  if (await Hive.boxExists("settings")) {
    await Hive.openBox("settings");
  } else {
    final box = await Hive.openBox("settings");
    box.put("theme", "dark");
    box.put('resolution', '720p');
    box.put("fallBackResHigh", true);
  }

  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => SettingsRepository(),
        ),
        RepositoryProvider(create: (context) => PaheRepo()),
        RepositoryProvider(create: (context) => HomeRepo())
      ],
      child: MultiBlocProvider(providers: [
        BlocProvider(
            create: (context) =>
                SettingsBloc(setrepo: context.read<SettingsRepository>())),
        BlocProvider(create: (context) => HomeBloc(repo: context.read<HomeRepo>())),
      ], child: const AniApp()),
    );
  }
}

class AniApp extends StatelessWidget {
  const AniApp({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = context.select((SettingsBloc bloc) => bloc.state.theme);
    String storagePath = context.read<SettingsBloc>().state.storagePath;
    var repo = context.read<HomeRepo>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: storagePath != '' ? HomePage() : StartPage(),
    );
  }
}
