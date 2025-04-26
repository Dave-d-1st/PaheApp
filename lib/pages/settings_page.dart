import 'package:app/bloc/home/home_bloc.dart';
import 'package:app/bloc/settings/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController watchController;
  late TextEditingController downloadController;
  late SettingsBloc bloc;
  @override
  void initState() {
    bloc = context.read<SettingsBloc>();
    watchController = TextEditingController(text: bloc.state.watchRes);
    downloadController = TextEditingController(text: bloc.state.downloadRes);
    watchController.addListener((){
      bloc.add(ChangeWatchRes(watchController.text.contains('p')?watchController.text:"${watchController.text}p"));
    });
    downloadController.addListener((){
      bloc.add(ChangeDownloadRes(downloadController.text.contains('p')?downloadController.text:"${downloadController.text}p"));
    });
    super.initState();
  }
  @override
  void dispose() {
    watchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
          return ListView(
            children: [
              ListTile(
                title: Text("Set Dowload Resolution"),
                subtitle: Text(state.downloadRes),
                onTap: () {  
                  showDialog(
                      context: context,
                      builder: (context) {
                        List defaultRes = ["360p", '720p', '1080p'];
                        return BlocBuilder<SettingsBloc,SettingsState>(
                          builder: (context,state) {
                            return AlertDialog(
                              
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (var res in defaultRes)
                                    RadioListTile(
                                      title: Text(res),
                                      value: res,
                                      groupValue: state.downloadRes,
                                      onChanged: (value) {
                                        bloc.add(ChangeDownloadRes(res));
                                        Navigator.pop(context);
                                      },
                                    ),
                                  RadioListTile(
                                      title: Text("Custom"),
                                      value: !defaultRes.contains(state.downloadRes)
                                          ? state.downloadRes
                                          : '',
                                      groupValue: state.downloadRes,
                                      onChanged: (value) {
                                        bloc.add(ChangeDownloadRes(downloadController.text));
                                      }),
                                      !defaultRes.contains(state.downloadRes)?TextField(
                                        controller: downloadController,
                                      ):SizedBox(),
                                ],
                              ),
                            );
                          }
                        );
                      });
                },
              ),
              ListTile(
                title: Text("Set Watch Resolution"),
                subtitle: Text(state.watchRes),
                onTap: () {  
                  showDialog(
                      context: context,
                      builder: (context) {
                        List defaultRes = ["360p", '720p', '1080p'];
                        return BlocBuilder<SettingsBloc,SettingsState>(
                          builder: (context,state) {
                            return AlertDialog(
                              
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (var res in defaultRes)
                                    RadioListTile(
                                      title: Text(res),
                                      value: res,
                                      groupValue: state.watchRes,
                                      onChanged: (value) {
                                        bloc.add(ChangeWatchRes(res));
                                        Navigator.pop(context);
                                        
                                      },
                                    ),
                                  RadioListTile(
                                      title: Text("Custom"),
                                      value: !defaultRes.contains(state.watchRes)
                                          ? state.watchRes
                                          : '',
                                      groupValue: state.watchRes,
                                      onChanged: (value) {
                                        bloc.add(ChangeWatchRes(watchController.text));
                                      }),
                                      !defaultRes.contains(state.watchRes)?TextField(
                                        controller: watchController,
                                      ):SizedBox(),
                                ],
                              ),
                            );
                          }
                        );
                      });
                },
              ),
              ListTile(
                title: Text("FallBack Resolution"),
                subtitle: Text(
                    "If Watch or Download Resolution is unavailable, it will use the highest resolution if true."),
                trailing: Switch(
                    value: state.fallBackRes,
                    onChanged: (value) {
                      bloc.add(ChangeFallbackRes());
                    }),
              ),
              ListTile(
                title: Text("Always get .M3U8 file"),
                subtitle: Text("When watching from wcofun it will always get the m3u8 file"),
                trailing: Switch(
                    value: state.getM3u8,
                    onChanged: (value) {
                      bloc.add(ChangegetM3u8());
                    }),
              ),
              ListTile(
                title: Text("Migrate"),
                onTap: () {var boc = context.read<HomeBloc>();
                boc.add(Migrate());},
              )
              // ListTile(
              //   title: Text("Throw Error"),
              //   onTap: () => throw Exception("Deez nutz"),
              // )
            ],
          );
        }));
  }
}
