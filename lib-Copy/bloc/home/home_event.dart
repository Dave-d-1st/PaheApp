part of 'home_bloc.dart';

sealed class HomeEvent {

}

class GetHomeItems extends HomeEvent{

}
class AddHomeItem extends HomeEvent{
  final AnimeState state;
  AddHomeItem({required this.state});
}
class SavedItem extends HomeEvent{
  final HomeItem item;
  SavedItem({required this.item});
}
