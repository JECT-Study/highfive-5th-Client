import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/performances/data/repositories/concert_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/models/concert_detail.dart';
import 'package:highfive/features/performances/presentation/providers/concert_detail_providers.dart';

/// 같은 서버 저장소에서 다른 사용자의 수정이 일어난 상황을 재현한다.
class _MutableConcertRepository implements ConcertRepository {
  final details = {
    12: FakeConcertRepository.sample,
    27: FakeConcertRepository.sample.copyWith(concertId: 27, version: 8),
  };

  @override
  Future<ConcertDetail> fetchDetail(int concertId) async =>
      details[concertId] ??
      (throw const ApiException(statusCode: 404, code: 'CONCERT_001'));
}

void main() {
  test('ID별 성공과 404 오류는 서로의 상태를 바꾸지 않는다', () async {
    final container = ProviderContainer(
      overrides: [
        concertRepositoryProvider.overrideWithValue(FakeConcertRepository()),
      ],
    );
    addTearDown(container.dispose);
    final valid = container.listen(concertDetailProvider(12), (_, _) {});
    final missing = container.listen(concertDetailProvider(99), (_, _) {});
    addTearDown(valid.close);
    addTearDown(missing.close);

    await expectLater(
      container.read(concertDetailProvider(99).future),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'CONCERT_001')),
    );

    expect(
      (await container.read(concertDetailProvider(12).future)).concertId,
      12,
    );
    expect(container.read(concertDetailProvider(99)).hasError, isTrue);
  });

  test('같은 저장소에서 invalidate한 ID만 새 버전을 조회한다', () async {
    final repository = _MutableConcertRepository();
    final container = ProviderContainer(
      overrides: [concertRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final first = container.listen(concertDetailProvider(12), (_, _) {});
    final second = container.listen(concertDetailProvider(27), (_, _) {});
    addTearDown(first.close);
    addTearDown(second.close);
    expect((await container.read(concertDetailProvider(12).future)).version, 3);
    expect((await container.read(concertDetailProvider(27).future)).version, 8);
    repository.details[12] = repository.details[12]!.copyWith(version: 4);
    repository.details[27] = repository.details[27]!.copyWith(version: 9);
    expect(container.read(concertDetailProvider(12)).requireValue.version, 3);

    container.invalidate(concertDetailProvider(12));

    expect((await container.read(concertDetailProvider(12).future)).version, 4);
    expect(container.read(concertDetailProvider(27)).requireValue.version, 8);
  });

  test('마지막 구독 해제 후 다시 구독하면 이전 상세를 재사용하지 않는다', () async {
    final repository = _MutableConcertRepository();
    final container = ProviderContainer(
      overrides: [concertRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final first = container.listen(concertDetailProvider(12), (_, _) {});
    expect((await container.read(concertDetailProvider(12).future)).version, 3);

    first.close();
    await container.pump();
    repository.details[12] = repository.details[12]!.copyWith(version: 4);
    final next = container.listen(concertDetailProvider(12), (_, _) {});
    addTearDown(next.close);

    expect((await container.read(concertDetailProvider(12).future)).version, 4);
  });
}
