import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/models/concert_draft.dart';

void main() {
  final today = DateTime(2026, 11, 26, 18);
  const options = [ConcertGenre(code: 'SERVER_GENRE', name: '서버 장르')];

  Map<String, String> errors(ConcertDraft draft) =>
      draft.validate(today: today, availableGenres: options);

  test('미정 입력은 null이고 주최 밴드와 모집 팀 수는 구분해서 전송한다', () {
    const draft = ConcertDraft(
      title: ' 겨울 공연 ',
      genres: {'SERVER_GENRE'},
      recruitTeamCount: 3,
    );

    expect(errors(draft), isEmpty);
    expect(draft.toJson(HostBand(id: 41, name: '주최 팀')), {
      'bandId': 41,
      'title': '겨울 공연',
      'genres': ['SERVER_GENRE'],
      'recruitTeamCount': 3,
      'performDate': null,
      'startTime': null,
      'endTime': null,
      'place': null,
      'address': null,
      'rentalFee': null,
      'posterImageUrl': null,
    });
  });

  test('오늘 공연과 자정을 넘기는 시간 및 무료 대관비를 허용한다', () {
    final draft = ConcertDraft(
      title: '공연',
      genres: {'SERVER_GENRE'},
      recruitTeamCount: 1,
      performDate: DateTime(2026, 11, 26),
      startTime: const ConcertTime(23, 30),
      endTime: const ConcertTime(1, 0),
      rentalFeeText: '0',
    );

    expect(errors(draft), isEmpty);
    final json = draft.toJson(HostBand(id: 41, name: '주최 팀'));
    expect(json['performDate'], '2026-11-26');
    expect(json['startTime'], '23:30:00');
    expect(json['endTime'], '01:00:00');
    expect(json['rentalFee'], 0);
    expect(json.containsKey('region'), isFalse);
    expect(json.containsKey('customGenre'), isFalse);
  });

  test('필수값과 서버 코드 및 길이·날짜·시간·금액 경계를 검사한다', () {
    final cases = <(ConcertDraft, Set<String>)>[
      (
        ConcertDraft(
          title: '가' * 31,
          genres: const {},
          recruitTeamCount: 0,
          performDate: DateTime(2026, 11, 25),
          startTime: const ConcertTime(19, 0),
          place: '가' * 101,
          address: '가' * 201,
          rentalFeeText: '-1',
        ),
        {
          'title',
          'genres',
          'recruitTeamCount',
          'performDate',
          'startTime',
          'place',
          'address',
          'rentalFee',
        },
      ),
      (
        const ConcertDraft(
          title: ' ',
          genres: {'INVENTED'},
          recruitTeamCount: 1,
          rentalFeeText: '2147483648',
        ),
        {'title', 'genres', 'rentalFee'},
      ),
      (
        const ConcertDraft(
          title: '공연',
          genres: {'SERVER_GENRE'},
          recruitTeamCount: 1,
          endTime: ConcertTime(24, 0),
          rentalFeeText: '1.5',
        ),
        {'startTime', 'rentalFee'},
      ),
    ];
    for (final (draft, fields) in cases) {
      expect(errors(draft).keys.toSet(), fields);
    }
    expect(
      errors(
        ConcertDraft(
          title: '가' * 30,
          genres: const {'SERVER_GENRE'},
          recruitTeamCount: 1,
          place: '가' * 100,
          address: '가' * 200,
          rentalFeeText: '2147483647',
        ),
      ),
      isEmpty,
    );
  });
}
