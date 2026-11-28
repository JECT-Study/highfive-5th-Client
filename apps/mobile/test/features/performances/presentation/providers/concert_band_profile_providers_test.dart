import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/performances/data/repositories/concert_participants_repository.dart';
import 'package:highfive/features/performances/data/repositories/concert_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_participants_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/models/concert_participant.dart';
import 'package:highfive/features/performances/models/concert_detail.dart';
import 'package:highfive/features/performances/presentation/providers/concert_band_profile_providers.dart';
import 'package:highfive/features/performances/presentation/providers/concert_detail_providers.dart';
import 'package:highfive/features/performances/presentation/providers/concert_participants_providers.dart';

/// 서버의 합류·빼기·권한 변경을 재조회 때 돌려준다.
class _Participants implements ConcertParticipantsRepository {
  List<ConcertParticipant> teams = FakeConcertParticipantsRepository.sample;
  Object? error;
  var calls = 0;

  @override
  Future<List<ConcertParticipant>> fetchParticipants(int concertId) async {
    calls++;
    final error = this.error;
    if (error != null) throw error;
    return teams;
  }
}

class _UnavailableConcerts implements ConcertRepository {
  @override
  Future<ConcertDetail> fetchDetail(int concertId) async =>
      throw const NetworkException();
}

void main() {
  final profile = concertBandProfileProvider((concertId: 12, bandId: 9001));

  ProviderContainer start(
    _Participants participants, {
    ConcertRepository? concerts,
  }) {
    final container = ProviderContainer.test(
      retry: (count, error) => null,
      overrides: [
        concertRepositoryProvider.overrideWithValue(
          concerts ?? FakeConcertRepository(),
        ),
        concertParticipantsRepositoryProvider.overrideWithValue(participants),
      ],
    );
    container.listen(profile, (previous, next) {});
    return container;
  }

  Future<void> loaded(ProviderContainer container) async {
    await Future.wait([
      container.read(concertDetailProvider(12).future),
      container.read(concertParticipantsProvider(12).future),
    ]);
    await container.pump();
  }

  test('상세·참여 목록의 캐시를 합쳐 선택한 밴드와 공연 제목을 보인다', () async {
    final participants = _Participants();
    final container = start(participants);
    await loaded(container);

    final result = container.read(profile).requireValue!;
    expect(result.band.bandId, 9001);
    expect(result.band.name, participants.teams.last.name);
    expect(result.concertTitle, FakeConcertRepository.sample.title);
    expect(participants.calls, 1);

    // 정보 탭이 같은 provider를 구독해도 별도 roster 요청이 생기지 않는다.
    container.listen(concertParticipantsProvider(12), (previous, next) {});
    expect(participants.calls, 1);
  });

  test('재조회에서 밴드가 빠지면 이전 프로필 대신 없음으로 바뀐다', () async {
    final participants = _Participants();
    final container = start(participants);
    await loaded(container);
    expect(container.read(profile).requireValue?.band.bandId, 9001);

    participants.teams = [participants.teams.first];
    container.invalidate(concertParticipantsProvider(12));
    await container.read(concertParticipantsProvider(12).future);
    await container.pump();

    expect(container.read(profile).requireValue, isNull);
    expect(participants.calls, 2);
  });

  test('재조회 접근 거부는 이전 프로필을 숨기고 원래 오류를 전달한다', () async {
    final participants = _Participants();
    final container = start(participants);
    await loaded(container);
    const denied = ApiException(statusCode: 403, code: 'AUTH_005');

    participants.error = denied;
    container.invalidate(concertParticipantsProvider(12));
    await expectLater(
      container.read(concertParticipantsProvider(12).future),
      throwsA(same(denied)),
    );
    await container.pump();

    expect(container.read(profile).error, same(denied));
    expect(container.read(profile).hasValue, isFalse);
  });

  test('다른 공연의 같은 밴드 ID로는 이전 공연 프로필을 재사용하지 않는다', () async {
    final container = start(_Participants());
    await loaded(container);
    final other = concertBandProfileProvider((concertId: 27, bandId: 9001));
    container.listen(other, (previous, next) {});

    await expectLater(
      container.read(concertDetailProvider(27).future),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 404)),
    );
    await container.pump();

    expect(container.read(other).hasValue, isFalse);
    expect(container.read(other).error, isA<ApiException>());
    expect(container.read(profile).requireValue?.band.bandId, 9001);
  });

  test('어느 조회에서든 접근 거부·삭제는 다른 조회의 네트워크 오류보다 우선한다', () async {
    for (final (concerts, participantsError, status) in [
      (
        FakeConcertRepository(forbiddenConcertIds: {12}),
        const NetworkException(),
        403,
      ),
      (FakeConcertRepository(concerts: []), const NetworkException(), 404),
      (
        _UnavailableConcerts(),
        const ApiException(statusCode: 403, code: 'AUTH_005'),
        403,
      ),
      (
        _UnavailableConcerts(),
        const ApiException(statusCode: 404, code: 'CONCERT_001'),
        404,
      ),
    ]) {
      final participants = _Participants()..error = participantsError;
      final container = start(participants, concerts: concerts);
      final detailFailed = Completer<void>();
      final participantsFailed = Completer<void>();
      final detailSubscription = container.listen(concertDetailProvider(12), (
        previous,
        next,
      ) {
        if (next.hasError && !detailFailed.isCompleted) {
          detailFailed.complete();
        }
      });
      final participantsSubscription = container.listen(
        concertParticipantsProvider(12),
        (previous, next) {
          if (next.hasError && !participantsFailed.isCompleted) {
            participantsFailed.complete();
          }
        },
      );
      addTearDown(detailSubscription.close);
      addTearDown(participantsSubscription.close);

      await Future.wait([detailFailed.future, participantsFailed.future])
          .timeout(const Duration(seconds: 5));
      await container.pump();
      final error = container.read(profile).error;
      expect(
        error,
        isA<ApiException>().having((e) => e.statusCode, 'status', status),
      );
      expect(container.read(profile).hasValue, isFalse);
    }
  });
}
