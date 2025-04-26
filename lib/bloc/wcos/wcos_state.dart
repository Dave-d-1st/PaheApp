part of 'wcos_bloc.dart';
class WcosState {
  final WcoStatus status;
  final String title;
  final String synopsis;
  final List genres;
  final List episodes;
  final Uint8List? image;
  final double imageHeight;
  WcosState(data,{this.status = WcoStatus.done}):
  title = data['title']??'',
  synopsis = data['syn']??'',
  genres = data['genres']??[],
  episodes = data['episodes']??[],
  image = data['image'],
  imageHeight = data['height']??1;
}
