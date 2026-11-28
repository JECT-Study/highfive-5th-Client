import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/locator.dart';
import '../../../../core/error/app_exception.dart';
import '../../data/repositories/concert_repository.dart';
import '../../models/concert_detail.dart';

final concertRepositoryProvider = Provider<ConcertRepository>(
  (ref) => getIt<ConcertRepository>(),
);

/// 상세·수정·정보 화면이 공유하는 ID별 조회. 쓰기 성공 후 이 family를 invalidate한다.
final concertDetailProvider = FutureProvider.autoDispose
    .family<ConcertDetail, int>(
      (ref, concertId) =>
          ref.watch(concertRepositoryProvider).fetchDetail(concertId),
      // 존재하지 않거나 참여하지 않은 공연은 재시도로 복구되지 않는다.
      retry: (count, error) => switch (error) {
        ApiException(statusCode: 403 || 404) => null,
        _ => ProviderContainer.defaultRetry(count, error),
      },
    );
