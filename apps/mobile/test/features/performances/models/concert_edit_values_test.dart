import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/models/concert_edit_values.dart';

import '../edit_fixture.dart';

void main() {
  test('해외 기기에서도 서울 자정 경계로 변경 날짜를 검증한다', () {
    final snapshot = editSnapshot();
    final form = ConcertEditForm(snapshot.values)..performDate = '2026-11-26';
    final beforeMidnight = concertBusinessDate(
      DateTime.parse('2026-11-26T14:59:59Z'),
    );
    final afterMidnight = concertBusinessDate(
      DateTime.parse('2026-11-26T15:00:00Z'),
    );
    expect(form.validate(snapshot, today: beforeMidnight), isEmpty);
    expect(form.validate(snapshot, today: afterMidnight).keys, ['performDate']);
    expect(
      concertBusinessDate(DateTime.parse('2026-11-26T08:00:00-07:00')),
      afterMidnight,
    );
  });

  for (final field in editJson().keys) {
    test('전체 교체 원본에서 $field 키가 없으면 null로 추측하지 않는다', () {
      final incomplete = editJson()..remove(field);
      expect(() => ConcertEditValues.fromJson(incomplete), throwsA(anything));
    });
  }

  for (final version in <Object?>[
    null,
    '7',
    7.5,
    <String, Object?>{},
    <Object?>[],
  ]) {
    test('누락되거나 잘못된 version을 기본값·반올림으로 보정하지 않는다 ($version)', () {
      final malformed = editJson()..['version'] = version;
      expect(() => ConcertEditValues.fromJson(malformed), throwsA(anything));
    });
  }

  for (final optional in [true, false]) {
    test('제목만 바꾸면 선택값·초·숨은 필드·버전이 그대로 보존된다 ($optional)', () {
      final source = editJson(optional: optional);
      final original = ConcertEditValues.fromJson(source);
      final form = ConcertEditForm(original)..title = '변경 제목';

      expect(form.replace(original).toJson(), {...source, 'title': '변경 제목'});
    });
  }

  test('미정으로 지운 선택값도 키를 생략하지 않고 null로 전송한다', () {
    final original = editSnapshot().values;
    final form = ConcertEditForm(original)
      ..performDate = null
      ..startTime = null
      ..endTime = null
      ..place = ''
      ..address = ''
      ..rentalFee = '';

    expect(form.replace(original).toJson(), {
      ...editJson(),
      'performDate': null,
      'startTime': null,
      'endTime': null,
      'place': null,
      'address': null,
      'rentalFee': null,
    });
  });

  final invalidCases = <({String field, void Function(ConcertEditForm) edit})>[
    (field: 'title', edit: (f) => f.title = ' '),
    (field: 'title', edit: (f) => f.title = List.filled(31, '가').join()),
    (field: 'genres', edit: (f) => f.genres = []),
    (field: 'genres', edit: (f) => f.genres = ['UNCONFIRMED']),
    (field: 'recruitTeamCount', edit: (f) => f.recruitTeamCount = '1'),
    (field: 'recruitTeamCount', edit: (f) => f.recruitTeamCount = '0'),
    (field: 'recruitTeamCount', edit: (f) => f.recruitTeamCount = '2147483648'),
    (field: 'recruitTeamCount', edit: (f) => f.recruitTeamCount = '1.5'),
    (field: 'performDate', edit: (f) => f.performDate = '2026-11-25'),
    (field: 'performDate', edit: (f) => f.performDate = '2027-02-30'),
    (field: 'startTime', edit: (f) => f.startTime = null),
    (field: 'startTime', edit: (f) => f.endTime = '24:00:00'),
    (field: 'place', edit: (f) => f.place = List.filled(101, '가').join()),
    (field: 'address', edit: (f) => f.address = List.filled(201, '가').join()),
    (field: 'rentalFee', edit: (f) => f.rentalFee = '-1'),
    (field: 'rentalFee', edit: (f) => f.rentalFee = '2147483648'),
    (field: 'rentalFee', edit: (f) => f.rentalFee = '10.5'),
  ];
  for (final (index, row) in invalidCases.indexed) {
    test('잘못된 ${row.field} 입력을 필드 오류로 차단한다 ($index)', () {
      final snapshot = editSnapshot();
      final form = ConcertEditForm(snapshot.values);
      row.edit(form);

      expect(form.validate(snapshot, today: DateTime(2026, 11, 26)).keys, [
        row.field,
      ]);
    });
  }

  test('지난 공연 날짜 유지와 기존 장르 코드는 허용하고 오늘 날짜 변경도 허용한다', () {
    final snapshot = editSnapshot();
    final form = ConcertEditForm(snapshot.values);
    expect(form.validate(snapshot, today: DateTime(2026, 11, 26)), isEmpty);
    form.performDate = '2026-11-26';
    expect(form.validate(snapshot, today: DateTime(2026, 11, 26)), isEmpty);
  });

  test('가변 목록을 전달해도 원본 전체 값이 나중에 바뀌지 않는다', () {
    final genres = ['ROCK'];
    final source = editJson()..['genres'] = genres;
    final values = ConcertEditValues.fromJson(source);
    genres.clear();

    expect(values.genres, ['ROCK']);
  });
}
