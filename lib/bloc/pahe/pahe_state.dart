part of 'pahe_bloc.dart';

enum PaheStatus{done,searching,error}
class PaheState extends Equatable{
  final List episodeInfos;
  final PaheRepo repo;
  final PaheStatus status;
  final Map? search;
  PaheState({required this.repo,this.status=PaheStatus.searching}):
    episodeInfos = List.from(repo.episodes),
    search = repo.search;

  @override
  List<Object?> get props => [episodeInfos,status,search];

  @override
  String toString() {
    return "Pahe(episdeInfos: $episodeInfos)";
  }
}
