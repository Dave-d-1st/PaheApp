part of 'download_bloc.dart';

class DownloadState {
  final List downloading;
  final List currentDownloads;
  final bool paused;
  final List? downs;
  DownloadState(DownloadRepo repo,[this.downs]):
  downloading = downs??repo.downloading,
  paused=repo.paused,
  currentDownloads = repo.currentDownloads;
}