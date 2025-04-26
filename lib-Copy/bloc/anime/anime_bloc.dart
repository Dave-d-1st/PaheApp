import 'package:app/models/pahe.dart';
import 'package:app/repository/pahe_repo.dart';
import 'package:bloc/bloc.dart';
import 'dart:typed_data';
import 'package:app/bloc/pahe/pahe_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
part 'anime_event.dart';
part 'anime_state.dart';

class AnimeBloc extends Bloc<AnimeEvent, AnimeState> {
  final PaheRepo _repo;
  AnimeBloc({required repo})
      : _repo = repo,
        super(AnimeState(repo: repo)) {
    on<StartAniPage>(_aniPageStarted);
    on<GetEpisodes>(_getEpisodes);
  }

  Future<void> _getEpisodes(GetEpisodes event, Emitter<AnimeState> emit) async {
    int epiPage = 1;
    bool nextPage = true;
    final episodes = [];
    do {
      var response = await _repo.getEpisodes("${event.url}$epiPage");
      List datas = response[
          'data']; // {"id":64223,"anime_id":4,"episode":1122,"episode2":0,"edition":"","title":"","snapshot":"https:\/\/i.animepahe.ru\/snapshots\/069b876a55ac41fbbe3fc992f04297d7902b204a257762ed15a4c2901c21b28f.jpg","disc":"","audio":"jpn","duration":"00:23:51","session":"88cc15701d9466075d81eee854b8d8a9a9a9dc64f409c42c738ef36ec2585d7e","filler":0,"created_at":"2024-10-13 02:54:45"},
      for (var data in datas) {
        ids['${state.session}/${data['session']}'] = data['id'];
        Map info = {
          "anime_title": data["duration"],
          "id": data['id'],
          "episode": data['episode'],
          "episode2": data['episode2'],
          "snapshot": data["snapshot"],
          "anime_session": state.session,
          "session": data['session']
        };
        episodes.add(Pahe(data: info));
      }
      emit(AnimeState(
          repo: _repo,
          episodes: episodes,
          status: PaheStatus.done,
          session: event.url.split('/').last,
          id: datas.first['anime_id']));
      epiPage++;
      nextPage = response['next_page_url'] != null ? true : false;
    } while (nextPage);
  }

  Future<void> _aniPageStarted(
      StartAniPage event, Emitter<AnimeState> emit) async {
    emit(AnimeState(repo: _repo, session: event.url.split('/').last));
    await _repo.getAnimeInfo(event.url);
    emit(AnimeState(
        repo: _repo,
        status: PaheStatus.done,
        session: event.url.split('/').last));
    
    add(GetEpisodes(url: event.url.split('/').last));
  }

  
}
