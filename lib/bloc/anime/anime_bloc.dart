import 'dart:async';

import 'package:app/models/pahe.dart';
import 'package:app/repository/pahe_repo.dart';
import 'package:bloc/bloc.dart';
import 'dart:typed_data';
import 'package:app/bloc/pahe/pahe_bloc.dart';
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
      List datas = response['data'];
      for (var data in datas) {
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
    emit(AnimeState(
      repo: _repo,
      session: event.url.split('/').last,
    ));
    await _repo.getAnimeInfo(event.url);
    if (_repo.error != null) {
      emit(AnimeState(
          repo: _repo,
          status: PaheStatus.error,
          session: event.url.split('/').last));
    } else {
      emit(AnimeState(
          repo: _repo,
          status: PaheStatus.done,
          session: event.url.split('/').last));
      if (!isClosed) {
        add(GetEpisodes(url: event.url.split('/').last));
      }
    }
  }
}
