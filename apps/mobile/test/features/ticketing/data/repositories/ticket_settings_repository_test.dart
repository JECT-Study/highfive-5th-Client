import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/ticketing/data/repositories/ticket_settings_repository.dart';
import 'package:highfive/features/ticketing/models/ticket_role.dart';
import 'package:highfive/features/ticketing/models/ticket_schedule.dart';
import 'package:highfive/features/ticketing/models/ticket_settings.dart';

import '../../settings_fixture.dart';

TicketSettingsRepository _repository({
  TicketRole role = TicketRole.organizer,
  String actorId = 'demo-host',
}) => TicketSettingsRepository(
  role: role,
  concert: TicketSettingsConcert.demo,
  actorId: actorId,
  now: () => settingsNow,
);

void main() {
  for (final unit in ['\u1100\u1161', '👩‍👩‍👧‍👦']) {
    test('한글 결합 문자와 이모지의 표시 글자 수 200/201 경계를 검증한다: $unit', () {
      final repository = _repository();
      final draft = validTicketSettings().copyWith(
        introduction: unit * 200,
        precautions: unit * 200,
      );
      final saved = repository.save(draft);
      expect(saved.draft.introduction, unit * 200);
      expect(saved.draft.precautions, unit * 200);
      for (final (invalid, field) in [
        (
          draft.copyWith(introduction: unit * 201),
          TicketSettingsField.introduction,
        ),
        (
          draft.copyWith(precautions: unit * 201),
          TicketSettingsField.precautions,
        ),
      ]) {
        expect(
          () => repository.save(invalid),
          throwsA(
            isA<TicketSettingsFailure>().having(
              (error) => error.errors.keys,
              'invalid field',
              contains(field),
            ),
          ),
        );
        expect(repository.read(), same(saved));
      }
    });
  }
  test('소개와 유의사항은 표시 글자 수 200자까지 저장하고 초과는 보존 없이 거부한다', () {
    final draft = validTicketSettings().copyWith(
      introduction: '${'가' * 199}🎵',
      precautions: '나' * 200,
      refundPolicy: '${'다' * 999}🎵',
    );
    final repository = _repository();
    final saved = repository.save(draft);
    expect(saved.draft.introduction, draft.introduction);
    expect(saved.draft.precautions, draft.precautions);
    for (final invalid in [
      draft.copyWith(introduction: '${draft.introduction}가'),
      draft.copyWith(precautions: '${draft.precautions}나'),
    ]) {
      expect(
        () => repository.save(invalid),
        throwsA(isA<TicketSettingsFailure>()),
      );
      expect(repository.read(), same(saved));
    }
  });

  test('자유 문구의 계좌 연락처 외부 주소 형태를 저장 경계에서 차단한다', () {
    for (final text in [
      '000-0000-0000',
      '000.0000.0000',
      '000/0000/0000',
      '000000000000',
      'demo@example.invalid',
      'https://example.invalid',
    ]) {
      for (final draft in [
        validTicketSettings().copyWith(refundPolicy: text),
        validTicketSettings().copyWith(introduction: text),
        validTicketSettings().copyWith(precautions: text),
      ]) {
        final repository = _repository();
        expect(
          () => repository.save(draft),
          throwsA(isA<TicketSettingsFailure>()),
        );
        expect(repository.read(), isNull);
      }
    }
  });

  test('같은 저장 범위의 후발 폼이 먼저 확정된 일정을 덮어쓰지 않는다', () {
    final store = TicketSettingsStore((
      concertId: ticketPreviewConcertId,
      actorId: ticketPreviewActorId,
      role: TicketRole.organizer,
    ));
    TicketSettingsRepository open() => TicketSettingsRepository(
      role: TicketRole.organizer,
      concert: TicketSettingsConcert.demo,
      actorId: ticketPreviewActorId,
      now: () => settingsNow,
      store: store,
    );
    final first = open();
    final second = open();
    final saved = first.save(validTicketSettings());
    expect(
      second.save(
        validTicketSettings().copyWith(
          registrationClosesAt: DateTime(2027, 1, 10),
        ),
      ),
      same(saved),
    );
    expect(
      first.readSchedule()?.registrationClosesAt,
      DateTime(2027, 1, 12, 18),
    );
  });
  test('저장된 마감과 공연 시간을 J162 일정 인터페이스로 읽는다', () {
    final repository = _repository();
    final TicketScheduleSource source = repository;
    expect(source.readSchedule(), isNull);

    repository.save(validTicketSettings());

    final schedule = source.readSchedule()!;
    expect(schedule.registrationClosesAt, DateTime(2027, 1, 12, 18));
    expect(schedule.performanceStartsAt, DateTime(2027, 1, 12, 19));
    expect(schedule.performanceEndsAt, DateTime(2027, 1, 12, 21));
    expect(schedule.refundClosesAt, DateTime(2027, 1, 11, 23, 59));
  });

  for (final role in [
    TicketRole.accountOwner,
    TicketRole.member,
    TicketRole.outsider,
  ]) {
    test('$role은 저장소 읽기와 쓰기를 직접 호출해도 거부된다', () {
      final repository = _repository(role: role);
      final denied = isA<TicketSettingsFailure>().having(
        (e) => e.denied,
        'denied',
        isTrue,
      );
      expect(repository.read, throwsA(denied));
      expect(() => repository.save(validTicketSettings()), throwsA(denied));
    });
  }

  test('주최자 역할이라도 허용되지 않은 행위자는 거부된다', () {
    final repository = _repository(actorId: 'demo-guest');
    expect(
      () => repository.save(validTicketSettings()),
      throwsA(
        isA<TicketSettingsFailure>().having((e) => e.denied, 'denied', true),
      ),
    );
  });

  test('저장소 인스턴스 간에 저장한 설정이 새지 않는다', () {
    final first = _repository()..save(validTicketSettings());
    final second = _repository();

    expect(second.read(), isNull);
    expect(first.read()?.draft.price, '15000');
  });

  test('고정 합성 공연 밖에서는 주최자도 읽기와 쓰기를 거부한다', () {
    final repository = TicketSettingsRepository(
      role: TicketRole.organizer,
      concert: TicketSettingsConcert.demo,
      concertId: 'different-concert',
      actorId: ticketPreviewActorId,
      now: () => settingsNow,
    );
    expect(repository.read, throwsA(isA<TicketSettingsFailure>()));
    expect(
      () => repository.save(validTicketSettings()),
      throwsA(isA<TicketSettingsFailure>()),
    );
  });

  test('범위를 닫으면 이전 일정 인터페이스와 저장 명령을 무효화한다', () {
    final repository = _repository()..save(validTicketSettings());
    final TicketScheduleSource source = repository;
    repository.close();

    expect(source.readSchedule, throwsA(isA<TicketSettingsFailure>()));
    expect(
      () => repository.save(validTicketSettings()),
      throwsA(isA<TicketSettingsFailure>()),
    );
  });

  test('경로 핸들을 폐기해도 같은 dev 메모리에서 재진입하면 저장 일정을 복원한다', () {
    final store = TicketSettingsStore((
      concertId: ticketPreviewConcertId,
      actorId: ticketPreviewActorId,
      role: TicketRole.organizer,
    ));
    TicketSettingsRepository open() => TicketSettingsRepository(
      role: TicketRole.organizer,
      concert: TicketSettingsConcert.demo,
      actorId: ticketPreviewActorId,
      now: () => settingsNow,
      store: store,
    );
    final first = open()..save(validTicketSettings());
    first.close();

    final reopened = open();

    expect(
      reopened.readSchedule()?.registrationClosesAt,
      DateTime(2027, 1, 12, 18),
    );
    expect(first.readSchedule, throwsA(isA<TicketSettingsFailure>()));
  });

  test('다른 공연의 메모리 저장소를 주입해도 권한 경계에서 거부한다', () {
    final store = TicketSettingsStore((
      concertId: 'different-concert',
      actorId: ticketPreviewActorId,
      role: TicketRole.organizer,
    ));
    final repository = TicketSettingsRepository(
      role: TicketRole.organizer,
      concert: TicketSettingsConcert.demo,
      actorId: ticketPreviewActorId,
      now: () => settingsNow,
      store: store,
    );

    expect(
      () => repository.save(validTicketSettings()),
      throwsA(isA<TicketSettingsFailure>()),
    );
  });

  final valid = validTicketSettings();
  for (final (name, draft, field) in [
    ('음수 가격', valid.copyWith(price: '-1'), TicketSettingsField.price),
    ('소수 가격', valid.copyWith(price: '1.5'), TicketSettingsField.price),
    ('정수 범위 초과', valid.copyWith(price: '1000001'), TicketSettingsField.price),
    ('수량 0', valid.copyWith(capacity: '0'), TicketSettingsField.capacity),
    (
      '수량 상한 초과',
      valid.copyWith(capacity: '10001'),
      TicketSettingsField.capacity,
    ),
    (
      '지난 공연 시작',
      valid.copyWith(performanceStartsAt: settingsNow),
      TicketSettingsField.performanceStartsAt,
    ),
    (
      '지난 신청 마감',
      valid.copyWith(registrationClosesAt: settingsNow),
      TicketSettingsField.registrationClosesAt,
    ),
    (
      '공연 이후 신청 마감',
      valid.copyWith(registrationClosesAt: DateTime(2027, 1, 12, 20)),
      TicketSettingsField.registrationClosesAt,
    ),
    (
      '공연 이후 환불 마감',
      valid.copyWith(refundClosesAt: DateTime(2027, 1, 12, 20)),
      TicketSettingsField.refundClosesAt,
    ),
    (
      '지난 환불 마감',
      valid.copyWith(refundClosesAt: settingsNow),
      TicketSettingsField.refundClosesAt,
    ),
    (
      '종료가 시작과 동일',
      valid.copyWith(performanceEndsAt: DateTime(2027, 1, 12, 19)),
      TicketSettingsField.performanceEndsAt,
    ),
    (
      '빈 환불 규정',
      valid.copyWith(refundPolicy: '  '),
      TicketSettingsField.refundPolicy,
    ),
  ]) {
    test('$name 저장을 차단하고 이전 저장값을 보존한다', () {
      final repository = _repository()..save(valid);

      expect(
        () => repository.save(draft),
        throwsA(
          isA<TicketSettingsFailure>().having(
            (e) => e.errors.containsKey(field),
            'field',
            isTrue,
          ),
        ),
      );
      expect(repository.read()?.draft, same(valid));
    });
  }

  test('무료 가격과 공연 시작 시각까지인 마감을 허용한다', () {
    final repository = _repository();
    final saved = repository.save(
      valid.copyWith(
        price: '0',
        registrationClosesAt: DateTime(2027, 1, 12, 19),
        refundClosesAt: DateTime(2027, 1, 12, 19),
      ),
    );
    expect(saved.draft.price, '0');
  });

  test('계좌와 문의 채널을 선택하지 않은 초안은 저장되지 않는다', () {
    final repository = _repository();
    expect(
      () => repository.save(const TicketSettingsDraft()),
      throwsA(
        isA<TicketSettingsFailure>().having(
          (e) => e.errors.keys,
          'missing choices',
          containsAll([
            TicketSettingsField.account,
            TicketSettingsField.contact,
          ]),
        ),
      ),
    );
    expect(repository.read(), isNull);
  });
}
