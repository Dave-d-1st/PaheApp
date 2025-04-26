import 'package:app/bloc/download/download_bloc.dart';
import 'package:app/models/download.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

String convertSize(num size) {
    if (size < 1024) {
      return "$size B";
    } else if (size < 1024 * 1024) {
      return "${(size / 1024).toStringAsFixed(2)} KB";
    } else if (size < 1024 * 1024 * 1024) {
      return "${(size / (1024 * 1024)).toStringAsFixed(2)} MB";
    } else {
      return "${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB";
    }
}

class DownloadPage extends StatelessWidget {
  const DownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    var bloc = context.read<DownloadBloc>();
    Color priamaryColor = Theme.of(context).colorScheme.onPrimaryFixedVariant;
    Color backgroundColor = Theme.of(context).primaryColor;
    return BlocBuilder<DownloadBloc, DownloadState>(builder: (context, state) {
      return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(state.paused?Icons.play_arrow:Icons.pause),
          label: Text(state.paused?"Resume":"Pause"),
          onPressed: () {
          bloc.add(PlayPause());
        }),
        appBar: AppBar(
          title: Text("Downloads(${state.downloading.length})"),
        ),
        body: ReorderableListView.builder(
          buildDefaultDragHandles: false,
          onReorder: (oldIndex, newIndex) async{
            if (newIndex > oldIndex) newIndex--;
            bloc.add(ChangeOrder(oldIndex, newIndex));
          },
          itemCount: state.downloading.length,
          itemBuilder: (context, index) {
            Download download = state.downloading.elementAt(index);
            Duration speedDur = Duration(seconds:(((download.size??0) - ((download.size??0)*download.progress))/(download.speed>0?download.speed:1)).toInt());
            String speedText = "${speedDur.inMinutes.toString().padLeft(2,'0')}:${(speedDur.inSeconds%60).toString().padLeft(2,'0')}";

            return Slidable(
              key: Key("${download.id}"),
              
              
              startActionPane: ActionPane(
                
                  motion: ScrollMotion(),
                  dismissible: DismissiblePane(
                    onDismissed: (){
                    bloc.add(Cancel(index));
                  }),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        bloc.add(Cancel(index));
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.cancel,
                    ),
                    SlidableAction(
                      onPressed: (context) {
                        bloc.add(GroupCancel(download.title));
                      },
                      backgroundColor: const Color.fromARGB(255, 255, 17, 0),
                      foregroundColor: Colors.white,
                      icon: Icons.group_off,
                    ),
                  ]),
              endActionPane: ActionPane(
                  motion: ScrollMotion(),
                  dismissible: DismissiblePane(onDismissed: () {
                  }),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        bloc.add(Restore(download));
                      },
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.black,
                      icon: Icons.restore,
                    ),
                    SlidableAction(
                      onPressed: (context) async{
                        await Future.delayed(Duration(milliseconds: 300));
                        bloc.add(MoveGroupUp(download.title));
                        
                      },
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.black,
                      icon: Icons.keyboard_double_arrow_up,
                    ),
                    SlidableAction(
                      onPressed: (context) async{
                        await Future.delayed(Duration(milliseconds: 300));
                        bloc.add(ChangeOrder(index, 0));
                      },
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                      icon: Icons.arrow_upward,
                    ),
                  ]),
              child: Container(
                decoration: BoxDecoration(
                  color: download.status==DownloadStatus.error?Colors.red:null,
                    gradient: download.status!=DownloadStatus.error?LinearGradient(
                        colors: [priamaryColor, backgroundColor],
                        stops: [download.progress, download.progress]):null),
                child: ListTile(
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: Icon(Icons.drag_handle),
                  ),
                  title: Text(download.title),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "${(download.progress * 100).round()}% | ${convertSize(download.size??0)}"),
                      Text("${convertSize(download.speed)}/s | ${download.speed==0?'--:--':speedText}")
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
