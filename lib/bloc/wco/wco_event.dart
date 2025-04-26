part of 'wco_bloc.dart';
sealed class WcoEvent {}

class StartWco extends WcoEvent{}

class GetSearch extends WcoEvent{
  final String searchTerm;
  GetSearch(this.searchTerm);
}