import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/lineup/data/repositories/lineup_repository.dart';
import 'package:highfive/features/lineup/data/repositories/network_lineup_repository.dart';
import 'package:highfive/features/lineup/data/services/lineup_service.dart';
import 'package:highfive/features/lineup/models/lineup.dart';

class _Adapter implements HttpClientAdapter {
  int status = 200;
  Map<String, Object?> data = {};
  String code = 'COMMON_000';
  late RequestOptions request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode({'status': status, 'code': code, 'message': '', 'data': data}),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _band = {
  'bandId': 3,
  'name': '소음공장',
  'profileImageUrl': null,
  'genres': ['ROCK', 'INDIE'],
  'memberCount': 4,
};

void main() {
  late _Adapter adapter;
  late LineupRepository repository;
  late Dio dio;
  setUp(() {
    adapter = _Adapter();
    dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    repository = NetworkLineupRepository(LineupService(dio));
  });
  tearDown(() => dio.close(force: true));

  test('라인업 응답의 팀·밴드·미리보기 필드를 모델로 변환한다', () async {
    adapter.data = {
      'teams': [
        {
          'concertTeamId': 21,
          'lineupOrder': 2,
          'isHost': true,
          'band': _band,
          'setlistPreview': ['Creep', '한숨', '나는 나비'],
          'setlistTotalCount': 5,
        },
      ],
      'emptySlotCount': 2,
    };
    final lineup = await repository.getLineup(1);
    expect(adapter.request.method, 'GET');
    expect(
      adapter.request.uri.toString(),
      'https://api.test/api/v1/concerts/1/lineup',
    );
    expect(
      lineup,
      const Lineup(
        teams: [
          LineupTeam(
            concertTeamId: 21,
            lineupOrder: 2,
            isHost: true,
            band: LineupBand(
              bandId: 3,
              name: '소음공장',
              genres: ['ROCK', 'INDIE'],
              memberCount: 4,
            ),
            setlistPreview: ['Creep', '한숨', '나는 나비'],
            setlistTotalCount: 5,
          ),
        ],
        emptySlotCount: 2,
      ),
    );
  });

  test('라인업 변경은 bandIds 전체를 PUT으로 전송한다', () async {
    await repository.saveLineup(2, [7, 3, 12]);
    expect(adapter.request.method, 'PUT');
    expect(adapter.request.path, '/api/v1/concerts/2/lineup');
    expect(adapter.request.data, {
      'bandIds': [7, 3, 12],
    });
  });

  test('셋리스트 응답에서 자작곡 nullable 필드와 검색 곡 재생 링크를 유지한다', () async {
    adapter.data = {
      'isHost': false,
      'canEdit': false,
      'band': _band,
      'songs': [
        {'type': 'ORIGINAL', 'songTitle': '새벽의 노래'},
        {
          'type': 'SEARCHED',
          'trackId': 'abc123',
          'songTitle': 'Wonderwall',
          'artist': 'Oasis',
          'durationSeconds': 258,
          'albumImageUrl': 'https://image.test/album',
          'externalUrl': 'https://music.test/abc123',
        },
      ],
    };
    final setlist = await repository.getSetlist(2, 3);
    expect(adapter.request.path, '/api/v1/concerts/2/teams/3/setlist');
    expect(adapter.request.method, 'GET');
    expect(setlist.canEdit, isFalse);
    expect(setlist.isHost, isFalse);
    expect(setlist.songs, const [
      LineupSong(type: SongType.original, songTitle: '새벽의 노래'),
      LineupSong(
        type: SongType.searched,
        songTitle: 'Wonderwall',
        trackId: 'abc123',
        artist: 'Oasis',
        durationSeconds: 258,
        albumImageUrl: 'https://image.test/album',
        externalUrl: 'https://music.test/abc123',
      ),
    ]);
  });

  test('곡 저장은 순서·중복을 유지하며 자작곡 검색 필드와 externalUrl을 제외한다', () async {
    const searched = LineupSong(
      type: SongType.searched,
      trackId: 'abc123',
      songTitle: 'Wonderwall',
      artist: 'Oasis',
      durationSeconds: 258,
      albumImageUrl: 'https://image.test/album',
      externalUrl: 'https://music.test/abc123',
    );
    await repository.saveSetlist(1, 3, [
      const LineupSong(type: SongType.original, songTitle: '자작곡'),
      const LineupSong(
        type: SongType.original,
        songTitle: '시간 있는 곡',
        durationSeconds: 12,
      ),
      searched,
      searched,
    ]);
    expect(adapter.request.method, 'PUT');
    expect(adapter.request.path, '/api/v1/concerts/1/teams/3/setlist');
    const searchedJson = {
      'type': 'SEARCHED',
      'trackId': 'abc123',
      'songTitle': 'Wonderwall',
      'artist': 'Oasis',
      'durationSeconds': 258,
      'albumImageUrl': 'https://image.test/album',
    };
    expect(adapter.request.data, {
      'songs': [
        {'type': 'ORIGINAL', 'songTitle': '자작곡'},
        {'type': 'ORIGINAL', 'songTitle': '시간 있는 곡', 'durationSeconds': 12},
        searchedJson,
        searchedJson,
      ],
    });
  });

  test('빈 곡 배열로 셋리스트를 비운다', () async {
    await repository.saveSetlist(1, 3, []);
    expect(adapter.request.data, {'songs': <Object>[]});
  });

  test('검색은 keyword를 인코딩하고 type 없는 결과를 searched로 변환한다', () async {
    adapter.data = {
      'songs': [
        {
          'trackId': 'abc123',
          'songTitle': 'Wonderwall',
          'artist': 'Oasis',
          'durationSeconds': 258,
          'albumImageUrl': null,
        },
      ],
    };
    final songs = await repository.searchSongs(' Oasis & rock ');
    expect(adapter.request.method, 'GET');
    expect(adapter.request.uri.path, '/api/v1/songs');
    expect(adapter.request.uri.queryParameters, {'keyword': 'Oasis & rock'});
    expect(songs, const [
      LineupSong(
        type: SongType.searched,
        trackId: 'abc123',
        songTitle: 'Wonderwall',
        artist: 'Oasis',
        durationSeconds: 258,
      ),
    ]);
  });

  test('검색 결과가 없으면 빈 배열이다', () async {
    adapter.data = {'songs': <Object>[]};
    expect(await repository.searchSongs('none'), isEmpty);
  });

  for (final (status, code) in [
    (400, 'COMMON_004'),
    (403, 'AUTH_005'),
    (404, 'CONCERT_001'),
    (404, 'CONCERT_007'),
    (409, 'CONCERT_014'),
    (503, 'CONCERT_013'),
  ]) {
    test('HTTP $status $code 오류를 모든 저장소 진입점에서 보존한다', () async {
      adapter.status = status;
      adapter.code = code;
      for (final operation in [
        () => repository.getLineup(1),
        () => repository.saveLineup(1, [3, 7, 12]),
        () => repository.getSetlist(1, 3),
        () => repository.saveSetlist(1, 3, []),
        () => repository.searchSongs('Oasis'),
      ]) {
        await expectLater(
          operation(),
          throwsA(
            isA<ApiException>()
                .having((error) => error.statusCode, 'statusCode', status)
                .having((error) => error.code, 'code', code),
          ),
        );
      }
    });
  }
}
