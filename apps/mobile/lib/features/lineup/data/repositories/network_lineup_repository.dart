import '../../models/lineup.dart';
import '../dto/save_setlist_request.dart';
import '../services/lineup_service.dart';
import 'lineup_repository.dart';

/// 서버가 상태를 보유한다. 세션별 factory로 생성해도 공유 메모리 캐시가 없다.
class NetworkLineupRepository implements LineupRepository {
  NetworkLineupRepository(this._service);

  final LineupService _service;

  @override
  Future<Lineup> getLineup(int concertId) async =>
      (await _service.getLineup(concertId)).toModel();

  @override
  Future<void> saveLineup(int concertId, List<int> bandIds) =>
      _service.saveLineup(concertId, bandIds);

  @override
  Future<BandSetlist> getSetlist(int concertId, int bandId) async =>
      (await _service.getSetlist(concertId, bandId)).toModel();

  @override
  Future<void> saveSetlist(int concertId, int bandId, List<LineupSong> songs) =>
      _service.saveSetlist(concertId, bandId, setlistRequest(songs));

  @override
  Future<List<LineupSong>> searchSongs(String keyword) async =>
      (await _service.searchSongs(keyword.trim())).songs
          .map((song) => song.toModel())
          .toList();
}
