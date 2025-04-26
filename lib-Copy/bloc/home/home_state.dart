part of 'home_bloc.dart';

class HomeState extends Equatable{
  final Map<String,HomeItem> homeInfos;
  HomeState({required HomeRepo repo}):
  homeInfos=repo.homeInfos;

  @override
  // TODO: implement props
  List<Object?> get props => [Map.from(homeInfos).hashCode];
}