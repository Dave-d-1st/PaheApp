part of 'home_bloc.dart';

class HomeState extends Equatable {
  final Map<int, HomeItem> homeInfos;
  final Map<String,List<int>> playtime;
  final bool reload;
  HomeState({required HomeRepo repo,this.reload=false}) : 
  homeInfos = repo.homeInfos,
  playtime=repo.playtime;

  @override
  List<Object?> get props => [Map.from(homeInfos).hashCode,reload];
}
