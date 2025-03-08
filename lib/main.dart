import 'package:app/repository/pahe_repo.dart';
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:app/repository/settings_repo.dart';
import 'package:app/bloc/settings/settings_bloc.dart';

import 'package:app/pages/home_page.dart';
import 'package:app/pages/start_page.dart';
import 'package:path_provider/path_provider.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // MediaKit.ensureInitialized();
  String path = (await getApplicationDocumentsDirectory()).path;
  Hive.init("$path/PaheApp");
  if (await Hive.boxExists("settings")) {
    await Hive.openBox("settings");
  } else {
    final box = await Hive.openBox("settings");
    box.put("theme", "dark");
  }

  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers:[RepositoryProvider(
        create: (context) => SettingsRepository(),),
        RepositoryProvider(create: (context)=>PaheRepo())],
      child:BlocProvider(
            create: (context) =>
                SettingsBloc(setrepo: context.read<SettingsRepository>()),
            child: const AniApp()), 
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
      theme: theme,
      home: storagePath != '' ? HomePage() : StartPage(),
    );
  }
}
