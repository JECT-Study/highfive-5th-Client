import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';

void main() {
  test('기본 fake는 예시 ID를 조회하며 대표자 권한을 주지 않는다', () async {
    final repository = FakeConcertRepository();

    final detail = await repository.fetchDetail(12);

    expect(detail.concertId, 12);
    expect(detail.version, 3);
    expect(detail.myPermissions.isHostLeader, isFalse);
    expect(detail.myPermissions.isTeamLeader, isFalse);
  });

  test('없는 ID를 예시 공연으로 바꾸지 않고 404를 반환한다', () async {
    final repository = FakeConcertRepository();

    await expectLater(
      repository.fetchDetail(99),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 404)
            .having((e) => e.code, 'code', 'CONCERT_001'),
      ),
    );
  });

  test('접근 금지 공연은 명세의 참여 권한 오류를 반환한다', () async {
    final repository = FakeConcertRepository(forbiddenConcertIds: {12});

    await expectLater(
      repository.fetchDetail(12),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 403)
            .having((e) => e.code, 'code', 'AUTH_005'),
      ),
    );
  });

  test('입력 컬렉션을 바꿔도 저장소의 공연과 접근 권한은 유지된다', () async {
    final concerts = [
      FakeConcertRepository.sample,
      FakeConcertRepository.sample.copyWith(concertId: 27, version: 8),
    ];
    final forbidden = <int>{};
    final repository = FakeConcertRepository(
      concerts: concerts,
      forbiddenConcertIds: forbidden,
    );
    concerts.clear();
    forbidden.add(27);

    final detail = await repository.fetchDetail(27);

    expect(detail.concertId, 27);
    expect(detail.version, 8);
  });

  test('명시적으로 빈 저장소에는 예시 공연도 없다', () async {
    final repository = FakeConcertRepository(concerts: []);

    await expectLater(
      repository.fetchDetail(12),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'CONCERT_001')),
    );
  });
}
