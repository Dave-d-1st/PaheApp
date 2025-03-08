import 'package:app/bloc/settings/settings_bloc.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:app/pages/home_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    String storagePath = context.select(
      (SettingsBloc value) => value.state.storagePath,
    );
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.handshake,
              size: 50,
            ),
            Text(
              "Welcome!",
              style: TextStyle(fontSize: 50),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
                "To get started, please provide the locations for important functions like downloads and backups. This will help us keep everything organized and running smoothly."),
            SizedBox(
              height: 10,
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "Choose a folder where Ani will save episode downloads, backups, and other related files. This will ensure that all your content is stored in one place for easy access."),
                    SizedBox(
                      height: 20,
                    ),
                    Text("A Dedicated folder would be preferential"),
                    SizedBox(
                      height: 20,
                    ),
                    Text("The currently selected folder is $storagePath"),
                    SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          context.read<SettingsBloc>().add(FilePicked());
                        },
                        child: Text("Select a Folder"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            SizedBox(width: double.infinity,
              child: FilledButton(
                  
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ));
                  },
                  child: Text("Continue")),
            )
          ],
        ),
      ),
    );
  }
}
