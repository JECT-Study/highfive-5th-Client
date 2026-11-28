import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/locator.dart';
import '../../data/repositories/concert_creation_repository.dart';
import '../../data/repositories/host_band_repository.dart';
import '../../models/host_band.dart';

/// 공연 생성 저장소 연결 Provider. 테스트는 overrides로 바꿔 끼운다.
final concertCreationRepositoryProvider = Provider<ConcertCreationRepository>(
  (ref) => getIt<ConcertCreationRepository>(),
);

/// 주최 밴드 목록 저장소 연결 Provider. 지금은 임시 목록이다 (`app/di.dart`).
final hostBandRepositoryProvider = Provider<HostBandRepository>(
  (ref) => getIt<HostBandRepository>(),
);

/// 밴드 선택 시트가 열릴 때마다 새로 받는 내가 대표자인 밴드 목록.
/// 자동 재시도는 끈다. 실패하면 시트가 안내하고 사용자가 다시 시도한다.
final hostBandsProvider = FutureProvider.autoDispose<List<HostBand>>(
  (ref) => ref.watch(hostBandRepositoryProvider).fetchHostBands(),
  retry: (_, _) => null,
);

/// 오늘을 알려 주는 시계. 날짜 검증과 달력이 같은 값을 쓰고, 테스트는 고정 날짜로 바꿔 끼운다.
final concertTodayProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);
