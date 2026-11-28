import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/locator.dart';
import '../../data/repositories/my_concerts_repository.dart';
import 'concert_detail_providers.dart';

/// 현재 세션의 상세 저장소로 목록을 만든다. 부모 스코프의 전역 fake를 다시 읽지 않는다.
final myConcertsRepositoryProvider = Provider<MyConcertsRepository>(
  (ref) =>
      getIt<MyConcertsRepository>(param1: ref.watch(concertRepositoryProvider)),
  dependencies: [concertRepositoryProvider],
);

/// 진행 중·지난 공연을 나눌 때 쓰는 지금 시각. 테스트는 overrides로 고정한다.
final myConcertsClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
  dependencies: const [],
);
