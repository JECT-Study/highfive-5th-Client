import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/data/repositories/my_concerts_repository.dart';
import 'package:highfive/features/performances/models/concert_status.dart';
import 'package:highfive/features/performances/models/my_concert.dart';
import 'package:highfive/features/performances/presentation/providers/my_concerts_providers.dart';
import 'package:highfive/features/performances/presentation/view_models/my_concerts_view_model.dart';

/// 서버 대신 목록을 돌려주고 읽은 횟수를 센다. [error]가 있으면 실패한다.
class _FakeMyConcertsRepository implements MyConcertsRepository {
  _FakeMyConcertsRepository(this.concerts, {this.error});

  final List<MyConcert> concerts;
  Object? error;
  int fetchCount = 0;

  @override
  Future<List<MyConcert>> fetchMyConcerts() async {
    fetchCount++;
    if (error case final error?) throw error;
    return concerts;
  }
}

MyConcert _concert(int id, String? performDate) => MyConcert(
  concertId: id,
  title: '공연 $id',
  status: ConcertStatus.recruiting,
  performDate: performDate,
  startTime: null,
  area: null,
  isHost: false,
  posterImageUrl: null,
);

/// 상세 헤더와 같은 기기 날짜.
final _now = DateTime(2026, 11, 28, 12);

List<int> _ids(List<MyConcert> concerts) => [
  for (final concert in concerts) concert.concertId,
];

ProviderContainer _container(_FakeMyConcertsRepository repository) {
  final container = ProviderContainer(
    overrides: [
      myConcertsRepositoryProvider.overrideWithValue(repository),
      myConcertsClockProvider.overrideWithValue(() => _now),
    ],
  );
  addTearDown(container.dispose);
  // autoDispose라 테스트 동안 구독해 둔다.
  container.listen(myConcertsViewModelProvider, (_, _) {});
  return container;
}

void main() {
  group('MyConcertsState.split', () {
    test('공연 날짜가 기기 날짜 기준 오늘보다 앞이면 지난 공연이고, 오늘·이후·미정은 진행 중이다', () {
      final state = MyConcertsState.split([
        _concert(1, '2026-11-27'),
        _concert(2, '2026-11-28'),
        _concert(3, '2026-12-01'),
        _concert(4, null),
        _concert(5, '2026/12/20'),
      ], now: _now);

      expect(_ids(state.current), [2, 3, 4, 5]);
      expect(_ids(state.past), [1]);
    });

    test('진행 중은 가까운 날짜부터(같은 날은 받은 순서, 미정은 맨 뒤), 지난 공연은 최근부터 둔다', () {
      final state = MyConcertsState.split([
        _concert(1, null),
        _concert(2, '2026-12-24'),
        _concert(3, '2026-10-02'),
        _concert(4, '2026-12-01'),
        _concert(5, '2026-11-01'),
        _concert(6, '2026-12-01'),
      ], now: _now);

      expect(_ids(state.current), [4, 6, 2, 1]);
      expect(_ids(state.past), [5, 3]);
    });

    test('기기 자정이 지나면 전날 공연은 지난 공연이 된다', () {
      final concerts = [_concert(1, '2026-11-28')];

      final before = MyConcertsState.split(
        concerts,
        now: DateTime(2026, 11, 28, 23, 59),
      );
      final after = MyConcertsState.split(
        concerts,
        now: DateTime(2026, 11, 29),
      );

      expect(_ids(before.current), [1]);
      expect(_ids(after.past), [1]);
    });

    test('남은 날은 오늘 공연이면 0, 날짜 미정이면 null이다', () {
      final today = _concert(1, '2026-11-28');
      final later = _concert(2, '2026-12-20');
      final undecided = _concert(3, null);

      final state = MyConcertsState.split([today, later, undecided], now: _now);

      expect(state.daysUntil(today), 0);
      expect(state.daysUntil(later), 22);
      expect(state.daysUntil(undecided), isNull);
    });
  });

  test('처음 읽는 동안 로딩이고, 받으면 기기 날짜로 진행 중·지난 공연을 나눈다', () async {
    final container = _container(
      _FakeMyConcertsRepository([
        _concert(1, '2026-10-02'),
        _concert(2, '2026-12-20'),
      ]),
    );

    expect(container.read(myConcertsViewModelProvider).isLoading, isTrue);
    final state = await container.read(myConcertsViewModelProvider.future);

    expect(_ids(state.current), [2]);
    expect(_ids(state.past), [1]);
  });

  test('목록을 못 받으면 오류이고, 다시 읽으면 다시 받는다', () async {
    final repository = _FakeMyConcertsRepository([
      _concert(1, '2026-12-20'),
    ], error: Exception('network'));
    final container = _container(repository);

    await expectLater(
      container.read(myConcertsViewModelProvider.future),
      throwsA(isA<Exception>()),
    );

    repository.error = null;
    container.read(myConcertsViewModelProvider.notifier).refresh();
    final state = await container.read(myConcertsViewModelProvider.future);

    expect(_ids(state.current), [1]);
    expect(repository.fetchCount, 2);
  });
}
