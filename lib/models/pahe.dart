import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
part 'pahe.g.dart';
@HiveType(typeId: 1)
class Pahe extends Equatable{
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String imageUrl;
  @HiveField(2)
  final int episode;
  @HiveField(3)
  final int id;
  @HiveField(4)
  final String animeSession;
  @HiveField(5)
  final String episodeSession;
  @HiveField(6)
  final int? episode2;

  Pahe({data}):
    title = data['anime_title'],
    id = data['id'],
    episode = data['episode'],
    episode2 = data['episode2'],
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