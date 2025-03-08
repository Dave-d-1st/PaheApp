import 'package:app/bloc/pahe/pahe_bloc.dart';
import 'package:app/repository/pahe_repo.dart';
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:app/bloc/settings/settings_bloc.dart';
import 'package:app/pages/pahe_page.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        openButtonBuilder: RotateFloatingActionButtonBuilder(
            child: const Icon(Icons.add),
            fabSize: ExpandableFabSize.regular,
            shape: const CircleBorder(),
          ),
          closeButtonBuilder: DefaultFloatingActionButtonBuilder(
            child: const Icon(Icons.close),
            shape: const CircleBorder(),
          ),children: [
        FloatingActionButton(onPressed: (){
          var pRepo = context.read<PaheRepo>();
          Navigator.push(context, MaterialPageRoute(builder: (context)=>BlocProvider(create: (context)=>PaheBloc(repo: pRepo),
            child: PahePage())));
        },child: Image.asset('assets/images/pika_icon.png'),)
      ]),
      body: Center(
        child: FilledButton(
            onPressed: () {
              context.read<SettingsBloc>().add(ChangeTheme());
            },
            child: Text("Change Theme")),
      ),
    );
  }
}
