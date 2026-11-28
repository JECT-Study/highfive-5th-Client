import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/data/dto/concert_participants_dto.dart';
import 'package:highfive/features/performances/models/concert_participant.dart';
import 'package:json_annotation/json_annotation.dart';

/// 라인업 조회 초안(JECT-228) 응답 예시의 `data`. 미리보기가 읽지 않는 필드도 원문대로 둔다.
Map<String, dynamic> _data() => {
  'teams': [
    <String, dynamic>{
      'concertTeamId': 21,
      'lineupOrder': 1,
      'isHost': true,
      'band': <String, dynamic>{
        'bandId': 3,
        'name': '새벽세시',
        'profileImageUrl': 'https://...',
        'genres': ['ROCK', 'INDIE'],
        'memberCount': 4,
      },
      'setlistPreview': ['Creep', '한숨', '나는 나비'],
      'setlistTotalCount': 5,
    },
  ],
  'emptySlotCount': 2,
};

Map<String, dynamic> _team(Map<String, dynamic> data) =>
    (data['teams'] as List).first as Map<String, dynamic>;

void main() {
  test('라인업 응답의 참여 밴드 표시 값을 공연 순서대로 옮긴다', () {
    final data = _data();
    (data['teams'] as List).add({
      'concertTeamId': 22,
      'lineupOrder': 2,
      'isHost': false,
      'band': {
        'bandId': 7,
        'name': '오프비트',
        'profileImageUrl': null,
        'genres': ['PUNK'],
        'memberCount': 3,
      },
      'setlistPreview': <String>[],
      'setlistTotalCount': 0,
    });

    final participants = ConcertParticipantsDto.fromJson(data).toModel();

    expect(participants, const [
      ConcertParticipant(
        bandId: 3,
        name: '새벽세시',
        isHost: true,
        profileImageUrl: 'https://...',
        genres: ['ROCK', 'INDIE'],
        memberCount: 4,
      ),
      ConcertParticipant(
        bandId: 7,
        name: '오프비트',
        isHost: false,
        profileImageUrl: null,
        genres: ['PUNK'],
        memberCount: 3,
      ),
    ]);
  });

  test('참여 팀이 없으면 빈 목록이다', () {
    final data = _data()..['teams'] = <Object>[];

    expect(ConcertParticipantsDto.fromJson(data).toModel(), isEmpty);
  });

  test('주최 여부·밴드·밴드 ID·이름이 없으면 기본값으로 채우지 않고 실패한다', () {
    final breaks = <void Function(Map<String, dynamic> team)>[
      (team) => team.remove('isHost'),
      (team) => team['isHost'] = null,
      (team) => team.remove('band'),
      (team) => (team['band'] as Map).remove('bandId'),
      (team) => (team['band'] as Map).remove('name'),
    ];
    for (final (index, breakTeam) in breaks.indexed) {
      final data = _data();
      breakTeam(_team(data));

      expect(
        () => ConcertParticipantsDto.fromJson(data),
        throwsA(isA<TypeError>()),
        reason: '$index',
      );
    }
  });

  test('소수 밴드 ID는 잘라 쓰지 않고 실패한다', () {
    final data = _data();
    (_team(data)['band'] as Map)['bandId'] = 3.5;

    expect(
      () => ConcertParticipantsDto.fromJson(data),
      throwsA(isA<TypeError>()),
    );
  });

  test('기존 최소 projection은 인원 미상을 0명으로 채우지 않는다', () {
    const participant = ConcertParticipant(bandId: 3, name: '밴드', isHost: true);
    expect(participant.memberCount, isNull);
    expect(participant.genres, isEmpty);
    expect(participant.profileImageUrl, isNull);
  });

  test('wire 표시 필드가 빠지면 최소 projection 기본값으로 감추지 않는다', () {
    for (final field in ['profileImageUrl', 'genres', 'memberCount']) {
      final data = _data();
      (_team(data)['band'] as Map).remove(field);

      expect(
        () => ConcertParticipantsDto.fromJson(data),
        throwsA(isA<MissingRequiredKeysException>()),
        reason: field,
      );
    }
  });

  test('장르·인원 null과 소수 인원은 거부한다', () {
    for (final field in ['genres', 'memberCount']) {
      final data = _data();
      (_team(data)['band'] as Map)[field] = null;
      expect(
        () => ConcertParticipantsDto.fromJson(data),
        throwsA(isA<DisallowedNullValueException>()),
        reason: field,
      );
    }
    final data = _data();
    (_team(data)['band'] as Map)['memberCount'] = 4.5;
    expect(
      () => ConcertParticipantsDto.fromJson(data),
      throwsA(isA<TypeError>()),
    );
  });

  test('돌려준 목록은 바꿀 수 없다', () {
    final participants = ConcertParticipantsDto.fromJson(_data()).toModel();

    expect(
      () => participants.add(
        const ConcertParticipant(bandId: 1, name: '추가', isHost: false),
      ),
      throwsUnsupportedError,
    );
    expect(() => participants.first.genres.add('POP'), throwsUnsupportedError);
  });
}
