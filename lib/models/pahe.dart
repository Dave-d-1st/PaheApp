import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
part 'pahe.g.dart';
@HiveType(typeId: 1)
class Pahe extends Equatable{
  final String title;
  final String imageUrl;
  final num episode;
  final int id;
  final bool completed;
  final String animeSession;
  final String episodeSession;
  final int? episode2;
  @HiveField(0)
  final Map data;
  Pahe({required this.data}):
    title = data['anime_title'],
    id = data['id'],
    episode = data['episode'],
    episode2 = data['episode2'],
    completed = data['completed']==1?true:false,
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