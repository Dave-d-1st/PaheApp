import 'package:equatable/equatable.dart';

class Pahe extends Equatable{
  final String title;
  final String imageUrl;
  final int episode;
  final int id;
  final String animeSession;
  final String episodeSession;

  Pahe({data}):
    title = data['anime_title'],
    id = data['id'],
    episode = data['episode'],
    imageUrl = data['snapshot'],
    animeSession =data['anime_session'],
    episodeSession = data['session'];

  @override
  List<Object?> get props => [id,title, imageUrl, episode];

  @override
  String toString() {
    return "Pahe(id: $id, title: $title, imageUrl: $imageUrl, episode: $episode)";
  }
}