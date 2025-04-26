part of 'download_bloc.dart';
sealed class DownloadEvent {}

class AddDownload extends DownloadEvent{
  final String url;
  final String title;
  AddDownload(this.url,this.title);
}

class Started extends DownloadEvent{
  
}
class Update extends DownloadEvent{
  
}
class Restore extends DownloadEvent{
  final Download download ;
  Restore(this.download);
}
class GroupCancel extends DownloadEvent{
   final String title;
   GroupCancel(this.title);
}
class Cancel extends DownloadEvent{
  final int index;
  Cancel(this.index);

}

class MoveGroupUp extends DownloadEvent{
  final String title;
  MoveGroupUp(this.title);

}
class ChangeOrder extends DownloadEvent{
  final int oldIndex;
  final int newIndex;
  ChangeOrder(this.oldIndex,this.newIndex);

}
class PlayPause extends DownloadEvent{
}