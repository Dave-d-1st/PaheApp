part of 'home_bloc.dart';

sealed class HomeEvent {

}

class AddHomeItem extends HomeEvent{
  final AnimeState state;
  AddHomeItem({required this.state});
}
class SavedItem extends HomeEvent{
  final HomeItem item;
  SavedItem({required this.item});
}

class GetPlayTime extends HomeEvent{
  final String episode;
  GetPlayTime({required this.episode});
}
class Refresh extends HomeEvent{
  final HomeItem item;
  Refresh(this.item);
}

class Update extends HomeEvent{
  
}

class Migrate extends HomeEvent{
  
}