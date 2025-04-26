part of 'wco_bloc.dart';
enum WcoStatus{searching,done,error}
class WcoState {
  final List animes;
  final WcoStatus status;
  WcoState(WcoRepo repo,[this.status=WcoStatus.done]):animes = repo.animes;
}