import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/performances/data/dto/concert_create_dto.dart';
import 'package:highfive/features/performances/data/repositories/concert_creation_repository.dart';
import 'package:highfive/features/performances/data/repositories/local_concert_creation_repository.dart';
import 'package:highfive/features/performances/data/services/concert_creation_service.dart';
import 'package:highfive/features/performances/models/concert_creation_failure.dart';
import 'package:highfive/features/performances/models/concert_draft.dart';
import 'package:highfive/features/performances/models/concert_genre.dart';
import 'package:highfive/features/performances/models/host_band.dart';

/// 서버 대신 받은 요청을 기록하고 정해진 오류를 던진다.
class _FakeService extends ConcertCreationService {
  _FakeService({this.error}) : super(Dio());

  final AppException? error;
  int calls = 0;
  ConcertCreateRequestDto? request;
  Future<void>? abandoned;

  @override
  Future<ConcertCreateResponseDto> create(
    ConcertCreateRequestDto request, {
    Future<void>? abandoned,
  }) async {
    calls++;
    this.request = request;
    this.abandoned = abandoned;
    if (error case final error?) throw error;
    return const ConcertCreateResponseDto(concertId: 12);
  }
}

const _band = HostBand.authenticated(
  id: 3,
  name: '소음공장',
  genres: [ConcertGenre.rock],
  memberCount: 4,
);

ConcertDraft _draft({bool rentalFeeUndecided = true, String rentalFee = ''}) =>
    ConcertDraft(
      title: ' 겨울 합동공연 ',
      genres: const {ConcertGenre.indie, ConcertGenre.rock},
      recruitTeamCount: 2,
      performDate: DateTime(2026, 12, 5, 18),
      rentalFeeUndecided: rentalFeeUndecided,
      rentalFeeText: rentalFee,
    );

void main() {
  test('임시 밴드는 같은 숫자의 실제 ID가 있어도 원격 호출 없이 로컬에만 만든다', () async {
    final service = _FakeService();
    final local = LocalConcertCreationRepository();
    final repository = ConcertCreationRepository.forContractTest(
      service,
      local: local,
    );
    const fixture = HostBand(
      id: 3,
      name: '임시 밴드',
      genres: [ConcertGenre.rock],
      memberCount: 4,
    );
    final draft = _draft();

    final id = await repository.create(fixture, draft);

    expect(id, -1);
    expect(service.request, isNull);
    expect(local.concerts[id]?.band, same(fixture));
    expect(local.concerts[id]?.draft, same(draft));
  });

  test('고른 밴드를 주최 팀으로 정리한 요청을 보내고 서버가 만든 공연 ID를 돌려준다', () async {
    final service = _FakeService();

    final concertId = await ConcertCreationRepository.forContractTest(service)
        .create(_band, _draft());

    expect(concertId, 12);
    expect(service.request?.toJson(), {
      'bandId': 3,
      'title': '겨울 합동공연',
      'genres': ['ROCK', 'INDIE'],
      'recruitTeamCount': 2,
      'performDate': '2026-12-05',
      'rentalFee': null,
    });
  });

  test('화면이 닫힘을 알리는 신호를 Service까지 그대로 넘긴다', () async {
    final service = _FakeService();
    final abandoned = Completer<void>().future;

    await ConcertCreationRepository.forContractTest(service)
        .create(_band, _draft(), abandoned: abandoned);

    expect(service.abandoned, same(abandoned));
  });

  test('대관비를 적었으면 원 단위 숫자로 보낸다', () async {
    final service = _FakeService();

    await ConcertCreationRepository.forContractTest(service)
        .create(_band, _draft(rentalFeeUndecided: false, rentalFee: '500000'));

    expect(service.request?.rentalFee, 500000);
  });

  test('서버 오류를 화면이 쓰는 실패 이유로 바꾼다', () async {
    final cases = <AppException, ConcertCreationFailureReason>{
      const NetworkException(): ConcertCreationFailureReason.network,
      const ApiException(statusCode: 400, code: 'COMMON_004'):
          ConcertCreationFailureReason.invalidInput,
      const ApiException(statusCode: 400, code: 'COMMON_001'):
          ConcertCreationFailureReason.invalidInput,
      const ApiException(statusCode: 400, code: 'CONCERT_010'):
          ConcertCreationFailureReason.invalidInput,
      const ApiException(statusCode: 400, code: 'CONCERT_002'):
          ConcertCreationFailureReason.pastDate,
      const ApiException(statusCode: 403, code: 'AUTH_005'):
          ConcertCreationFailureReason.forbidden,
      const ApiException(statusCode: 401, code: 'AUTH_001'):
          ConcertCreationFailureReason.rejected,
      const ApiException(statusCode: 500):
          ConcertCreationFailureReason.uncertain,
      const ApiException(statusCode: 500, code: 'COMMON_001'):
          ConcertCreationFailureReason.uncertain,
      const ApiException(statusCode: 302, code: 'COMMON_001'):
          ConcertCreationFailureReason.uncertain,
      const ApiException(statusCode: null):
          ConcertCreationFailureReason.uncertain,
      const UnknownApiException(DioExceptionType.receiveTimeout):
          ConcertCreationFailureReason.uncertain,
    };

    for (final MapEntry(key: error, value: reason) in cases.entries) {
      await expectLater(
        ConcertCreationRepository.forContractTest(_FakeService(error: error))
            .create(_band, _draft()),
        throwsA(
          isA<ConcertCreationFailure>()
              .having((f) => f.reason, 'reason', reason)
              .having((f) => f.cause, 'cause', error),
        ),
        reason: '$error',
      );
    }
  });

  test('결과 불명은 화면을 새로 열어도 같은 밴드의 원격 생성을 다시 보내지 않는다', () async {
    for (final error in [
      const UnknownApiException(DioExceptionType.receiveTimeout),
      const ApiException(statusCode: 500, code: 'COMMON_001'),
      const ApiException(statusCode: 302, code: 'COMMON_001'),
    ]) {
      final service = _FakeService(error: error);
      final repository = ConcertCreationRepository.forContractTest(service);

      await expectLater(
        repository.create(_band, _draft()),
        throwsA(isA<ConcertCreationFailure>()),
      );
      service.request = null;

      await expectLater(
        repository.create(_band, _draft()),
        throwsA(
          isA<ConcertCreationFailure>().having(
            (failure) => failure.reason,
            'reason',
            ConcertCreationFailureReason.uncertain,
          ),
        ),
      );
      expect(service.request, isNull);
      expect(service.calls, 1, reason: '$error');
    }
  });
}
