import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/lineup/data/repositories/fake_lineup_repository.dart';
import 'package:highfive/features/lineup/data/repositories/lineup_repository.dart';
import 'package:highfive/features/lineup/models/lineup.dart';

Matcher apiError(int status, String code) => isA<ApiException>()
    .having((error) => error.statusCode, 'statusCode', status)
    .having((error) => error.code, 'code', code);

void main() {
  late LineupRepository repository;
  setUp(() => repository = FakeLineupRepository());

  test('두 데모 공연은 세 팀, 빈 자리, 편집 권한을 제공한다', () async {
    for (final concertId in [1, 2]) {
      final lineup = await repository.getLineup(concertId);
      expect(lineup.teams.map((team) => team.band.bandId), [3, 7, 12]);
      expect(lineup.teams.map((team) => team.lineupOrder), [1, 2, 3]);
      expect(lineup.emptySlotCount, 1);
      final editable = await repository.getSetlist(concertId, 3);
      expect(editable.canEdit, isTrue);
      expect(editable.isHost, isTrue);
      expect(editable.songs, isEmpty);
      final readonly = await repository.getSetlist(concertId, 7);
      expect(readonly.canEdit, isFalse);
      expect(readonly.isHost, isFalse);
      expect(
        lineup.teams[1].setlistPreview,
        readonly.songs.take(3).map((song) => song.songTitle),
      );
      expect(lineup.teams[1].setlistTotalCount, 4);
    }
  });

  test('공연 순서를 전체 교체하고 주최 팀도 옮기며 다른 공연과 세션은 보존한다', () async {
    final ids = [12, 7, 3];
    await repository.saveLineup(1, ids);
    ids.clear();
    final lineup = await repository.getLineup(1);
    expect(lineup.teams.map((team) => team.band.bandId), [12, 7, 3]);
    expect(lineup.teams.map((team) => team.lineupOrder), [1, 2, 3]);
    expect(lineup.teams.last.isHost, isTrue);
    expect((await repository.getLineup(2)).teams.first.band.bandId, 3);
    expect(
      (await FakeLineupRepository().getLineup(1)).teams.first.band.bandId,
      3,
    );
  });

  for (final (ids, status, code) in <(List<int>, int, String)>[
    ([], 400, 'COMMON_004'),
    ([3, 3, 7], 400, 'COMMON_004'),
    ([3, 7], 409, 'CONCERT_014'),
    ([3, 7, 99], 409, 'CONCERT_014'),
    ([3, 7, 12, 99], 409, 'CONCERT_014'),
  ]) {
    test('잘못되거나 오래된 밴드 목록 $ids 저장을 거부하고 순서를 유지한다', () async {
      await expectLater(
        repository.saveLineup(1, ids),
        throwsA(apiError(status, code)),
      );
      expect(
        (await repository.getLineup(1)).teams.map((team) => team.band.bandId),
        [3, 7, 12],
      );
    });
  }

  test('검색 곡과 자작곡의 순서·중복을 저장하고 빈 배열로 비울 수 있다', () async {
    final searched = await repository.searchSongs(' Oasis ');
    final songs = [
      searched.first,
      const LineupSong(type: SongType.original, songTitle: '자작곡'),
      searched.first,
    ];
    await repository.saveSetlist(1, 3, songs);
    songs.clear();
    final saved = await repository.getSetlist(1, 3);
    expect(saved.songs.map((song) => song.songTitle), [
      'Wonderwall',
      '자작곡',
      'Wonderwall',
    ]);
    final team = (await repository.getLineup(1)).teams.first;
    expect(team.setlistPreview, ['Wonderwall', '자작곡', 'Wonderwall']);
    expect(team.setlistTotalCount, 3);
    expect((await repository.getSetlist(2, 3)).songs, isEmpty);
    expect((await FakeLineupRepository().getSetlist(1, 3)).songs, isEmpty);
    await repository.saveSetlist(1, 3, []);
    expect((await repository.getSetlist(1, 3)).songs, isEmpty);
    expect((await repository.getLineup(1)).teams.first.setlistTotalCount, 0);
  });

  for (final bandId in [7, 12]) {
    test('다른 팀 $bandId 셋리스트는 조회되지만 저장 권한은 없다', () async {
      final before = await repository.getSetlist(1, bandId);
      await expectLater(
        repository.saveSetlist(1, bandId, []),
        throwsA(apiError(403, 'AUTH_005')),
      );
      expect(await repository.getSetlist(1, bandId), before);
    });
  }

  test('참여하지 않은 밴드의 조회와 저장을 거부한다', () async {
    await expectLater(
      repository.getSetlist(1, 99),
      throwsA(apiError(404, 'CONCERT_007')),
    );
    await expectLater(
      repository.saveSetlist(1, 99, []),
      throwsA(apiError(404, 'CONCERT_007')),
    );
  });

  for (final concertId in [-1, 0, 3, 999]) {
    test('미등록 공연 $concertId 모든 연산은 CONCERT_001이다', () async {
      for (final operation in [
        () => repository.getLineup(concertId),
        () => repository.saveLineup(concertId, [3, 7, 12]),
        () => repository.getSetlist(concertId, 3),
        () => repository.saveSetlist(concertId, 3, []),
      ]) {
        await expectLater(operation(), throwsA(apiError(404, 'CONCERT_001')));
      }
    });
  }

  final invalidSongs = [
    const LineupSong(type: SongType.original, songTitle: '  '),
    LineupSong(type: SongType.original, songTitle: 'a' * 101),
    const LineupSong(
      type: SongType.original,
      songTitle: 'a',
      durationSeconds: 0,
    ),
    const LineupSong(type: SongType.original, songTitle: 'a', trackId: 'abc'),
    const LineupSong(type: SongType.original, songTitle: 'a', artist: 'Oasis'),
    const LineupSong(
      type: SongType.original,
      songTitle: 'a',
      albumImageUrl: 'x',
    ),
    const LineupSong(type: SongType.searched, songTitle: 'a'),
    const LineupSong(
      type: SongType.searched,
      songTitle: 'a',
      trackId: 'x',
      artist: 'Oasis',
    ),
    const LineupSong(
      type: SongType.searched,
      songTitle: 'a',
      trackId: '',
      artist: 'Oasis',
      durationSeconds: 1,
    ),
    const LineupSong(
      type: SongType.searched,
      songTitle: 'a',
      trackId: 'x',
      artist: '',
      durationSeconds: 1,
    ),
    LineupSong(
      type: SongType.searched,
      songTitle: 'a',
      trackId: 'x',
      artist: 'a' * 101,
      durationSeconds: 1,
    ),
  ];
  for (var i = 0; i < invalidSongs.length; i++) {
    test('곡 필드 검증 실패 $i 때 저장하지 않는다', () async {
      await expectLater(
        repository.saveSetlist(1, 3, [invalidSongs[i]]),
        throwsA(apiError(400, 'COMMON_004')),
      );
      expect((await repository.getSetlist(1, 3)).songs, isEmpty);
    });
  }

  test('제목과 아티스트를 대소문자 무시해 검색하며 결과는 검색 곡이다', () async {
    final oasis = await repository.searchSongs(' oAsIs ');
    expect(oasis.map((song) => song.trackId), [
      'abc123',
      'oasis-dont-look-back',
      'oasis-live-forever',
    ]);
    expect(oasis.every((song) => song.type == SongType.searched), isTrue);
    expect(
      (await repository.searchSongs('wonderwall')).single.trackId,
      'abc123',
    );
    expect(await repository.searchSongs('없는노래'), isEmpty);
  });

  for (final keyword in [' ', 'a' * 51]) {
    test('검색어 길이 검증 실패 ${keyword.length}', () async {
      await expectLater(
        repository.searchSongs(keyword),
        throwsA(apiError(400, 'COMMON_004')),
      );
    });
  }
}
