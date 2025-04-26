import 'dart:io';

import 'package:app/bloc/download/download_bloc.dart';
import 'package:app/bloc/home/home_bloc.dart';
import 'package:app/models/custom_observer.dart';
import 'package:app/models/download.dart';
import 'package:app/models/home_item.dart';
import 'package:app/models/pahe.dart';
import 'package:app/repository/download_repo.dart';
import 'package:app/repository/home_repo.dart';
import 'package:app/repository/pahe_repo.dart';
import 'package:app/repository/wco_repo.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:hive/hive.dart';
import 'package:app/repository/settings_repo.dart';
import 'package:app/bloc/settings/settings_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'package:app/pages/home_page.dart';
import 'package:app/pages/start_page.dart';

void main() async {
  // FlutterError.onError = (details) {
  //   FlutterError.presentError(details);
  //   print("Ballz");
  // };
  ErrorWidget.builder = (error)=>ErrorWid(error: error);
  // PlatformDispatcher.instance.onError = (error,stack){
  //   FlutterError.presentError(FlutterErrorDetails(exception: error,stack: stack));
  //   print("Sex");
  //   return true;
  // };
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  Hive.init("${(await getApplicationDocumentsDirectory()).path}/HomeLib");
  Hive.registerAdapter(HomeItemAdapter());
  Hive.registerAdapter(PaheAdapter());
  Hive.registerAdapter(DownloadAdapter());
  Hive.registerAdapter(DownloadStatusAdapter());
  await Hive.openBox("playtime");
  await Hive.openBox<Download>("download");
  await Hive.openBox("offline");
  final box = await Hive.openBox("settings");
  if (box.get("resolution") == null) await box.put('resolution', '720p');
  if (box.get("fallBackResHigh") == null) await box.put("fallBackResHigh", true);
  if (box.get("downloadRes") == null) await box.put("downloadRes", '720p');
  if (box.get("getM3u8") == null) await box.put("getM3u8", false);

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
        RepositoryProvider(create: (context) => HomeRepo()),
        RepositoryProvider(create: (context) => DownloadRepo()),
        RepositoryProvider(create: (context) => WcoRepo()),
      ],
      child: MultiBlocProvider(providers: [
        BlocProvider(
            create: (context) =>
                SettingsBloc(setrepo: context.read<SettingsRepository>())),
        BlocProvider(
            create: (context) => HomeBloc(repo: context.read<HomeRepo>())),
        BlocProvider(
            create: (context) =>
                DownloadBloc(repo: context.read<DownloadRepo>())),
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [CustomObserver(context)],
      theme: theme,
      home: storagePath != '' ? HomePage() : StartPage(),
    );
  }
}

class ErrorWid extends StatelessWidget {
  ErrorWid({super.key, required this.error});
  final FlutterErrorDetails error;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Column(
                    children: [
            Row(
              children: [
                Icon(
                  Icons.bug_report,
                  size: 50,
                ),
                Text(
                  "Error",
                  style: TextStyle(fontSize: 50),
                )
              ],
            ),
            Text(
                "An Error was occured during the runtime of the app. Please see the error message below"),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          border: Border.all(color: Colors.blue, width: 3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('$error')),
                  ],
                ),
              ),
            ),
            SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: () {
                      exit(1);
                    },
                    child: Text("Close App"))),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: error.toString()));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Copied to clipboard!")),
                      );
                    },
                    child: Text("Copy Error to ClipBoard"))),
                    ],
                  ),
          )),
    );
  }
}
