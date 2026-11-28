import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/locator.dart';
import '../../../../core/error/app_exception.dart';
import '../../data/repositories/concert_participants_repository.dart';
import '../../models/concert_participant.dart';

final concertParticipantsRepositoryProvider =
    Provider<ConcertParticipantsRepository>(
      (ref) => getIt<ConcertParticipantsRepository>(),
    );

/// 정보 탭 참여 밴드 미리보기가 쓰는 공연별 참여 밴드. 빼기 같은 쓰기 성공 후 이 family를 invalidate한다.
final concertParticipantsProvider = FutureProvider.autoDispose
    .family<List<ConcertParticipant>, int>(
      (ref, concertId) => ref
          .watch(concertParticipantsRepositoryProvider)
          .fetchParticipants(concertId),
      // 공연 상세와 같다: 없는 공연·참여하지 않은 공연은 재시도로 복구되지 않는다.
      retry: (count, error) => switch (error) {
        ApiException(statusCode: 403 || 404) => null,
        _ => ProviderContainer.defaultRetry(count, error),
      },
    );
