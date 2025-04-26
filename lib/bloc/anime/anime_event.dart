part of 'anime_bloc.dart';
sealed class AnimeEvent {}

class StartAniPage extends AnimeEvent{
  final String url;
  StartAniPage({url}):
  url = "https://animepahe.ru/anime/$url";
}

class GetEpisodes extends AnimeEvent{
  final String url;
  GetEpisodes({url}):
  url="https://animepahe.ru/api?m=release&id=$url&sort=episode_asc&page=";
}
