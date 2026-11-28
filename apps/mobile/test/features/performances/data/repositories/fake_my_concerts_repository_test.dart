import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_my_concerts_repository.dart';
import 'package:highfive/features/performances/models/concert_detail.dart';

class _FailingConcertRepository extends FakeConcertRepository {
  _FailingConcertRepository(this.error);

  final AppException error;

  @override
  Future<ConcertDetail> fetchDetail(int concertId) {
    if (concertId == 13) return Future.error(error);
    return super.fetchDetail(concertId);
  }
}

void main() {
  test('예시 공연은 모두 상세 fake에서 같은 ID로 읽혀, 카드마다 자기 공연이 열린다', () async {
    final details = FakeConcertRepository(
      concerts: FakeMyConcertsRepository.samples,
    );

    final concerts = await FakeMyConcertsRepository(details).fetchMyConcerts();

    expect(
      [for (final concert in concerts) concert.concertId],
      [for (final sample in FakeMyConcertsRepository.samples) sample.concertId],
    );
    for (final concert in concerts) {
      final detail = await details.fetchDetail(concert.concertId);
      expect(concert.title, detail.title);
    }
  });

  test('예시 공연마다 참여 밴드가 있고, 주최 팀과 내 밴드가 상세와 맞는다', () {
    for (final detail in FakeMyConcertsRepository.samples) {
      final participants =
          FakeMyConcertsRepository.participantSamples[detail.concertId];

      expect(participants, isNotNull, reason: '${detail.concertId}');
      expect(
        participants!.singleWhere((band) => band.isHost).bandId,
        detail.hostBandId,
        reason: '${detail.concertId}',
      );
      expect(
        [for (final band in participants) band.bandId],
        containsAll(detail.myBandIds),
        reason: '${detail.concertId}',
      );
    }
  });

  test('상세 값을 카드 값으로 옮긴다: 날짜·시간은 서버 문자열 그대로, 지역은 주소 앞 두 단어', () async {
    final details = FakeConcertRepository(
      concerts: [
        FakeConcertRepository.sample.copyWith(
          performDate: '2026-12-20',
          startTime: '19:30:00',
          address: '서울 마포구 어울마당로 35',
          posterImageUrl: 'https://example.com/poster.png',
        ),
      ],
    );

    final [concert] = await FakeMyConcertsRepository(
      details,
      concertIds: [12],
    ).fetchMyConcerts();

    expect(concert.performDate, '2026-12-20');
    expect(concert.startTime, '19:30:00');
    expect(concert.area, '서울 마포구');
    expect(concert.posterImageUrl, 'https://example.com/poster.png');
  });

  test('주소가 없으면 공연장을 쓰고, 주소와 공연장이 모두 없으면 장소 미정이다', () async {
    final details = FakeConcertRepository(
      concerts: [
        FakeConcertRepository.sample.copyWith(
          address: null,
          place: '  홍대 롤링홀  ',
        ),
        FakeConcertRepository.sample.copyWith(
          concertId: 13,
          address: null,
          place: null,
        ),
        FakeConcertRepository.sample.copyWith(
          concertId: 14,
          address: null,
          place: '   ',
        ),
      ],
    );

    final concerts = await FakeMyConcertsRepository(
      details,
      concertIds: [12, 13, 14],
    ).fetchMyConcerts();

    expect(concerts.map((concert) => concert.area), ['홍대 롤링홀', null, null]);
  });

  test('참여 밴드가 없는 공연은 내 공연 목록에 포함하지 않는다', () async {
    final details = FakeConcertRepository(
      concerts: [
        FakeConcertRepository.sample,
        FakeConcertRepository.sample.copyWith(concertId: 13, myBandIds: []),
      ],
    );

    final concerts = await FakeMyConcertsRepository(
      details,
      concertIds: [12, 13],
    ).fetchMyConcerts();

    expect(concerts.map((concert) => concert.concertId), [12]);
  });

  test('주최 여부는 대표자 권한이 아니라 내 밴드가 주최 팀인지로 정한다', () async {
    final details = FakeConcertRepository(
      concerts: [
        // 내 밴드가 주최 팀이지만 나는 대표자가 아니다.
        FakeConcertRepository.sample.copyWith(
          concertId: 1,
          hostBandId: 3,
          myBandIds: [3],
          myPermissions: const ConcertPermissions(
            isHostLeader: false,
            isTeamLeader: false,
          ),
        ),
        // 다른 밴드가 주최하고 나는 참여 팀 대표자다.
        FakeConcertRepository.sample.copyWith(
          concertId: 2,
          hostBandId: 8,
          myBandIds: [3],
          myPermissions: const ConcertPermissions(
            isHostLeader: false,
            isTeamLeader: true,
          ),
        ),
      ],
    );

    final concerts = await FakeMyConcertsRepository(
      details,
      concertIds: [1, 2],
    ).fetchMyConcerts();

    expect([for (final concert in concerts) concert.isHost], [true, false]);
  });

  test('삭제된 공연과 정상 공연이 섞여 있으면 정상 공연만 돌려준다', () async {
    final repository = FakeMyConcertsRepository(
      FakeConcertRepository(),
      concertIds: [990001, 12],
    );

    final concerts = await repository.fetchMyConcerts();

    expect(concerts.map((concert) => concert.concertId), [12]);
  });

  test('참여 권한을 잃은 공연은 다른 공연과 섞여 있어도 노출하지 않는다', () async {
    final repository = FakeMyConcertsRepository(
      FakeConcertRepository(
        concerts: [
          FakeConcertRepository.sample,
          FakeConcertRepository.sample.copyWith(concertId: 13),
        ],
        forbiddenConcertIds: {13},
      ),
      concertIds: [13, 12],
    );

    final concerts = await repository.fetchMyConcerts();

    expect(concerts.map((concert) => concert.concertId), [12]);
  });

  for (final error in [
    const ApiException(statusCode: 503, code: 'SERVER_001'),
    const ApiException(statusCode: 503, code: 'CONCERT_001'),
    const ApiException(statusCode: 503, code: 'AUTH_005'),
    const NetworkException(),
    const ApiException(statusCode: 403, code: 'UNEXPECTED_AUTH'),
    const ApiException(statusCode: 404, code: 'UNEXPECTED_MISSING'),
  ]) {
    test('확인된 삭제·비참여 이외의 $error 오류는 빈 목록으로 숨기지 않는다', () async {
      final repository = FakeMyConcertsRepository(
        _FailingConcertRepository(error),
        concertIds: [12, 13],
      );

      await expectLater(repository.fetchMyConcerts(), throwsA(same(error)));
    });
  }
}
