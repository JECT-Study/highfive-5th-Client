import '../../models/lineup.dart';

abstract interface class LineupRepository {
  Future<Lineup> getLineup(int concertId);
  Future<void> saveLineup(int concertId, List<int> bandIds);
  Future<BandSetlist> getSetlist(int concertId, int bandId);
  Future<void> saveSetlist(int concertId, int bandId, List<LineupSong> songs);
  Future<List<LineupSong>> searchSongs(String keyword);
}
