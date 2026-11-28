import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_management_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_participants_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/models/concert_detail.dart';
import 'package:highfive/features/performances/models/concert_management_failure.dart';
import 'package:highfive/features/performances/models/concert_status.dart';
import 'package:highfive/features/performances/models/concert_participant.dart';
import 'package:highfive/features/performances/presentation/providers/concert_detail_providers.dart';
import 'package:highfive/features/performances/presentation/providers/concert_management_providers.dart';
import 'package:highfive/features/performances/presentation/providers/concert_participants_providers.dart';
import 'package:highfive/features/performances/presentation/view_models/concert_management_view_model.dart';

final _host = FakeConcertRepository.sample.copyWith(
  myPermissions: const ConcertPermissions(
    isHostLeader: true,
    isTeamLeader: true,
  ),
);

class _Commands extends FakeConcertManagementRepository {
  _Commands()
    : super(
        FakeConcertRepository(concerts: [_host]),
        FakeConcertParticipantsRepository(),
      );
  final pending = Completer<void>();
  int writes = 0;

  @override
  Future<void> deleteConcert(int concertId) {
    writes++;
    return pending.future;
  }

  @override
  Future<void> removeBand(int concertId, int bandId) {
    writes++;
    return pending.future;
  }
}

Future<ProviderContainer> _container(
  ConcertDetail detail,
  _Commands commands, {
  Future<List<ConcertParticipant>> Function()? participantsRead,
}) async {
  final container = ProviderContainer(
    overrides: [
      if (participantsRead != null)
        concertParticipantsProvider(12)
            .overrideWith((ref) => participantsRead()),
      concertRepositoryProvider.overrideWithValue(
        FakeConcertRepository(concerts: [detail]),
      ),
      concertManagementRepositoryProvider.overrideWithValue(commands),
    ],
  );
  addTearDown(container.dispose);
  container.listen(concertDetailProvider(12), (_, _) {});
  container.listen(concertManagementViewModelProvider(12), (_, _) {});
  await container.read(concertDetailProvider(12).future);
  return container;
}

void main() {
  test('이미 빠졌다는 응답 뒤 새 명단에 같은 밴드가 돌아오면 임시 차단을 푼다', () async {
    final commands = _Commands();
    final response = Completer<List<ConcertParticipant>>();
    final container = await _container(
      _host,
      commands,
      participantsRead: () => response.future,
    );
    final subscription = container.listen(
      concertParticipantsProvider(12),
      (_, _) {},
    );
    addTearDown(subscription.close);
    final model = container.read(
      concertManagementViewModelProvider(12).notifier,
    );
    final first = model.removeBand(4);
    commands.pending.completeError(
      const ApiException(statusCode: 404, code: 'CONCERT_007'),
    );
    await first;
    expect(
      container.read(concertManagementViewModelProvider(12)).removedBandIds,
      {4},
    );

    response.complete(const [
      ConcertParticipant(bandId: 3, name: '주최', isHost: true),
      ConcertParticipant(bandId: 4, name: '재합류', isHost: false),
    ]);
    await container.read(concertParticipantsProvider(12).future);

    expect(
      container.read(concertManagementViewModelProvider(12)).removedBandIds,
      isEmpty,
    );
    await model.removeBand(4);
    expect(commands.writes, 2);
  });

  test('서버가 이미 빠진 밴드라고 하면 재조회 전 같은 명령을 반복하지 않는다', () async {
    final commands = _Commands();
    final container = await _container(_host, commands);
    final model = container.read(
      concertManagementViewModelProvider(12).notifier,
    );
    final first = model.removeBand(4);
    commands.pending.completeError(
      const ApiException(statusCode: 404, code: 'CONCERT_007'),
    );
    await first;

    await model.removeBand(4);

    expect(commands.writes, 1);
    expect(
      container.read(concertManagementViewModelProvider(12)).removedBandIds,
      {4},
    );
  });

  test('빼기 성공 후 목록 갱신 전 직접 다시 호출해도 같은 밴드는 다시 쓰지 않는다', () async {
    final commands = _Commands();
    final container = await _container(_host, commands);
    final model = container.read(
      concertManagementViewModelProvider(12).notifier,
    );
    final first = model.removeBand(4);
    commands.pending.complete();
    await first;

    await model.removeBand(4);

    expect(commands.writes, 1);
    expect(
      container.read(concertManagementViewModelProvider(12)).removedBandIds,
      {4},
    );
  });

  test('계정이 바뀐 프레임 전에 도착한 삭제 응답도 화면 결과로 전달하지 않는다', () async {
    final commands = _Commands();
    final container = await _container(_host, commands);
    final model = container.read(
      concertManagementViewModelProvider(12).notifier,
    );
    final first = model.deleteConcert(owner: Object());

    commands.endSession();
    commands.pending.complete();
    await first;

    expect(
      container.read(concertManagementViewModelProvider(12)).deleted,
      isFalse,
    );
  });

  for (final permissions in [
    const ConcertPermissions(isHostLeader: false, isTeamLeader: false),
    const ConcertPermissions(isHostLeader: false, isTeamLeader: true),
  ]) {
    test('주최 대표자가 아니면 직접 명령을 호출해도 삭제·밴드 빼기를 보내지 않는다 $permissions', () async {
      final commands = _Commands();
      final container = await _container(
        _host.copyWith(myPermissions: permissions),
        commands,
      );
      final model = container.read(
        concertManagementViewModelProvider(12).notifier,
      );

      await model.deleteConcert();
      await model.removeBand(4);

      expect(commands.writes, 0);
      expect(
        container.read(concertManagementViewModelProvider(12)).failure,
        ConcertManagementFailure.forbidden,
      );
    });
  }

  test('주최 밴드는 직접 빼기를 호출해도 요청하지 않는다', () async {
    final commands = _Commands();
    final container = await _container(_host, commands);

    await container
        .read(concertManagementViewModelProvider(12).notifier)
        .removeBand(3);

    expect(commands.writes, 0);
    expect(
      container.read(concertManagementViewModelProvider(12)).failure,
      ConcertManagementFailure.hostBand,
    );
  });

  for (final status in [
    ConcertStatus.selling,
    ConcertStatus.salePaused,
    ConcertStatus.saleClosed,
    ConcertStatus.unknown,
  ]) {
    test('$status 상태는 삭제 요청을 보내지 않는다', () async {
      final commands = _Commands();
      final container = await _container(
        _host.copyWith(status: status),
        commands,
      );

      await container
          .read(concertManagementViewModelProvider(12).notifier)
          .deleteConcert();

      expect(commands.writes, 0);
      expect(
        container.read(concertManagementViewModelProvider(12)).failure,
        status == ConcertStatus.unknown
            ? ConcertManagementFailure.unknownStatus
            : ConcertManagementFailure.sellingStarted,
      );
    });
  }

  test('삭제 요청 중 삭제와 밴드 빼기를 연달아 눌러도 쓰기는 한 번이다', () async {
    final commands = _Commands();
    final container = await _container(_host, commands);
    final model = container.read(
      concertManagementViewModelProvider(12).notifier,
    );

    final first = model.deleteConcert();
    await model.deleteConcert();
    await model.removeBand(4);

    expect(commands.writes, 1);
    expect(
      container.read(concertManagementViewModelProvider(12)).submitting,
      isTrue,
    );
    commands.pending.complete();
    await first;
    expect(
      container.read(concertManagementViewModelProvider(12)).deleted,
      isTrue,
    );
  });

  for (final entry in {
    'CONCERT_001': ConcertManagementFailure.concertNotFound,
    'AUTH_005': ConcertManagementFailure.forbidden,
    'CONCERT_007': ConcertManagementFailure.bandNotParticipating,
    'CONCERT_008': ConcertManagementFailure.hostBand,
    'CONCERT_009': ConcertManagementFailure.sellingStarted,
  }.entries) {
    test('서버 ${entry.key} 거부를 보존하고 다시 누를 수 있게 한다', () async {
      final commands = _Commands();
      final container = await _container(_host, commands);
      final model = container.read(
        concertManagementViewModelProvider(12).notifier,
      );

      final first = model.removeBand(4);
      commands.pending.completeError(
        ApiException(statusCode: 409, code: entry.key),
      );
      await first;

      final state = container.read(concertManagementViewModelProvider(12));
      expect(state.failure, entry.value);
      expect(state.submitting, isFalse);
      expect(state.removedBandIds, entry.key == 'CONCERT_007' ? {4} : isEmpty);
    });
  }

  test('화면을 닫은 뒤 늦게 온 쓰기 응답은 상태에 반영하지 않는다', () async {
    final commands = _Commands();
    final container = await _container(_host, commands);
    final model = container.read(
      concertManagementViewModelProvider(12).notifier,
    );
    final first = model.deleteConcert();

    container.invalidate(concertManagementViewModelProvider);
    commands.pending.complete();
    await first;

    expect(
      container.read(concertManagementViewModelProvider(12)).deleted,
      isFalse,
    );
  });
}
