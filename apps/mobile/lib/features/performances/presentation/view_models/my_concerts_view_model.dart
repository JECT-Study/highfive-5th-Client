import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/utils/date_format.dart';
import '../../models/my_concert.dart';
import '../providers/my_concerts_providers.dart';

/// 마이페이지 내 공연 섹션의 상태. 목록을 읽어 진행 중·지난 공연으로 나눈다 (쓰기 명령 없음).
///
/// Riverpod 자동 재시도는 끈다. 실패하면 바로 안내하고 사용자가 "다시 시도"를 누른다.
final myConcertsViewModelProvider =
    AsyncNotifierProvider.autoDispose<MyConcertsViewModel, MyConcertsState>(
      MyConcertsViewModel.new,
      retry: (_, _) => null,
      dependencies: [myConcertsRepositoryProvider, myConcertsClockProvider],
    );

/// 진행 중(`내 공연`)과 지난 공연(`공연 이력`)으로 나눈 내 공연.
///
/// 명세 없음: 나누는 기준과 순서는 추정이다. 상세 헤더처럼 기기 날짜 기준 오늘보다 앞이면 지난 공연이고,
/// 오늘 공연과 날짜 미정은 진행 중이다. 진행 중은 가까운 날짜부터(미정은 맨 뒤), 지난 공연은 최근부터 둔다.
class MyConcertsState {
  factory MyConcertsState.split(
    Iterable<MyConcert> concerts, {
    required DateTime now,
  }) {
    final today = DateTime.utc(now.year, now.month, now.day);
    final current = <_Dated>[];
    final past = <_Dated>[];
    for (final (order, concert) in concerts.indexed) {
      final days = daysUntilLocalDate(concert.performDate, today);
      (days != null && days < 0 ? past : current).add((
        order: order,
        concert: concert,
        days: days,
      ));
    }
    return MyConcertsState._(
      today: today,
      current: _byDate(current, latestFirst: false),
      past: _byDate(past, latestFirst: true),
    );
  }

  const MyConcertsState._({
    required this.today,
    required this.current,
    required this.past,
  });

  /// 기기 날짜 기준 오늘. 날짜 연산에 시각·서머타임이 끼지 않도록 UTC 자정으로 표현한다.
  final DateTime today;

  /// 진행 중 공연 (`내 공연` 카드).
  final List<MyConcert> current;

  /// 지난 공연 (`공연 이력` 줄).
  final List<MyConcert> past;

  /// 공연까지 남은 날 수. 오늘이면 0, 지난 공연이면 음수, 날짜 미정이면 null.
  int? daysUntil(MyConcert concert) =>
      daysUntilLocalDate(concert.performDate, today);
}

class MyConcertsViewModel extends AsyncNotifier<MyConcertsState> {
  @override
  Future<MyConcertsState> build() async {
    final repository = ref.watch(myConcertsRepositoryProvider);
    final now = ref.watch(myConcertsClockProvider);
    final concerts = await repository.fetchMyConcerts();
    return MyConcertsState.split(concerts, now: now());
  }

  /// "다시 시도"와, 공연 페이지에서 돌아왔을 때 다시 읽기.
  void refresh() => ref.invalidateSelf();
}

typedef _Dated = ({int order, MyConcert concert, int? days});

/// 남은 날 수 순서로 정렬한 새 목록. 같으면 받은 순서를 지키고, 미정은 맨 뒤에 둔다.
List<MyConcert> _byDate(List<_Dated> items, {required bool latestFirst}) {
  final sorted = [...items]
    ..sort((a, b) {
      final byDate = switch ((a.days, b.days)) {
        (null, null) => 0,
        (null, _) => 1,
        (_, null) => -1,
        (final x?, final y?) => latestFirst ? y.compareTo(x) : x.compareTo(y),
      };
      return byDate != 0 ? byDate : a.order.compareTo(b.order);
    });
  return List.unmodifiable([for (final item in sorted) item.concert]);
}
