import '../../../../core/error/app_exception.dart';
import '../../models/lineup.dart';
import 'lineup_repository.dart';

/// 세션별로 생성한다. 공연 1, 2 / 밴드 3, 7, 12만 존재한다.
/// 밴드 3 멤버의 시점이며 새 인스턴스는 모든 편집 상태를 초기화한다.
class FakeLineupRepository implements LineupRepository {
  FakeLineupRepository() {
    for (final concertId in [1, 2]) {
      _orders[concertId] = [3, 7, 12];
      _setlists[concertId] = {
        3: [],
        7: [
          const LineupSong(
            type: SongType.original,
            songTitle: '새벽의 노래',
            durationSeconds: 252,
          ),
          ..._catalog,
        ],
        12: [],
      };
    }
  }

  final _orders = <int, List<int>>{};
  final _setlists = <int, Map<int, List<LineupSong>>>{};

  static const _bands = {
    3: LineupBand(
      bandId: 3,
      name: '소음공장',
      genres: ['ROCK', 'INDIE'],
      memberCount: 4,
    ),
    7: LineupBand(bandId: 7, name: '새벽세시', genres: ['ROCK'], memberCount: 5),
    12: LineupBand(bandId: 12, name: '푸른파도', genres: ['POP'], memberCount: 3),
  };

  static const _catalog = [
    LineupSong(
      type: SongType.searched,
      trackId: 'abc123',
      songTitle: 'Wonderwall',
      artist: 'Oasis',
      durationSeconds: 258,
    ),
    LineupSong(
      type: SongType.searched,
      trackId: 'oasis-dont-look-back',
      songTitle: "Don't Look Back in Anger",
      artist: 'Oasis',
      durationSeconds: 288,
    ),
    LineupSong(
      type: SongType.searched,
      trackId: 'oasis-live-forever',
      songTitle: 'Live Forever',
      artist: 'Oasis',
      durationSeconds: 276,
    ),
  ];

  List<int> _order(int concertId) =>
      _orders[concertId] ??
      (throw const ApiException(statusCode: 404, code: 'CONCERT_001'));

  @override
  Future<Lineup> getLineup(int concertId) async {
    final order = _order(concertId);
    return Lineup(
      teams: [
        for (var i = 0; i < order.length; i++)
          LineupTeam(
            concertTeamId: concertId * 100 + order[i],
            lineupOrder: i + 1,
            isHost: order[i] == 3,
            band: _bands[order[i]]!,
            setlistPreview: _setlists[concertId]![order[i]]!
                .take(3)
                .map((song) => song.songTitle)
                .toList(),
            setlistTotalCount: _setlists[concertId]![order[i]]!.length,
          ),
      ],
      emptySlotCount: 1,
    );
  }

  @override
  Future<void> saveLineup(int concertId, List<int> bandIds) async {
    final order = _order(concertId);
    if (bandIds.isEmpty || bandIds.toSet().length != bandIds.length) {
      throw const ApiException(statusCode: 400, code: 'COMMON_004');
    }
    if (bandIds.length != order.length || !bandIds.toSet().containsAll(order)) {
      throw const ApiException(statusCode: 409, code: 'CONCERT_014');
    }
    _orders[concertId] = List.of(bandIds);
  }

  @override
  Future<BandSetlist> getSetlist(int concertId, int bandId) async {
    if (!_order(concertId).contains(bandId)) {
      throw const ApiException(statusCode: 404, code: 'CONCERT_007');
    }
    return BandSetlist(
      isHost: bandId == 3,
      canEdit: bandId == 3,
      band: _bands[bandId]!,
      songs: List.of(_setlists[concertId]![bandId]!),
    );
  }

  @override
  Future<void> saveSetlist(
    int concertId,
    int bandId,
    List<LineupSong> songs,
  ) async {
    _order(concertId);
    for (final song in songs) {
      final validTypeFields = switch (song.type) {
        SongType.original =>
          song.trackId == null &&
              song.artist == null &&
              song.albumImageUrl == null,
        SongType.searched =>
          song.trackId != null &&
              song.trackId!.trim().isNotEmpty &&
              song.artist != null &&
              song.artist!.trim().isNotEmpty &&
              song.artist!.runes.length <= 100 &&
              song.durationSeconds != null,
      };
      if (song.songTitle.trim().isEmpty ||
          song.songTitle.runes.length > 100 ||
          (song.durationSeconds != null && song.durationSeconds! < 1) ||
          !validTypeFields) {
        throw const ApiException(statusCode: 400, code: 'COMMON_004');
      }
    }
    if (!_orders[concertId]!.contains(bandId)) {
      throw const ApiException(statusCode: 404, code: 'CONCERT_007');
    }
    if (bandId != 3) {
      throw const ApiException(statusCode: 403, code: 'AUTH_005');
    }
    _setlists[concertId]![bandId] = List.of(songs);
  }

  @override
  Future<List<LineupSong>> searchSongs(String keyword) async {
    final query = keyword.trim();
    if (query.isEmpty || query.runes.length > 50) {
      throw const ApiException(statusCode: 400, code: 'COMMON_004');
    }
    return [
      for (final song in _catalog)
        if (song.songTitle.toLowerCase().contains(query.toLowerCase()) ||
            song.artist!.toLowerCase().contains(query.toLowerCase()))
          song,
    ];
  }
}
