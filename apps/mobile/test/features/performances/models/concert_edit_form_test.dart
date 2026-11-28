import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/models/concert_edit_form.dart';
import 'package:highfive/features/performances/models/concert_update.dart';
import 'package:highfive/features/performances/models/recruitment_status.dart';

// 명세 예시 공연 12: 장르 ROCK·INDIE, 날짜 2026-12-20, 시간 미정, 대관비 500,000원,
// 진행 중 공고(마감 2026-12-01, 합류 1팀), version 3.
const _sample = FakeConcertRepository.sample;
final _today = DateTime(2026, 11, 28);

void main() {
  test('손대지 않으면 상세 값을 그대로 보내고 바뀐 항목이 없다', () {
    final form = ConcertEditForm(_sample);

    expect(form.isDirty, isFalse);
    expect(form.validate(today: _today), isEmpty);
    expect(form.toUpdate(), ConcertUpdate.fromDetail(_sample));
    expect(form.changedFields(), isEmpty);
  });

  test('제목·장르만 바꾸면 그 항목만 바뀌고 지역·포스터·version은 원본이다', () {
    final source = _sample.copyWith(
      posterImageUrl: 'https://poster.test/original',
    );
    final form = ConcertEditForm(source)
      ..title = '  새 제목  '
      ..genres.add('METAL');

    expect(form.validate(today: _today), isEmpty);
    final update = form.toUpdate();
    expect(update.title, '새 제목');
    expect(update.genres, ['ROCK', 'INDIE', 'METAL']);
    expect(update.region, _sample.region);
    expect(update.posterImageUrl, source.posterImageUrl);
    expect(update.version, _sample.version);
    expect(form.changedFields(), [
      ConcertEditField.title,
      ConcertEditField.genres,
    ]);
  });

  test('공백만 고치면 입력은 바뀌었지만 보낼 변경은 없다', () {
    final form = ConcertEditForm(_sample)..title = '${_sample.title} ';

    expect(form.isDirty, isTrue);
    expect(form.validate(today: _today), isEmpty);
    expect(form.changedFields(), isEmpty);
  });

  test('주소만 고쳐도 null인 장소명을 강제하지 않고 원문을 따로 보존한다', () {
    final source = _sample.copyWith(place: null, address: '  원래 주소  ');
    final form = ConcertEditForm(source)..address = '새 주소';

    expect(form.validate(today: _today), isEmpty);
    expect(form.toUpdate().place, isNull);
    expect(form.toUpdate().address, '새 주소');

    final nameOnly = ConcertEditForm(source)..place = '새 장소';
    expect(nameOnly.toUpdate().address, source.address);
  });

  test('빈 제목·30자를 넘는 제목·빈 장르를 칸별로 막는다', () {
    expect((ConcertEditForm(_sample)..title = '   ').validate(today: _today), {
      ConcertEditField.title: ConcertEditIssue.empty,
    });
    expect(
      (ConcertEditForm(_sample)..title = '가' * 31).validate(today: _today),
      {ConcertEditField.title: ConcertEditIssue.tooLong},
    );
    expect(
      (ConcertEditForm(_sample)..title = '가' * 30).validate(today: _today),
      isEmpty,
    );
    expect((ConcertEditForm(_sample)..genres.clear()).validate(today: _today), {
      ConcertEditField.genres: ConcertEditIssue.empty,
    });
  });

  test('날짜를 오늘 이전으로 바꾸면 막고, 원래 지난 날짜는 그대로 둘 수 있다', () {
    final past = _sample.copyWith(performDate: '2026-11-01', recruitment: null);

    expect(ConcertEditForm(past).validate(today: _today), isEmpty);
    expect(
      (ConcertEditForm(
        past,
      )..performDate = '2026-11-27').validate(today: _today),
      {ConcertEditField.performDate: ConcertEditIssue.pastDate},
    );
    expect(
      (ConcertEditForm(
        past,
      )..performDate = '2026-11-28').validate(today: _today),
      isEmpty,
    );
  });

  test('진행 중인 모집 공고 마감일보다 이른 날짜는 막고, 마감된 공고는 보지 않는다', () {
    expect(
      (ConcertEditForm(
        _sample,
      )..performDate = '2026-11-30').validate(today: _today),
      {ConcertEditField.performDate: ConcertEditIssue.beforeRecruitDeadline},
    );
    final closed = _sample.copyWith(
      recruitment: _sample.recruitment!.copyWith(
        status: RecruitmentStatus.closed,
      ),
    );
    expect(
      (ConcertEditForm(
        closed,
      )..performDate = '2026-11-30').validate(today: _today),
      isEmpty,
    );
  });

  test('시간 미정을 풀면 두 시간을 HH:mm으로 함께 받아 초를 붙여 보낸다', () {
    ConcertEditForm decided() =>
        ConcertEditForm(_sample)..timeUndecided = false;

    expect(decided().validate(today: _today), {
      ConcertEditField.time: ConcertEditIssue.empty,
    });
    expect((decided()..startTime = '19:00').validate(today: _today), {
      ConcertEditField.time: ConcertEditIssue.timePair,
    });
    expect(
      (decided()
            ..startTime = '25:00'
            ..endTime = '21:00')
          .validate(today: _today),
      {ConcertEditField.time: ConcertEditIssue.timeFormat},
    );
    // 종료 시간은 자정을 넘길 수 있다.
    final crossing = decided()
      ..startTime = '23:00'
      ..endTime = '01:00';
    expect(crossing.validate(today: _today), isEmpty);
    final update = crossing.toUpdate();
    expect((update.startTime, update.endTime), ('23:00:00', '01:00:00'));
    expect(crossing.changedFields(), [ConcertEditField.time]);
  });

  test('원래 시각과 같은 HH:mm은 원래 문자열(초 포함)을 그대로 보낸다', () {
    final timed = _sample.copyWith(startTime: '19:00:30', endTime: '21:00');
    final form = ConcertEditForm(timed);
    expect(
      (form.timeUndecided, form.startTime, form.endTime),
      (false, '19:00', '21:00'),
    );

    form.endTime = '22:00';

    final update = form.toUpdate();
    expect((update.startTime, update.endTime), ('19:00:30', '22:00:00'));
  });

  test('미정으로 바꾸면 null을 보내고, 다시 풀면 적어 둔 값으로 돌아온다', () {
    final form = ConcertEditForm(_sample)
      ..placeUndecided = true
      ..rentalFeeUndecided = true;

    final update = form.toUpdate();
    expect(
      (update.place, update.address, update.rentalFee),
      (null, null, null),
    );
    expect(form.changedFields(), [
      ConcertEditField.place,
      ConcertEditField.address,
      ConcertEditField.rentalFee,
    ]);

    form
      ..placeUndecided = false
      ..rentalFeeUndecided = false;
    expect(form.isDirty, isFalse);
    expect(form.toUpdate(), ConcertUpdate.fromDetail(_sample));
  });

  test('장소명과 주소는 각각 비울 수 있고 각자의 길이 제한을 검사한다', () {
    expect(
      (ConcertEditForm(_sample)..place = ' ').validate(today: _today),
      isEmpty,
    );
    expect((ConcertEditForm(_sample)..place = ' ').toUpdate().place, isNull);
    expect(
      (ConcertEditForm(_sample)..address = '가' * 201).validate(today: _today),
      {ConcertEditField.address: ConcertEditIssue.tooLong},
    );
    expect((ConcertEditForm(_sample)..address = '').toUpdate().address, isNull);
  });

  test('대관비는 비우거나 서버 정수 범위를 넘으면 막는다', () {
    expect((ConcertEditForm(_sample)..rentalFee = '').validate(today: _today), {
      ConcertEditField.rentalFee: ConcertEditIssue.empty,
    });
    expect(
      (ConcertEditForm(
        _sample,
      )..rentalFee = '2147483648').validate(today: _today),
      {ConcertEditField.rentalFee: ConcertEditIssue.rentalFeeFormat},
    );
    expect((ConcertEditForm(_sample)..rentalFee = '0').toUpdate().rentalFee, 0);
  });

  test('이미 합류한 팀 수(주최 팀 제외)보다 적은 모집 팀 수는 막는다', () {
    final joined = _sample.copyWith(
      recruitment: _sample.recruitment!.copyWith(joinedTeamCount: 2),
    );
    final form = ConcertEditForm(joined);

    expect(form.minRecruitTeamCount, 2);
    expect((form..recruitTeamCount = 1).validate(today: _today), {
      ConcertEditField.recruitTeamCount: ConcertEditIssue.belowJoinedTeams,
    });
    expect(
      ConcertEditForm(_sample.copyWith(recruitment: null)).minRecruitTeamCount,
      1,
    );
  });

  test('서울 업무 날짜는 기기 시간대와 상관없이 UTC+9로 계산한다', () {
    expect(
      concertBusinessDate(DateTime.utc(2026, 11, 27, 15)),
      DateTime(2026, 11, 28),
    );
    expect(
      concertBusinessDate(DateTime.utc(2026, 11, 27, 14, 59)),
      DateTime(2026, 11, 27),
    );
  });
}
