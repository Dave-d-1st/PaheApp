part of 'wcos_bloc.dart';

sealed class WcosEvent {}

class GetAnimeInfo extends WcosEvent{
  final String url;
  GetAnimeInfo(this.url);
}