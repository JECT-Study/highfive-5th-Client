import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/performances/data/repositories/concert_participants_repository.dart';
import 'package:highfive/features/performances/data/repositories/concert_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_management_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/models/concert_detail.dart';
import 'package:highfive/features/performances/models/concert_participant.dart';
import 'package:highfive/features/performances/models/concert_status.dart';
import 'package:highfive/features/performances/models/concert_management_failure.dart';

class _Roster implements ConcertParticipantsRepository {
  @override
  Future<List<ConcertParticipant>> fetchParticipants(int concertId) async =>
      const [
        ConcertParticipant(bandId: 3, name: '주최', isHost: true),
        ConcertParticipant(bandId: 4, name: '참여', isHost: false),
      ];
}

class _Details implements ConcertRepository {
  ConcertDetail value = FakeConcertRepository.sample.copyWith(
    myPermissions: const ConcertPermissions(
      isHostLeader: true,
      isTeamLeader: true,
    ),
  );

  @override
  Future<ConcertDetail> fetchDetail(int concertId) async => value;
}

Matcher _code(String code) =>
    isA<ApiException>().having((error) => error.code, 'code', code);

class _PendingRoster implements ConcertParticipantsRepository {
  final response = Completer<List<ConcertParticipant>>();

  @override
  Future<List<ConcertParticipant>> fetchParticipants(int concertId) =>
      response.future;
}

Future<String?> _outcome(Future<void> command) async {
  try {
    await command;
    return null;
  } on ApiException catch (error) {
    return error.code;
  }
}

void main() {
  test('참여 밴드 조회 도중 삭제된 공연의 늦은 목록은 반환하지 않는다', () async {
    final roster = _PendingRoster();
    final repository = FakeConcertManagementRepository(_Details(), roster);
    final read = repository.fetchParticipants(12);
    final result = expectLater(read, throwsA(_code('CONCERT_001')));
    await repository.deleteConcert(12);

    roster.response.complete(await _Roster().fetchParticipants(12));

    await result;
  });

  test('같은 공연 동시 삭제는 하나만 성공하고 다른 요청은 공연 없음이다', () async {
    final repository = FakeConcertManagementRepository(_Details(), _Roster());

    final results = await Future.wait([
      _outcome(repository.deleteConcert(12)),
      _outcome(repository.deleteConcert(12)),
    ]);

    expect(results, unorderedEquals([null, 'CONCERT_001']));
  });

  test('같은 밴드 동시 빼기는 하나만 성공하고 다른 요청은 참여 밴드 없음이다', () async {
    final repository = FakeConcertManagementRepository(_Details(), _Roster());

    final results = await Future.wait([
      _outcome(repository.removeBand(12, 4)),
      _outcome(repository.removeBand(12, 4)),
    ]);

    expect(results, unorderedEquals([null, 'CONCERT_007']));
  });

  test('밴드 조회 도중 회수된 권한은 최종 빼기 시점에도 검사한다', () async {
    final details = _Details();
    final roster = _PendingRoster();
    final repository = FakeConcertManagementRepository(details, roster);
    final command = repository.removeBand(12, 4);
    details.value = FakeConcertRepository.sample;
    roster.response.complete(await _Roster().fetchParticipants(12));

    await expectLater(command, throwsA(_code('AUTH_005')));
  });

  test('세션이 끝난 뒤 늦게 도착한 조회로 삭제를 확정하지 않는다', () async {
    final roster = _PendingRoster();
    final repository = FakeConcertManagementRepository(_Details(), roster);
    final command = repository.removeBand(12, 4);
    final result = expectLater(command, throwsA(_code('AUTH_005')));

    repository.endSession();
    roster.response.complete(await _Roster().fetchParticipants(12));
    await result;

    expect(repository.active, isFalse);
  });

  test('밴드 빼기 뒤 목록과 모집 현황은 다시 읽어도 복원되지 않는다', () async {
    final repository = FakeConcertManagementRepository(_Details(), _Roster());

    await repository.removeBand(12, 4);

    expect(
      (await repository.fetchParticipants(12)).map((team) => team.bandId),
      [3],
    );
    expect((await repository.fetchDetail(12)).recruitment!.joinedTeamCount, 0);
    await expectLater(
      repository.removeBand(12, 4),
      throwsA(_code('CONCERT_007')),
    );
  });

  test('공연 삭제 뒤 상세와 참가자를 다시 읽어도 공연 없음이다', () async {
    final repository = FakeConcertManagementRepository(_Details(), _Roster());

    await repository.deleteConcert(12);

    await expectLater(
      repository.fetchDetail(12),
      throwsA(_code('CONCERT_001')),
    );
    await expectLater(
      repository.fetchParticipants(12),
      throwsA(_code('CONCERT_001')),
    );
    await expectLater(
      repository.deleteConcert(12),
      throwsA(_code('CONCERT_001')),
    );
  });

  test('주최 밴드와 존재하지 않는 밴드 삭제는 거부하고 목록을 보존한다', () async {
    final repository = FakeConcertManagementRepository(_Details(), _Roster());

    await expectLater(
      repository.removeBand(12, 3),
      throwsA(_code('CONCERT_008')),
    );
    await expectLater(
      repository.removeBand(12, 99),
      throwsA(_code('CONCERT_007')),
    );

    expect(
      (await repository.fetchParticipants(12)).map((team) => team.bandId),
      [3, 4],
    );
  });

  test('조회 뒤 권한이 회수되면 fake도 최종 명령을 거부한다', () async {
    final details = _Details();
    final repository = FakeConcertManagementRepository(details, _Roster());
    await repository.fetchDetail(12);
    details.value = FakeConcertRepository.sample;

    await expectLater(repository.deleteConcert(12), throwsA(_code('AUTH_005')));
    await expectLater(repository.removeBand(12, 4), throwsA(_code('AUTH_005')));

    expect(await repository.fetchParticipants(12), hasLength(2));
  });

  for (final status in [
    ConcertStatus.selling,
    ConcertStatus.salePaused,
    ConcertStatus.saleClosed,
    ConcertStatus.unknown,
  ]) {
    test('$status 공연 삭제는 fake에서도 거부한다', () async {
      final details = _Details();
      details.value = details.value.copyWith(status: status);
      final repository = FakeConcertManagementRepository(details, _Roster());

      await expectLater(
        repository.deleteConcert(12),
        throwsA(
          status == ConcertStatus.unknown
              ? ConcertManagementFailure.unknownStatus
              : _code('CONCERT_009'),
        ),
      );

      expect((await repository.fetchDetail(12)).status, status);
    });
  }
}
